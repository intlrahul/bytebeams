import 'dart:async';
import 'dart:io';

import 'package:bytebeams/core/data/database/database_migration.dart';
import 'package:bytebeams/core/data/database/database_migration_loader.dart';
import 'package:bytebeams/core/data/database/database_path_provider.dart';
import 'package:bytebeams/core/data/database/duckdb_app_database.dart';
import 'package:bytebeams/core/time/clock.dart';
import 'package:bytebeams/features/geofences/data/duckdb_geofence_projector.dart';
import 'package:bytebeams/features/telemetry/data/duckdb_telemetry_repository.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:bytebeams/features/telemetry/data/telemetry_packet_classifier.dart';
import 'package:bytebeams/features/sync/data/duckdb_sync_store.dart';
import 'package:bytebeams/features/sync/data/sync_dto_mapper.dart';
import 'package:bytebeams/features/vehicle_detail/data/duckdb_vehicle_detail_repository.dart';
import 'package:bytebeams/features/vehicle_detail/domain/vehicle_detail_models.dart';
import 'package:bytebeams_api/bytebeams_api.dart' as api;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'given_writer_transaction_in_progress_when_vehicle_read_then_returns_committed_snapshot',
    (tester) async {
      const provider = ApplicationSupportDatabasePathProvider(
        fileName: 'reader_writer_concurrency_probe.duckdb',
      );
      final path = await provider.databasePath();
      final file = File(path);
      if (await file.exists()) await file.delete();
      final database = await DuckDbAppDatabase.open(
        path: path,
        migrations: await const AssetDatabaseMigrationLoader().load(),
        clock: _FixedClock(DateTime.utc(2026, 8, 22)),
      );
      await database.execute(
        'INSERT INTO vehicles (vehicle_id, registration_number, model) VALUES (?, ?, ?)',
        parameters: ['vehicle-1', 'BB-001', 'E-Truck'],
      );
      final transactionStarted = Completer<void>();
      final releaseTransaction = Completer<void>();

      final write = database.transaction<void>((transaction) async {
        await transaction.execute(
          'UPDATE vehicles SET registration_number = ? WHERE vehicle_id = ?',
          parameters: ['BB-UPDATED', 'vehicle-1'],
        );
        transactionStarted.complete();
        await releaseTransaction.future;
      });
      await transactionStarted.future;

      final repository = DuckDbVehicleDetailRepository(database);
      final committed = await repository.getVehicleDetail(
        vehicleId: 'vehicle-1',
        asOfUtc: DateTime.utc(2026, 8, 22),
      );
      expect(
        (committed as Success<VehicleDetail, VehicleDetailFailure>)
            .value
            .registrationNumber,
        'BB-001',
      );
      releaseTransaction.complete();
      await write;
      final updated = await repository.getVehicleDetail(
        vehicleId: 'vehicle-1',
        asOfUtc: DateTime.utc(2026, 8, 22),
      );
      expect(
        (updated as Success<VehicleDetail, VehicleDetailFailure>)
            .value
            .registrationNumber,
        'BB-UPDATED',
      );

      await database.close();
      if (await file.exists()) await file.delete();
    },
  );

  testWidgets(
    'given_an_android_app_database_when_reopened_then_retains_a_durable_write',
    (tester) async {
      const pathProvider = ApplicationSupportDatabasePathProvider(
        fileName: 'milestone_2_integration_probe.duckdb',
      );
      final clock = _FixedClock(DateTime.utc(2026, 8, 21));
      const migrations = [
        DatabaseMigration(
          version: 1,
          name: 'create schema migrations',
          sql: _schemaSql,
        ),
      ];
      final databasePath = await pathProvider.databasePath();
      final databaseFile = File(databasePath);
      if (await databaseFile.exists()) {
        await databaseFile.delete();
      }

      final database = await DuckDbAppDatabase.open(
        path: databasePath,
        migrations: migrations,
        clock: clock,
      );
      await database.execute(
        'CREATE TABLE database_probe (value VARCHAR NOT NULL)',
      );
      await database.execute(
        'INSERT INTO database_probe (value) VALUES (?)',
        parameters: ['retained on Android'],
      );

      await database.close();
      final reopenedDatabase = await DuckDbAppDatabase.open(
        path: databasePath,
        migrations: migrations,
        clock: clock,
      );

      expect(await reopenedDatabase.query('SELECT value FROM database_probe'), [
        ['retained on Android'],
      ]);

      await reopenedDatabase.close();
      if (await databaseFile.exists()) {
        await databaseFile.delete();
      }
    },
  );

  testWidgets(
    'given_invalid_telemetry_when_reopened_then_diagnostics_persist',
    (tester) async {
      const provider = ApplicationSupportDatabasePathProvider(
        fileName: 'milestone_3_probe.duckdb',
      );
      final path = await provider.databasePath();
      final file = File(path);
      if (await file.exists()) await file.delete();
      final migrations = await const AssetDatabaseMigrationLoader().load();
      final database = await DuckDbAppDatabase.open(
        path: path,
        migrations: migrations,
        clock: _FixedClock(DateTime.utc(2026)),
      );
      await DuckDbTelemetryRepository(database).store(
        ClassifiedTelemetryPacket(
          packetId: 'invalid-1',
          vehicleId: 'vehicle-1',
          eventTimestampUtc: DateTime.utc(2026),
          clientReceivedAtUtc: DateTime.utc(2026),
          signalName: 'soc',
          rawValueJson: '{}',
          classification: TelemetryClassification.supportedInvalid,
          validationError: 'Signal value is invalid',
        ),
      );
      await database.close();
      final reopened = await DuckDbAppDatabase.open(
        path: path,
        migrations: migrations,
        clock: _FixedClock(DateTime.utc(2026)),
      );
      final result = await DuckDbTelemetryRepository(reopened)
          .diagnosticsForVehicle('vehicle-1');
      expect(
        (result as Success<List<ClassifiedTelemetryPacket>, TelemetryFailure>)
            .value
            .single
            .validationError,
        'Signal value is invalid',
      );
      await reopened.close();
      if (await file.exists()) await file.delete();
    },
  );

  testWidgets(
    'given_committed_sse_delivery_when_reopened_then_packet_and_cursor_persist',
    (tester) async {
      const provider = ApplicationSupportDatabasePathProvider(
        fileName: 'milestone_5_sync_probe.duckdb',
      );
      final path = await provider.databasePath();
      final file = File(path);
      if (await file.exists()) await file.delete();
      final migrations = await const AssetDatabaseMigrationLoader().load();
      final database = await DuckDbAppDatabase.open(
        path: path,
        migrations: migrations,
        clock: _FixedClock(DateTime.utc(2026)),
      );
      final store = DuckDbSyncStore(
        database: database,
        classifier: TelemetryPacketClassifier(
          clock: _FixedClock(DateTime.utc(2026)),
        ),
      );
      await database.execute(
        'INSERT INTO vehicles (vehicle_id, registration_number, model) VALUES (?, ?, ?)',
        parameters: ['vehicle-1', 'BB-001', 'E-Truck'],
      );
      await store.ingestDelivery(
        SyncDeliveryDto(
          deliveryId: '100',
          packet: api.TelemetryPacket(
            packetId: 'packet-1',
            vehicleId: 'vehicle-1',
            eventTimestamp: DateTime.utc(2026),
            signalName: 'soc',
            value: api.SignalValue(
              kind: api.SignalValueKindEnum.number,
              numberValue: 80,
            ),
          ),
        ),
      );
      await store.ingestDelivery(
        SyncDeliveryDto(
          deliveryId: '101',
          packet: api.TelemetryPacket(
            packetId: 'packet-1',
            vehicleId: 'vehicle-1',
            eventTimestamp: DateTime.utc(2026),
            signalName: 'soc',
            value: api.SignalValue(
              kind: api.SignalValueKindEnum.number,
              numberValue: 80,
            ),
          ),
        ),
      );
      await database.close();

      final reopened = await DuckDbAppDatabase.open(
        path: path,
        migrations: migrations,
        clock: _FixedClock(DateTime.utc(2026)),
      );
      final reopenedStore = DuckDbSyncStore(
        database: reopened,
        classifier: TelemetryPacketClassifier(
          clock: _FixedClock(DateTime.utc(2026)),
        ),
      );
      expect(await reopenedStore.deliveryCursor(), '101');
      expect(
        await reopened.query(
          'SELECT packet_id FROM telemetry_events WHERE packet_id = ?',
          parameters: ['packet-1'],
        ),
        [
          ['packet-1'],
        ],
      );
      expect(
        await reopened.query(
          'SELECT COUNT(*) FROM telemetry_events WHERE packet_id = ?',
          parameters: ['packet-1'],
        ),
        [
          [1],
        ],
      );
      await reopened.close();
      if (await file.exists()) await file.delete();
    },
  );

  testWidgets(
    'given_two_inside_locations_when_reopened_then_retains_geofence_membership',
    (tester) async {
      const provider = ApplicationSupportDatabasePathProvider(
        fileName: 'geofence_membership_probe.duckdb',
      );
      final path = await provider.databasePath();
      final file = File(path);
      if (await file.exists()) await file.delete();
      final database = await DuckDbAppDatabase.open(
        path: path,
        migrations: await const AssetDatabaseMigrationLoader().load(),
        clock: _FixedClock(DateTime.utc(2026, 8, 22, 12)),
      );
      await database.execute(
        'INSERT INTO vehicles (vehicle_id, registration_number, model) VALUES (?, ?, ?)',
        parameters: ['vehicle-1', 'BB-001', 'E-Truck'],
      );
      await database.execute(
        'INSERT INTO geofences (geofence_id, created_at_utc) VALUES (?, ?)',
        parameters: ['demo-hub', '2026-01-01T00:00:00.000Z'],
      );
      await database.execute(
        'INSERT INTO geofence_versions (geofence_id, version, display_name, latitude, longitude, radius_meters, is_active, effective_from_utc) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        parameters: [
          'demo-hub',
          1,
          'Demo Hub',
          12.9,
          77.6,
          1000,
          true,
          '2026-01-01T00:00:00.000Z',
        ],
      );
      final store = DuckDbSyncStore(
        database: database,
        classifier: TelemetryPacketClassifier(
          clock: _FixedClock(DateTime.utc(2026, 8, 22, 12)),
        ),
        geofenceProjector: const DuckDbGeofenceProjector(),
      );
      await store.ingestDeliveries([
        _locationDelivery('1', 'location-1', DateTime.utc(2026, 8, 22, 11, 58)),
        _locationDelivery('2', 'location-2', DateTime.utc(2026, 8, 22, 11, 59)),
      ]);
      await database.close();
      final reopened = await DuckDbAppDatabase.open(
        path: path,
        migrations: await const AssetDatabaseMigrationLoader().load(),
        clock: _FixedClock(DateTime.utc(2026, 8, 22, 12)),
      );
      expect(
        await reopened.query(
          'SELECT geofence_id FROM vehicle_geofence_memberships WHERE vehicle_id = ?',
          parameters: ['vehicle-1'],
        ),
        [
          ['demo-hub'],
        ],
      );
      await reopened.close();
      if (await file.exists()) await file.delete();
    },
  );
}

SyncDeliveryDto _locationDelivery(
  String deliveryId,
  String packetId,
  DateTime timestamp,
) => SyncDeliveryDto(
  deliveryId: deliveryId,
  packet: api.TelemetryPacket(
    packetId: packetId,
    vehicleId: 'vehicle-1',
    eventTimestamp: timestamp,
    signalName: 'location',
    value: api.SignalValue(
      kind: api.SignalValueKindEnum.location,
      locationValue: api.LocationValue(
        latitude: 12.9,
        longitude: 77.6,
        accuracyMeters: 10,
      ),
    ),
  ),
);

final class _FixedClock implements Clock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime nowUtc() => value;
}

const _schemaSql = '''
CREATE TABLE IF NOT EXISTS schema_migrations (
  version INTEGER PRIMARY KEY,
  name VARCHAR NOT NULL,
  applied_at_utc TIMESTAMPTZ NOT NULL
)
''';
