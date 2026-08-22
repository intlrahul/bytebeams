import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/core/data/database/database_failure.dart';
import 'package:bytebeams/features/alerts/data/alert_queries.dart';
import 'package:bytebeams/features/alerts/data/duckdb_alert_repository.dart';
import 'package:bytebeams/features/alerts/domain/alert_models.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 8, 22, 12);
  test('given_active_and_dismissed_episodes_when_read_then_keeps_only_visible_alerts', () async {
    final database = _Database(
      rows: [
        ['a1', 'v1', 'lowBattery', 'warning', now, null, null, null],
        [
          'a2',
          'v1',
          'batteryOverheating',
          'critical',
          now,
          now,
          'wrongAlert',
          now.add(const Duration(seconds: 4)),
        ],
        ['a3', 'v1', 'lowBattery', 'warning', now, now, 'iAmOnIt', now],
      ],
    );
    final result = await DuckDbAlertRepository(database)
        .getActiveForVehicle('v1', nowUtc: now);
    final alerts = (result as Success<List<VehicleAlert>, AlertFailure>).value;
    expect(alerts.map((alert) => alert.alertId), ['a1', 'a2']);
  });

  test(
    'given_actions_when_persisted_then_writes_dismiss_and_undo_queries',
    () async {
      final database = _Database();
      final repository = DuckDbAlertRepository(database);
      await repository.dismiss('a1', AlertDismissalReason.iAmOnIt, nowUtc: now);
      await repository.undoDismissal('a1', nowUtc: now);
      expect(
        database.sql,
        containsAll([
          AlertQueries.dismiss,
          AlertQueries.undo,
          AlertQueries.insertLifecycle,
        ]),
      );
    },
  );

  test('given_expired_undo_when_requested_then_returns_undo_expired', () async {
    final result = await DuckDbAlertRepository(_Database(undoSucceeds: false))
        .undoDismissal('a1', nowUtc: now);
    expect(result, isA<Failure<void, AlertFailure>>());
  });

  test(
    'given_database_failure_when_actioned_then_returns_safe_failure',
    () async {
      final result = await DuckDbAlertRepository(_Database(fails: true))
          .dismiss('a1', AlertDismissalReason.wrongAlert, nowUtc: now);
      expect(result, isA<Failure<void, AlertFailure>>());
    },
  );

  test('given_database_failure_when_read_then_returns_safe_failure', () async {
    final result = await DuckDbAlertRepository(_Database(fails: true))
        .getActiveForVehicle('v1', nowUtc: now);
    expect(result, isA<Failure<List<VehicleAlert>, AlertFailure>>());
  });
}

final class _Database implements AppDatabase {
  _Database({
    this.rows = const [],
    this.fails = false,
    this.undoSucceeds = true,
  });
  final List<List<Object?>> rows;
  final bool fails;
  final sql = <String>[];
  final bool undoSucceeds;
  @override
  Future<void> close() async {}
  @override
  Future<int> currentSchemaVersion() async => 4;
  @override
  Future<void> execute(
    String value, {
    List<Object?> parameters = const [],
  }) async {
    if (fails) throw const DatabaseOperationFailure(safeMessage: 'x');
    sql.add(value);
  }

  @override
  Future<List<List<Object?>>> query(
    String value, {
    List<Object?> parameters = const [],
  }) async {
    sql.add(value);
    if (fails) {
      throw const DatabaseOperationFailure(safeMessage: 'x');
    }
    if (value == AlertQueries.selectCurrent) {
      return rows;
    }
    if (value == AlertQueries.undo && undoSucceeds) {
      return const [
        ['a1'],
      ];
    }
    return const [];
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(DatabaseTransaction transaction) action,
  ) => action(this);
}
