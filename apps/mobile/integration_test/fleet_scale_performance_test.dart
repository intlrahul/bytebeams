import 'dart:async';
import 'dart:io';

import 'package:bytebeams/app_dependencies.dart';
import 'package:bytebeams/app_runtime.dart';
import 'package:bytebeams/core/data/database/database_migration_loader.dart';
import 'package:bytebeams/core/data/database/database_path_provider.dart';
import 'package:bytebeams/core/data/database/duckdb_app_database.dart';
import 'package:bytebeams/core/time/clock.dart';
import 'package:bytebeams/features/fleet_home/data/duckdb_fleet_home_repository.dart';
import 'package:bytebeams/features/fleet_home/domain/fleet_home_models.dart';
import 'package:bytebeams/features/sync/domain/app_event_bus.dart';
import 'package:bytebeams/features/sync/domain/sync_models.dart';
import 'package:bytebeams/features/sync/domain/sync_repository.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:bytebeams/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const _vehicleCount = 500;
const _signalRowCount = 2000000;
const _warmupQueryCount = 10;
const _measuredQueryCount = 100;
const _memoryHoldSeconds = int.fromEnvironment('PERF_MEMORY_HOLD_SECONDS');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'given_two_million_signals_when_fleet_opens_then_reports_scale_measurements',
    (tester) async {
      // Given
      const provider = ApplicationSupportDatabasePathProvider(
        fileName: 'fleet_scale_performance.duckdb',
      );
      final path = await provider.databasePath();
      final file = File(path);
      if (await file.exists()) await file.delete();
      DuckDbAppDatabase? database;
      AsyncAppEventBus? eventBus;
      addTearDown(() async {
        await eventBus?.close();
        await database?.close();
        if (await file.exists()) await file.delete();
      });

      final measuredAtUtc = DateTime.now().toUtc();
      database = await DuckDbAppDatabase.open(
        path: path,
        migrations: await const AssetDatabaseMigrationLoader().load(),
        clock: _FixedClock(measuredAtUtc),
      );
      final seedWatch = Stopwatch()..start();
      await _seedScaleData(database, measuredAtUtc);
      await database.execute('CHECKPOINT');
      seedWatch.stop();
      expect(await database.query('SELECT COUNT(*) FROM vehicles'), [
        [_vehicleCount],
      ]);
      expect(await database.query('SELECT COUNT(*) FROM telemetry_events'), [
        [_signalRowCount],
      ]);
      final databaseBytes = await file.length();
      await database.close();
      database = null;

      // When: measure the in-app portion of a cold start, from opening the
      // existing DuckDB file through the first populated Fleet Home frame.
      final firstPaintWatch = Stopwatch()..start();
      database = await DuckDbAppDatabase.open(
        path: path,
        migrations: await const AssetDatabaseMigrationLoader().load(),
        clock: _FixedClock(measuredAtUtc),
      );
      eventBus = AsyncAppEventBus();
      final runtime = AppRuntime.forTesting(
        database: database,
        syncRepository: const _IdleSyncRepository(),
        eventBus: eventBus,
      );
      await tester.pumpWidget(
        ByteBeamsApp(dependencies: AppDependencies(runtime)),
      );
      await _pumpUntilFound(tester, find.text('RT-000'));
      firstPaintWatch.stop();

      final repository = DuckDbFleetHomeRepository(database);
      for (var index = 0; index < _warmupQueryCount; index += 1) {
        final result = await repository.getFleet(
          filter: FleetFilter.all,
          asOfUtc: measuredAtUtc,
        );
        _expectCompleteFleet(result);
      }
      final samplesMicros = <int>[];
      for (var index = 0; index < _measuredQueryCount; index += 1) {
        final watch = Stopwatch()..start();
        final result = await repository.getFleet(
          filter: FleetFilter.all,
          asOfUtc: measuredAtUtc,
        );
        watch.stop();
        _expectCompleteFleet(result);
        samplesMicros.add(watch.elapsedMicroseconds);
      }
      samplesMicros.sort();
      final p50Micros = _nearestRank(samplesMicros, 50);
      final p95Micros = _nearestRank(samplesMicros, 95);

      // Then: print aggregate diagnostics only; never emit telemetry values.
      // ignore: avoid_print
      print(
        'FLEET_SCALE vehicles=$_vehicleCount signals=$_signalRowCount '
        'seed_ms=${seedWatch.elapsedMilliseconds} db_bytes=$databaseBytes '
        'first_painted_ms=${firstPaintWatch.elapsedMilliseconds} '
        'warm_samples=$_measuredQueryCount '
        'query_p50_us=$p50Micros query_p95_us=$p95Micros',
      );
      expect(p95Micros, greaterThanOrEqualTo(p50Micros));
      if (_memoryHoldSeconds > 0) {
        // The host performance runner watches for this aggregate-only marker
        // and samples Android process memory while the populated list is idle.
        // ignore: avoid_print
        print('FLEET_SCALE_MEMORY_READY');
        await Future<void>.delayed(Duration(seconds: _memoryHoldSeconds));
      }
    },
    timeout: Timeout.none,
  );
}

