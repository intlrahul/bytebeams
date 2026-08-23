import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/core/time/clock.dart';
import 'package:bytebeams/features/sync/data/retention_cleanup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given_new_utc_day_when_cleanup_runs_then_deletes_by_correct_retention_clock', () async {
    final database = _Database();
    await DuckDbRetentionCleanup(clock: _Clock(DateTime.utc(2026, 2, 1)))
        .runIfDue(database);

    expect(database.executed, hasLength(5));
    expect(database.executed[0].$1, startsWith('DELETE FROM'));
    expect(database.executed[1].$1, contains('geofence_replay_checkpoints'));
    final cutoff = DateTime.utc(2026, 1, 2).millisecondsSinceEpoch;
    expect(database.executed[1].$2, [
      '2026-01-02T00:00:00.000Z',
      cutoff,
      cutoff,
    ]);
    expect(database.executed[2].$2, [cutoff]);
    expect(database.executed[3].$1, contains('client_received_at_utc'));
  });

  test(
    'given_cleanup_already_ran_today_when_requested_then_is_idempotent',
    () async {
      final database = _Database(
        rows: [
          ['2026-02-01'],
        ],
      );
      await DuckDbRetentionCleanup(clock: _Clock(DateTime.utc(2026, 2, 1)))
          .runIfDue(database);

      expect(database.executed, isEmpty);
    },
  );
}

final class _Clock implements Clock {
  const _Clock(this.now);
  final DateTime now;
  @override
  DateTime nowUtc() => now;
}

final class _Database implements AppDatabase {
  _Database({this.rows = const []});
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
  }) async => rows;
}
