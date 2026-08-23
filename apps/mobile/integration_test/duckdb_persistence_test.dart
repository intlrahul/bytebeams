import 'dart:async';
import 'dart:io';

import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/core/data/database/database_migration.dart';
import 'package:bytebeams/core/data/database/database_failure.dart';
import 'package:bytebeams/core/data/database/database_migration_loader.dart';
import 'package:bytebeams/core/data/database/database_path_provider.dart';
import 'package:bytebeams/core/data/database/duckdb_app_database.dart';
import 'package:bytebeams/core/time/clock.dart';
import 'package:bytebeams/features/geofences/data/duckdb_geofence_projector.dart';
import 'package:bytebeams/features/alerts/data/duckdb_alert_projector.dart';
import 'package:bytebeams/features/sync/data/projection_rebuild_service.dart';
import 'package:bytebeams/features/sync/data/retention_cleanup.dart';
import 'package:bytebeams/features/trips/data/duckdb_trip_projector.dart';
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

import '../test/support/retention_seed_factory.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'given_schema_six_when_reopened_with_schema_seven_then_adds_replay_checkpoints',
    (tester) async {
      const provider = ApplicationSupportDatabasePathProvider(
        fileName: 'milestone_11_migration_probe.duckdb',
      );
      final path = await provider.databasePath();
      final file = File(path);
      if (await file.exists()) await file.delete();
      final migrations = await const AssetDatabaseMigrationLoader().load();
      final versionSix = await DuckDbAppDatabase.open(
        path: path,
        migrations: migrations
            .where((migration) => migration.version <= 6)
            .toList(),
        clock: _FixedClock(DateTime.utc(2026)),
      );
      await versionSix.close();

      final upgraded = await DuckDbAppDatabase.open(
        path: path,
        migrations: migrations,
        clock: _FixedClock(DateTime.utc(2026)),
      );
      expect(await upgraded.currentSchemaVersion(), 7);
      expect(
        await upgraded.query(
          'SELECT COUNT(*) FROM geofence_replay_checkpoints',
        ),
        [
          [0],
        ],
      );
      await upgraded.close();
      if (await file.exists()) await file.delete();
    },
  );

  testWidgets(
    'given_retention_boundaries_when_cleanup_reopens_then_keeps_boundary_and_derived_history',
    (tester) async {
      const provider = ApplicationSupportDatabasePathProvider(
        fileName: 'milestone_11_retention_probe.duckdb',
      );
      final path = await provider.databasePath();
      final file = File(path);
      if (await file.exists()) await file.delete();
      final migrations = await const AssetDatabaseMigrationLoader().load();
      final now = DateTime.utc(2026, 8, 22, 12);
      final cutoff = now.subtract(const Duration(days: 30));
      final database = await DuckDbAppDatabase.open(
        path: path,
        migrations: migrations,
        clock: _FixedClock(now),
      );
      for (final row in [
        ['valid-boundary', 'supportedValid', cutoff, cutoff],
        [
          'invalid-expired',
          'supportedInvalid',
          cutoff.subtract(const Duration(seconds: 1)),
          now,
        ],
        [
          'unsupported-expired',
          'unsupported',
          cutoff.subtract(const Duration(seconds: 1)),
          now,
        ],
        [
          'quarantine-boundary',
          'quarantined',
          cutoff.subtract(const Duration(days: 1)),
          cutoff,
        ],
        [
          'quarantine-expired',
          'quarantined',
          cutoff.subtract(const Duration(days: 1)),
          cutoff.subtract(const Duration(seconds: 1)),
        ],
      ]) {
        await database.execute(
          'INSERT INTO telemetry_events (packet_id, vehicle_id, event_timestamp_utc, client_received_at_utc, signal_name, classification, raw_value_json) VALUES (?, ?, ?, ?, ?, ?, ?)',
          parameters: [
            row[0],
            'vehicle-1',
            (row[2] as DateTime).toIso8601String(),
            (row[3] as DateTime).toIso8601String(),
            'soc',
            row[1],
            '{}',
          ],
        );
      }
      await database.execute(
        'INSERT INTO geofence_transitions (transition_id, vehicle_id, geofence_id, geofence_version, transition_type, event_timestamp_utc, packet_id) VALUES (?, ?, ?, ?, ?, ?, ?)',
        parameters: [
          'historical-transition',
          'vehicle-1',
          'site-a',
          1,
          'exit',
          cutoff.subtract(const Duration(days: 1)).toIso8601String(),
          'expired-location',
        ],
      );
      await database.transaction<void>(
        (transaction) =>
            DuckDbRetentionCleanup(clock: _FixedClock(now))
                .runIfDue(transaction),
      );
      await database.close();

      final reopened = await DuckDbAppDatabase.open(
        path: path,
        migrations: migrations,
        clock: _FixedClock(now),
      );
      expect(
        await reopened.query(
          'SELECT packet_id FROM telemetry_events ORDER BY packet_id',
        ),
        [
          ['quarantine-boundary'],
          ['valid-boundary'],
        ],
      );
      expect(
        await reopened.query('SELECT transition_id FROM geofence_transitions'),
        [
          ['historical-transition'],
        ],
      );
      await reopened.close();
      if (await file.exists()) await file.delete();
    },
  );

  testWidgets(
    'given_test_failure_before_commit_when_retention_runs_then_rolls_back_packet_marker_and_cursor',
    (tester) async {
      const provider = ApplicationSupportDatabasePathProvider(
        fileName: 'milestone_11_rollback_probe.duckdb',
      );
      final path = await provider.databasePath();
      final file = File(path);
      if (await file.exists()) await file.delete();
      final database = await DuckDbAppDatabase.open(
        path: path,
        migrations: await const AssetDatabaseMigrationLoader().load(),
        clock: _FixedClock(DateTime.utc(2026)),
      );
      await expectLater(
        database.transaction<void>((transaction) async {
          await transaction.execute(
            "INSERT INTO sync_state (key, value) VALUES ('delivery_cursor', 'new')",
          );
          await const _FailingRetentionCleanup().runIfDue(transaction);
        }),
        throwsA(isA<DatabaseOperationFailure>()),
      );
      expect(
        await database.query(
          "SELECT value FROM sync_state WHERE key = 'delivery_cursor'",
        ),
        isEmpty,
      );
      await database.close();
      if (await file.exists()) await file.delete();
    },
  );

  testWidgets(
    'given_late_duplicate_locations_across_cleanup_when_rebuilt_then_transitions_and_trip_are_stable',
    (tester) async {
      const provider = ApplicationSupportDatabasePathProvider(
        fileName: 'milestone_11_replay_probe.duckdb',
      );
      final path = await provider.databasePath();
      final file = File(path);
      if (await file.exists()) await file.delete();
      final now = DateTime.utc(2026, 8, 22, 12);
      final cutoff = now.subtract(const Duration(days: 30));
      final database = await DuckDbAppDatabase.open(
        path: path,
        migrations: await const AssetDatabaseMigrationLoader().load(),
        clock: _FixedClock(now),
      );
      await database.execute(
        'INSERT INTO vehicles VALUES (?, ?, ?)',
        parameters: ['vehicle-1', 'RT-001', 'Retention Truck'],
      );
      await database.execute(
        'INSERT INTO geofences VALUES (?, ?)',
        parameters: ['site-a', DateTime.utc(2026)],
      );
      await database.execute(
        'INSERT INTO geofence_versions VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        parameters: [
          'site-a',
          1,
          'Test Site',
          12.9,
          77.6,
          1000.0,
          true,
          DateTime.utc(2026),
          null,
        ],
      );
      Future<void> location(String id, DateTime at, double longitude) =>
          database.execute(
            'INSERT INTO telemetry_events (packet_id, vehicle_id, event_timestamp_utc, client_received_at_utc, signal_name, classification, raw_value_json, latitude, longitude, accuracy_meters) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            parameters: [
              id,
              'vehicle-1',
              at,
              now,
              'location',
              'supportedValid',
              '{}',
              12.9,
              longitude,
              10.0,
            ],
          );
      await location(
        'old-in-1',
        cutoff.subtract(const Duration(days: 2)),
        77.6,
      );
      await location(
        'old-in-2',
        cutoff.subtract(const Duration(days: 2, minutes: -1)),
        77.6,
      );
      await location(
        'old-out-1',
        cutoff.subtract(const Duration(days: 1)),
        77.7,
      );
      await location(
        'old-out-2',
        cutoff.subtract(const Duration(days: 1, minutes: -1)),
        77.7,
      );
      await location('recent-in-1', cutoff.add(const Duration(hours: 1)), 77.6);
      await location(
        'recent-in-2',
        cutoff.add(const Duration(hours: 1, minutes: 1)),
        77.6,
      );
      await database.transaction<void>((transaction) async {
        await const DuckDbGeofenceProjector().rebuild(transaction, [
          'vehicle-1',
        ]);
        await const DuckDbTripProjector().rebuild(transaction, ['vehicle-1']);
      });
      final transitionsBefore = await database.query(
        'SELECT transition_id FROM geofence_transitions ORDER BY transition_id',
      );
      final tripsBefore = await database.query(
        'SELECT trip_id, status FROM trips ORDER BY trip_id',
      );
      await database.transaction<void>(
        (transaction) =>
            DuckDbRetentionCleanup(clock: _FixedClock(now))
                .runIfDue(transaction),
      );
      await location(
        'late-outside',
        cutoff.add(const Duration(minutes: 30)),
        77.7,
      );
      await database.transaction<void>((transaction) async {
        await const DuckDbGeofenceProjector().rebuild(transaction, [
          'vehicle-1',
        ]);
        await const DuckDbTripProjector().rebuild(transaction, ['vehicle-1']);
      });

      expect(
        await database.query(
          'SELECT transition_id FROM geofence_transitions ORDER BY transition_id',
        ),
        transitionsBefore,
      );
      expect(
        await database.query(
          'SELECT trip_id, status FROM trips ORDER BY trip_id',
        ),
        tripsBefore,
      );
      await database.close();
      if (await file.exists()) await file.delete();
    },
  );

  testWidgets(
    'given_representative_backlog_when_cleaned_and_rebuilt_then_meets_android_budgets',
    (tester) async {
      const provider = ApplicationSupportDatabasePathProvider(
        fileName: 'milestone_11_performance_probe.duckdb',
      );
      final path = await provider.databasePath();
      final file = File(path);
      if (await file.exists()) await file.delete();
      final now = DateTime.utc(2026, 8, 22, 12);
      final database = await DuckDbAppDatabase.open(
        path: path,
        migrations: await const AssetDatabaseMigrationLoader().load(),
        clock: _FixedClock(now),
      );
      final deliveries = RetentionSeedFactory.deliveries(
        startUtc: now.subtract(const Duration(days: 31)),
      );
      await DuckDbSyncStore(
        database: database,
        classifier: TelemetryPacketClassifier(clock: _FixedClock(now)),
      ).importBootstrap(
        SyncBootstrapDto(
          vehicles: RetentionSeedFactory.vehicles(),
          telemetry: deliveries.map((delivery) => delivery.packet).toList(),
          deliveryCursor: '10000',
        ),
        origin: 'performance',
      );
      await database.execute(
        "UPDATE telemetry_events SET classification = 'supportedValid'",
      );
      await database.execute('CHECKPOINT');
      final bytesBefore = await file.length();
      final cleanupWatch = Stopwatch()..start();
      await database.transaction<void>(
        (transaction) =>
            DuckDbRetentionCleanup(clock: _FixedClock(now))
                .runIfDue(transaction),
      );
      cleanupWatch.stop();
      final rebuildWatch = Stopwatch()..start();
      await database.transaction<void>(
        (transaction) =>
            DuckDbProjectionRebuildService(
              alertProjector: DuckDbAlertProjector(clock: _FixedClock(now)),
              geofenceProjector: const DuckDbGeofenceProjector(),
              tripProjector: const DuckDbTripProjector(),
            ).rebuild(
              transaction,
              RetentionSeedFactory.vehicles().map(
                (vehicle) => vehicle.vehicleId,
              ),
            ),
      );
      rebuildWatch.stop();
      await database.execute('CHECKPOINT');
      final bytesAfter = await file.length();
      // Aggregate measurements contain no telemetry payloads.
      // ignore: avoid_print
      print(
        'M11 cleanup_ms=${cleanupWatch.elapsedMilliseconds} rebuild_ms=${rebuildWatch.elapsedMilliseconds} db_before=$bytesBefore db_after=$bytesAfter',
      );
      expect(cleanupWatch.elapsed, lessThan(const Duration(seconds: 3)));
      expect(rebuildWatch.elapsed, lessThan(const Duration(seconds: 5)));
      await database.close();
      if (await file.exists()) await file.delete();
    },
  );

  testWidgets(
    'given_confirmed_exit_and_entry_when_reopened_then_retains_one_completed_trip',
    (tester) async {
      const provider = ApplicationSupportDatabasePathProvider(
        fileName: 'milestone_10_trip_projection_probe.duckdb',
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
      await database.execute(
        'INSERT INTO geofence_transitions (transition_id, vehicle_id, geofence_id, geofence_version, transition_type, event_timestamp_utc, packet_id) VALUES (?, ?, ?, ?, ?, ?, ?)',
        parameters: [
          'exit-a',
          'vehicle-1',
          'site-a',
          1,
          'exit',
          DateTime.utc(2026, 1, 1),
          'packet-exit',
        ],
      );
      await database.execute(
        'INSERT INTO geofence_transitions (transition_id, vehicle_id, geofence_id, geofence_version, transition_type, event_timestamp_utc, packet_id) VALUES (?, ?, ?, ?, ?, ?, ?)',
        parameters: [
          'entry-b',
          'vehicle-1',
          'site-b',
          1,
          'entry',
          DateTime.utc(2026, 1, 1, 1),
          'packet-entry',
        ],
      );
      await database.transaction<void>(
        (transaction) =>
            const DuckDbTripProjector().rebuild(transaction, ['vehicle-1']),
      );
      await database.close();

      final reopened = await DuckDbAppDatabase.open(
        path: path,
        migrations: migrations,
        clock: _FixedClock(DateTime.utc(2026)),
      );
      expect(
        await reopened.query(
          'SELECT trip_id, status, destination_geofence_id FROM trips',
        ),
        [
          ['vehicle-1:exit-a', 'completed', 'site-b'],
        ],
      );
      await reopened.close();
      if (await file.exists()) await file.delete();
    },
  );

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
    'given_live_inside_and_outside_locations_when_reopened_then_updates_membership',
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
      final reopenedStore = DuckDbSyncStore(
        database: reopened,
        classifier: TelemetryPacketClassifier(
          clock: _FixedClock(DateTime.utc(2026, 8, 22, 12)),
        ),
        geofenceProjector: const DuckDbGeofenceProjector(),
      );
      await reopenedStore.ingestDeliveries([
        _locationDelivery(
          '3',
          'location-3',
          DateTime.utc(2026, 8, 22, 11, 59, 10),
          longitude: 77.62,
        ),
        _locationDelivery(
          '4',
          'location-4',
          DateTime.utc(2026, 8, 22, 11, 59, 20),
          longitude: 77.62,
        ),
        _numberDelivery(
          '5',
          'speed-5',
          DateTime.utc(2026, 8, 22, 11, 59, 30),
          signalName: 'speed',
          value: 32,
        ),
        _numberDelivery(
          '6',
          'soc-6',
          DateTime.utc(2026, 8, 22, 11, 59, 30),
          signalName: 'soc',
          value: 81.8,
        ),
        _numberDelivery(
          '7',
          'range-7',
          DateTime.utc(2026, 8, 22, 11, 59, 30),
          signalName: 'range',
          value: 245.4,
        ),
      ]);
      expect(
        await reopened.query(
          'SELECT geofence_id FROM vehicle_geofence_memberships WHERE vehicle_id = ?',
          parameters: ['vehicle-1'],
        ),
        [
          [null],
        ],
      );
      final detailResult = await DuckDbVehicleDetailRepository(reopened)
          .getVehicleDetail(
            vehicleId: 'vehicle-1',
            asOfUtc: DateTime.utc(2026, 8, 22, 12),
          );
      final detail = switch (detailResult) {
        Success<VehicleDetail, VehicleDetailFailure>(value: final value) =>
          value,
        _ => throw StateError('Expected persisted vehicle detail'),
      };
      final readings = {
        for (final reading in detail.readings) reading.signal: reading,
      };
      expect(readings[VehicleReadingSignal.speed]?.value, 32);
      expect(readings[VehicleReadingSignal.soc]?.value, 81.8);
      expect(readings[VehicleReadingSignal.range]?.value, 245.4);
      expect(
        readings[VehicleReadingSignal.soc]?.reportedAtUtc,
        DateTime.utc(2026, 8, 22, 11, 59, 30),
      );
      await reopened.close();
      if (await file.exists()) await file.delete();
    },
  );
}

