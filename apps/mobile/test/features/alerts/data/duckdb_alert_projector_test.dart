import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/core/time/clock.dart';
import 'package:bytebeams/features/alerts/data/alert_queries.dart';
import 'package:bytebeams/features/alerts/data/duckdb_alert_projector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 8, 22, 12);
  test(
    'given_fresh_low_soc_when_rebuilt_then_creates_warning_episode',
    () async {
      final database = _Database(soc: [15, now, 'packet-1']);
      await _projector(now).rebuild(database, ['vehicle-1']);
      final insert = database.executions.singleWhere(
        (entry) => entry.$1 == AlertQueries.insertEpisode,
      );
      expect(insert.$2.sublist(0, 3), [
        'vehicle-1:lowBattery:packet-1',
        'vehicle-1',
        'lowBattery',
      ]);
      expect(insert.$2.last, 'warning');
    },
  );

  test(
    'given_fresh_clear_signal_when_episode_active_then_resolves_episode',
    () async {
      final database = _Database(
        soc: [20, now, 'packet-2'],
        active: [
          ['alert-1', 'vehicle-1', 'lowBattery', 'warning'],
        ],
      );
      await _projector(now).rebuild(database, ['vehicle-1']);
      expect(
        database.executions.map((entry) => entry.$1),
        contains(AlertQueries.resolveEpisode),
      );
    },
  );

  test(
    'given_stale_signals_when_rebuilt_then_leaves_episodes_unchanged',
    () async {
      final database = _Database(
        soc: [5, now.subtract(const Duration(minutes: 11)), 'packet-3'],
      );
      await _projector(now).rebuild(database, ['vehicle-1']);
      expect(database.executions, isEmpty);
    },
  );

  test(
    'given_warning_episode_when_soc_becomes_critical_then_escalates_once',
    () async {
      final database = _Database(
        soc: [9, now, 'packet-4'],
        active: const [
          ['alert-1', 'vehicle-1', 'lowBattery', 'warning'],
        ],
      );
      await _projector(now).rebuild(database, ['vehicle-1']);
      expect(
        database.executions.map((entry) => entry.$1),
        containsAll([
          AlertQueries.escalateEpisode,
          AlertQueries.insertLifecycle,
        ]),
      );
    },
  );

  test(
    'given_many_vehicles_when_rebuilt_then_uses_two_projection_reads',
    () async {
      final database = _Database(soc: [15, now, 'packet-5']);

      await _projector(now)
          .rebuild(database, List.generate(500, (index) => 'vehicle-$index'));

      expect(database.queries, hasLength(2));
    },
  );
}

DuckDbAlertProjector _projector(DateTime now) =>
    DuckDbAlertProjector(clock: _Clock(now));

final class _Clock implements Clock {
  const _Clock(this.value);
  final DateTime value;
  @override
  DateTime nowUtc() => value;
}

final class _Database implements AppDatabase {
  _Database({required this.soc, this.active = const []});
  final List<Object?> soc;
  final List<List<Object?>> active;
  final executions = <(String, List<Object?>)>[];
  final queries = <String>[];
  @override
  Future<void> close() async {}
  @override
  Future<int> currentSchemaVersion() async => 4;
  @override
  Future<void> execute(
    String sql, {
    List<Object?> parameters = const [],
  }) async => executions.add((sql, parameters));
  @override
  Future<List<List<Object?>>> query(
    String sql, {
    List<Object?> parameters = const [],
  }) async {
    queries.add(sql);
    if (sql.contains('FROM telemetry_events')) {
      return [
        ['vehicle-1', 'soc', ...soc],
      ];
    }
    if (sql.contains('FROM alert_episodes')) {
      return active;
    }
    return const [];
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(DatabaseTransaction transaction) action,
  ) => action(this);
}
