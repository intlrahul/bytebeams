import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/core/data/database/database_failure.dart';
import 'package:bytebeams/features/fleet_home/data/duckdb_fleet_home_repository.dart';
import 'package:bytebeams/features/fleet_home/domain/fleet_home_models.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final asOf = DateTime.utc(2026, 8, 22, 12);

  test('given_query_rows_when_fleet_read_then_maps_sql_snapshot', () async {
    final database = _Database(
      rows: [
        ['vehicle-1', 'BB-001', 'E-Truck', 78.0, 242.0, 'moving', 1],
      ],
      counts: const [1, 1, 0, 0, 0],
    );

    final result = await DuckDbFleetHomeRepository(database)
        .getFleet(filter: FleetFilter.all, asOfUtc: asOf);

    final snapshot =
        (result as Success<FleetHomeSnapshot, FleetHomeFailure>).value;
    expect(snapshot.rows.single.status, FleetStatus.moving);
    expect(snapshot.rows.single.soc, 78);
    expect(snapshot.rows.single.attentionCount, 1);
    expect(snapshot.counts.moving, 1);
    expect(database.parameters.first.first, '2026-08-22T11:50:00.000Z');
    expect(database.parameters.first.skip(3), [
      FleetFilter.all.name,
      FleetFilter.all.name,
    ]);
  });

  test(
    'given_selected_filter_when_fleet_read_then_passes_filter_to_sql',
    () async {
      final database = _Database();

      await DuckDbFleetHomeRepository(database)
          .getFleet(filter: FleetFilter.offline, asOfUtc: asOf);

      expect(database.parameters.first.skip(3), [
        FleetFilter.offline.name,
        FleetFilter.offline.name,
      ]);
    },
  );

  test(
    'given_database_failure_when_fleet_read_then_returns_safe_failure',
    () async {
      final result = await DuckDbFleetHomeRepository(_Database(fails: true))
          .getFleet(filter: FleetFilter.all, asOfUtc: asOf);

      expect(result, isA<Failure<FleetHomeSnapshot, FleetHomeFailure>>());
    },
  );
}

final class _Database implements AppDatabase {
  _Database({
    this.rows = const [],
    this.counts = const [0, 0, 0, 0, 0],
    this.fails = false,
  });

  final List<List<Object?>> rows;
  final List<Object?> counts;
  final bool fails;
  final List<List<Object?>> parameters = [];

  @override
  Future<void> close() async {}

  @override
  Future<int> currentSchemaVersion() async => 2;

  @override
  Future<void> execute(
    String sql, {
    List<Object?> parameters = const [],
  }) async {}

  @override
  Future<List<List<Object?>>> query(
    String sql, {
    List<Object?> parameters = const [],
  }) async {
    if (fails) {
      throw const DatabaseOperationFailure(safeMessage: 'unavailable');
    }
    this.parameters.add(parameters);
    return sql.contains('all_count') ? [counts] : rows;
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(DatabaseTransaction transaction) action,
  ) => action(this);
}
