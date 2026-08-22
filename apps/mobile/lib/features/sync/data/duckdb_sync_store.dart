import 'package:bytebeams/core/data/database/app_database.dart';
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
  const DuckDbSyncStore({required this._database, required this._classifier});

  final AppDatabase _database;
  final TelemetryPacketClassifier _classifier;

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
    for (final vehicle in bootstrap.vehicles) {
      await transaction.execute(
        upsertVehicle,
        parameters: [
          vehicle.vehicleId,
          vehicle.registrationNumber,
          vehicle.model,
        ],
      );
    }
    for (final packet in bootstrap.telemetry) {
      await _insertPacket(transaction, packet);
    }
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
        for (final vehicle in bootstrap.vehicles) {
          await transaction.execute(
            upsertVehicle,
            parameters: [
              vehicle.vehicleId,
              vehicle.registrationNumber,
              vehicle.model,
            ],
          );
        }
        for (final packet in bootstrap.telemetry) {
          await _insertPacket(transaction, packet);
        }
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
