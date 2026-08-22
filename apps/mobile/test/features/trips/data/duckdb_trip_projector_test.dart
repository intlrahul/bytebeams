import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/features/trips/data/duckdb_trip_projector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'given_exit_then_entry_when_rebuilt_then_writes_completed_trip',
    () async {
      final database = _Database([_exit, _entry]);
      await const DuckDbTripProjector().rebuild(database, ['vehicle-1']);
      final insert = database.executed.singleWhere(
        (item) => item.$1.startsWith('INSERT INTO trips'),
      );
      expect(insert.$2[0], 'vehicle-1:exit-1');
      expect(insert.$2[10], 'completed');
    },
  );
  test(
    'given_exit_without_entry_when_rebuilt_then_writes_one_active_trip',
    () async {
      final database = _Database([_exit]);
      await const DuckDbTripProjector().rebuild(database, ['vehicle-1']);
      expect(
        database.executed
            .singleWhere((item) => item.$1.startsWith('INSERT INTO trips'))
            .$2[10],
        'inProgress',
      );
    },
  );
  test(
    'given_extra_exit_when_active_when_rebuilt_then_keeps_one_trip',
    () async {
      final database = _Database([_exit, _exit2]);
      await const DuckDbTripProjector().rebuild(database, ['vehicle-1']);
      expect(
        database.executed.where(
          (item) => item.$1.startsWith('INSERT INTO trips'),
        ),
        hasLength(1),
      );
    },
  );
  test('given_reordered_history_when_rebuilt_then_sorts_event_time_deterministically', () async {
    final database = _Database([_entry, _exit]);

    await const DuckDbTripProjector().rebuild(database, ['vehicle-1']);

    expect(
      database.executed
          .singleWhere((item) => item.$1.startsWith('INSERT INTO trips'))
          .$2[10],
      'completed',
    );
  });
  test('given_duplicate_replay_when_rebuilt_twice_then_replaces_one_deterministic_trip', () async {
    final database = _Database([_exit, _entry]);

    await const DuckDbTripProjector().rebuild(database, ['vehicle-1']);
    await const DuckDbTripProjector().rebuild(database, ['vehicle-1']);

    final inserts = database.executed
        .where((item) => item.$1.startsWith('INSERT INTO trips'))
        .toList();
    expect(inserts, hasLength(2));
    expect(inserts.first.$2[0], inserts.last.$2[0]);
  });
}

final _exit = [
  'exit-1',
  'vehicle-1',
  'a',
  1,
  DateTime.utc(2026, 1, 1),
  'exit',
  'p1',
];
final _exit2 = [
  'exit-2',
  'vehicle-1',
  'b',
  1,
  DateTime.utc(2026, 1, 2),
  'exit',
  'p2',
];
final _entry = [
  'entry-1',
  'vehicle-1',
  'b',
  1,
  DateTime.utc(2026, 1, 2),
  'entry',
  'p2',
];

final class _Database implements AppDatabase {
  _Database(this.rows);
  final List<List<Object?>> rows;
  final executed = <(String, List<Object?>)>[];
  @override
  Future<void> close() async {}
  @override
  Future<int> currentSchemaVersion() async => 6;
  @override
  Future<void> execute(
    String sql, {
    List<Object?> parameters = const [],
  }) async => executed.add((sql, parameters));
  @override
  Future<T> transaction<T>(
    Future<T> Function(DatabaseTransaction transaction) action,
  ) => action(this);
  @override
  Future<List<List<Object?>>> query(
    String sql, {
    List<Object?> parameters = const [],
  }) async => [...rows]
    ..sort((left, right) {
      final time = (left[4]! as DateTime).compareTo(right[4]! as DateTime);
      if (time != 0) return time;
      return (left[5] == 'exit' ? 0 : 1).compareTo(right[5] == 'exit' ? 0 : 1);
    });
}
