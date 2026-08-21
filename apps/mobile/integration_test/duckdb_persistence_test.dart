import 'dart:io';

import 'package:bytebeams/core/data/database/database_migration.dart';
import 'package:bytebeams/core/data/database/database_migration_loader.dart';
import 'package:bytebeams/core/data/database/database_path_provider.dart';
import 'package:bytebeams/core/data/database/duckdb_app_database.dart';
import 'package:bytebeams/core/time/clock.dart';
import 'package:bytebeams/features/telemetry/data/duckdb_telemetry_repository.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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
}

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
