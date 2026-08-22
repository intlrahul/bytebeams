import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/features/alerts/data/duckdb_alert_projector.dart';
import 'package:bytebeams/features/geofences/data/duckdb_geofence_projector.dart';
import 'package:bytebeams/features/sync/data/sync_dto_mapper.dart';
import 'package:bytebeams/features/sync/data/sync_queries.dart';
import 'package:bytebeams/features/telemetry/data/telemetry_packet_classifier.dart';
import 'package:bytebeams/features/telemetry/data/telemetry_queries.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:bytebeams_api/bytebeams_api.dart' as api;

abstract interface class SyncStore {
  Future<String?> deliveryCursor();
  Future<bool> hasUsableFleetData();
  Future<void> importBootstrap(
    SyncBootstrapDto bootstrap, {
    required String origin,
  });
  Future<void> replaceBackendData(SyncBootstrapDto bootstrap);
  Future<void> ingestDeliveries(List<SyncDeliveryDto> deliveries);
}

final class DuckDbSyncStore implements SyncStore {
  const DuckDbSyncStore({
    required this._database,
    required this._classifier,
    this._alertProjector,
    this._geofenceProjector,
  });

  final AppDatabase _database;
  final TelemetryPacketClassifier _classifier;
  final AlertProjector? _alertProjector;
  final GeofenceProjector? _geofenceProjector;

  @override
  Future<String?> deliveryCursor() async {
    final rows = await _database.query(selectSyncCursor);
    return rows.isEmpty ? null : rows.single.single as String;
  }

  @override
  Future<bool> hasUsableFleetData() async {
    final rows = await _database.query('SELECT COUNT(*) FROM vehicles');
    return (rows.single.single as num) > 0;
  }

  @override
  Future<void> importBootstrap(
    SyncBootstrapDto bootstrap, {
    required String origin,
  }) => _database.transaction((transaction) async {
    await _upsertVehicles(transaction, bootstrap.vehicles);
    await _insertPackets(transaction, bootstrap.telemetry);
    await _alertProjector?.rebuild(
      transaction,
      bootstrap.vehicles.map((vehicle) => vehicle.vehicleId),
    );
    await _geofenceProjector?.rebuild(
      transaction,
      bootstrap.vehicles.map((vehicle) => vehicle.vehicleId),
    );
    await transaction.execute(
      upsertSyncCursor,
      parameters: [bootstrap.deliveryCursor],
    );
    await transaction.execute(upsertSyncOrigin, parameters: [origin]);
  });

  @override
  Future<void> replaceBackendData(SyncBootstrapDto bootstrap) =>
      _database.transaction((transaction) async {
        await transaction.execute(deleteBackendSyncedData);
        await transaction.execute(deleteBackendSyncedVehicles);
        await _upsertVehicles(transaction, bootstrap.vehicles);
        await _insertPackets(transaction, bootstrap.telemetry);
        await _alertProjector?.rebuild(
          transaction,
          bootstrap.vehicles.map((vehicle) => vehicle.vehicleId),
        );
        await _geofenceProjector?.rebuild(
          transaction,
          bootstrap.vehicles.map((vehicle) => vehicle.vehicleId),
        );
        await transaction.execute(
          upsertSyncCursor,
          parameters: [bootstrap.deliveryCursor],
        );
        await transaction.execute(upsertSyncOrigin, parameters: ['backend']);
      });

  @override
  Future<void> ingestDeliveries(List<SyncDeliveryDto> deliveries) =>
      _database.transaction((transaction) async {
        for (final delivery in deliveries) {
          await _insertPacket(transaction, delivery.packet);
        }
        await _alertProjector?.rebuild(
          transaction,
          deliveries.map((delivery) => delivery.packet.vehicleId),
        );
        await _geofenceProjector?.rebuild(
          transaction,
          deliveries.map((delivery) => delivery.packet.vehicleId),
        );
        final lastDelivery = deliveries.last;
        await transaction.execute(
          upsertSyncCursor,
          parameters: [lastDelivery.deliveryId],
        );
      });

  /// Convenience entry point for focused persistence tests and one-off imports.
  Future<void> ingestDelivery(SyncDeliveryDto delivery) =>
      ingestDeliveries([delivery]);

  Future<void> _insertPacket(
    DatabaseTransaction transaction,
    api.TelemetryPacket packet,
  ) async {
    final classified = _classifier.classify(packet);
    await classified.when(
      success: (value) => transaction.execute(
        insertTelemetryEvent,
        parameters: _parameters(value),
      ),
      failure: (_) => Future<void>.value(),
    );
  }

  Future<void> _upsertVehicles(
    DatabaseTransaction transaction,
    Iterable<Vehicle> vehicles,
  ) async {
    final values = vehicles.toList(growable: false);
    if (values.isEmpty) return;
    for (final chunk in _chunks(values)) {
      await transaction.execute(
        'INSERT INTO vehicles (vehicle_id, registration_number, model) VALUES '
        '${List.filled(chunk.length, '(?, ?, ?)').join(', ')} '
        'ON CONFLICT (vehicle_id) DO UPDATE SET '
        'registration_number = excluded.registration_number, model = excluded.model',
        parameters: [
          for (final vehicle in chunk) ...[
            vehicle.vehicleId,
            vehicle.registrationNumber,
            vehicle.model,
          ],
        ],
      );
    }
  }

  Future<void> _insertPackets(
    DatabaseTransaction transaction,
    Iterable<api.TelemetryPacket> packets,
  ) async {
    final values = <List<Object?>>[];
    for (final packet in packets) {
      final classified = _classifier.classify(packet);
      if (classified case Success<ClassifiedTelemetryPacket, TelemetryFailure>(
        value: final value,
      )) {
        values.add(_parameters(value));
      }
    }
    for (final chunk in _chunks(values)) {
      await transaction.execute(
        'INSERT INTO telemetry_events ('
        'packet_id, vehicle_id, event_timestamp_utc, server_received_at_utc, '
        'client_received_at_utc, signal_name, classification, raw_value_json, '
        'validation_error, number_value, boolean_value, latitude, longitude, accuracy_meters'
        ') VALUES ${List.filled(chunk.length, '(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)').join(', ')} '
        'ON CONFLICT (packet_id) DO NOTHING',
        parameters: [for (final packet in chunk) ...packet],
      );
    }
  }

  Iterable<List<T>> _chunks<T>(List<T> values) sync* {
    const size = 100;
    for (var start = 0; start < values.length; start += size) {
      final end = start + size > values.length ? values.length : start + size;
      yield values.sublist(start, end);
    }
  }

  List<Object?> _parameters(ClassifiedTelemetryPacket packet) {
    final value = packet.value;
    return [
      packet.packetId,
      packet.vehicleId,
      packet.eventTimestampUtc.toIso8601String(),
      packet.serverReceivedAtUtc?.toIso8601String(),
      packet.clientReceivedAtUtc.toIso8601String(),
      packet.signalName,
      packet.classification.name,
      packet.rawValueJson,
      packet.validationError,
      value is TelemetryNumberValue ? value.value : null,
      value is TelemetryBooleanValue ? value.value : null,
      value is TelemetryLocationValue ? value.latitude : null,
      value is TelemetryLocationValue ? value.longitude : null,
      value is TelemetryLocationValue ? value.accuracyMeters : null,
    ];
  }
}