SyncDeliveryDto _locationDelivery(
  String deliveryId,
  String packetId,
  DateTime timestamp, {
  double latitude = 12.9,
  double longitude = 77.6,
}) => SyncDeliveryDto(
  deliveryId: deliveryId,
  packet: api.TelemetryPacket(
    packetId: packetId,
    vehicleId: 'vehicle-1',
    eventTimestamp: timestamp,
    signalName: 'location',
    value: api.SignalValue(
      kind: api.SignalValueKindEnum.location,
      locationValue: api.LocationValue(
        latitude: latitude,
        longitude: longitude,
        accuracyMeters: 10,
      ),
    ),
  ),
);

SyncDeliveryDto _numberDelivery(
  String deliveryId,
  String packetId,
  DateTime timestamp, {
  required String signalName,
  required double value,
}) => SyncDeliveryDto(
  deliveryId: deliveryId,
  packet: api.TelemetryPacket(
    packetId: packetId,
    vehicleId: 'vehicle-1',
    eventTimestamp: timestamp,
    signalName: signalName,
    value: api.SignalValue(
      kind: api.SignalValueKindEnum.number,
      numberValue: value,
    ),
  ),
);

final class _FixedClock implements Clock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime nowUtc() => value;
}

final class _FailingRetentionCleanup implements RetentionCleanup {
  const _FailingRetentionCleanup();

  @override
  Future<void> runIfDue(DatabaseTransaction database) async {
    await database.execute(
      "INSERT INTO sync_state (key, value) VALUES ('retention_cleanup_utc_day', '2026-01-01')",
    );
    throw StateError('Injected retention failure');
  }
}

const _schemaSql = '''
CREATE TABLE IF NOT EXISTS schema_migrations (
  version INTEGER PRIMARY KEY,
  name VARCHAR NOT NULL,
  applied_at_utc TIMESTAMPTZ NOT NULL
)
''';