Future<void> _seedScaleData(
  DuckDbAppDatabase database,
  DateTime measuredAtUtc,
) async {
  await database.transaction<void>((transaction) async {
    await transaction.execute('''
INSERT INTO vehicles
SELECT
  'scale-' || LPAD(CAST(vehicle_index AS VARCHAR), 3, '0'),
  'RT-' || LPAD(CAST(vehicle_index AS VARCHAR), 3, '0'),
  'Scale Test Truck'
FROM range($_vehicleCount) AS vehicles(vehicle_index)
''');
    await transaction.execute(
      '''
INSERT INTO telemetry_events (
  packet_id,
  vehicle_id,
  event_timestamp_utc,
  server_received_at_utc,
  client_received_at_utc,
  signal_name,
  classification,
  raw_value_json,
  number_value,
  boolean_value
)
SELECT
  'scale-packet-' || CAST(signal_index AS VARCHAR),
  'scale-' || LPAD(
    CAST(CAST(FLOOR(signal_index / 6) AS BIGINT) % $_vehicleCount AS VARCHAR),
    3,
    '0'
  ),
  CAST(? AS TIMESTAMPTZ) -
    CAST(FLOOR(signal_index / 3000) AS BIGINT) * INTERVAL 3888 SECOND,
  CAST(? AS TIMESTAMPTZ) -
    CAST(FLOOR(signal_index / 3000) AS BIGINT) * INTERVAL 3888 SECOND,
  CAST(? AS TIMESTAMPTZ),
  CASE signal_index % 6
    WHEN 0 THEN 'last_ping'
    WHEN 1 THEN 'speed'
    WHEN 2 THEN 'ignition'
    WHEN 3 THEN 'soc'
    WHEN 4 THEN 'range'
    ELSE 'battery_temp'
  END,
  'supportedValid',
  '{}',
  CASE signal_index % 6
    WHEN 1 THEN CAST(signal_index % 90 AS DOUBLE)
    WHEN 3 THEN CAST(20 + signal_index % 80 AS DOUBLE)
    WHEN 4 THEN CAST(40 + signal_index % 360 AS DOUBLE)
    WHEN 5 THEN CAST(20 + signal_index % 30 AS DOUBLE)
    ELSE NULL
  END,
  CASE WHEN signal_index % 6 = 2 THEN signal_index % 4 <> 0 ELSE NULL END
FROM range($_signalRowCount) AS signals(signal_index)
''',
      parameters: [measuredAtUtc, measuredAtUtc, measuredAtUtc],
    );
  });
}

void _expectCompleteFleet(FleetHomeResult result) {
  switch (result) {
    case Success<FleetHomeSnapshot, FleetHomeFailure>(value: final snapshot):
      expect(snapshot.rows, hasLength(_vehicleCount));
      expect(snapshot.counts.all, _vehicleCount);
    case Failure<FleetHomeSnapshot, FleetHomeFailure>():
      fail('The production Fleet Home query failed during the benchmark');
  }
}

int _nearestRank(List<int> sortedSamples, int percentile) {
  final rank = ((percentile * sortedSamples.length) + 99) ~/ 100;
  return sortedSamples[rank - 1];
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 300; attempt += 1) {
    await tester.pump(const Duration(milliseconds: 16));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('The populated Fleet Home list did not paint within 4.8 seconds');
}

final class _FixedClock implements Clock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime nowUtc() => value;
}

final class _IdleSyncRepository implements SyncRepository {
  const _IdleSyncRepository();

  @override
  SyncState get currentState => const SyncState.idle();

  @override
  Stream<SyncState> get states => const Stream.empty();

  @override
  Future<void> close() async {}

  @override
  Future<void> refreshFromServer() async {}

  @override
  Future<void> synchronize() async {}

  @override
  Future<void> useDemoData() async {}
}
