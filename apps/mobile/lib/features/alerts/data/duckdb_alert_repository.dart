import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/core/data/database/database_failure.dart';
import 'package:bytebeams/features/alerts/data/alert_queries.dart';
import 'package:bytebeams/features/alerts/domain/alert_models.dart';
import 'package:bytebeams/features/alerts/domain/alert_repository.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';

final class DuckDbAlertRepository implements AlertRepository {
  const DuckDbAlertRepository(this._database);
  final AppDatabase _database;

  @override
  Future<AlertsResult> getActiveForVehicle(
    String vehicleId, {
    required DateTime nowUtc,
  }) async {
    try {
      final rows = await _database.query(
        AlertQueries.selectCurrent,
        parameters: [vehicleId],
      );
      return Result.success(
        rows
            .map(_alert)
            .where((alert) => !alert.isDismissed || alert.canUndoAt(nowUtc))
            .toList(growable: false),
      );
    } on DatabaseFailure {
      return const Result.failure(AlertFailure.persistenceUnavailable());
    }
  }

  @override
  Future<AlertActionResult> dismiss(
    String alertId,
    AlertDismissalReason reason, {
    required DateTime nowUtc,
  }) => _action(() async {
    await _database.execute(
      AlertQueries.dismiss,
      parameters: [
        nowUtc.toIso8601String(),
        reason.name,
        nowUtc.add(const Duration(seconds: 5)).toIso8601String(),
        alertId,
      ],
    );
    await _recordLifecycle(alertId, 'dismissed', nowUtc, reason: reason);
  });

  @override
  Future<AlertActionResult> undoDismissal(
    String alertId, {
    required DateTime nowUtc,
  }) async {
    try {
      final rows = await _database.query(
        AlertQueries.undo,
        parameters: [
          nowUtc.toIso8601String(),
          alertId,
          nowUtc.toIso8601String(),
        ],
      );
      if (rows.isEmpty) return const Result.failure(AlertFailure.undoExpired());
      await _recordLifecycle(alertId, 'undone', nowUtc);
      return const Result.success(null);
    } on DatabaseFailure {
      return const Result.failure(AlertFailure.persistenceUnavailable());
    }
  }

  Future<AlertActionResult> _action(Future<void> Function() run) async {
    try {
      await run();
      return const Result.success(null);
    } on DatabaseFailure {
      return const Result.failure(AlertFailure.persistenceUnavailable());
    }
  }

  Future<void> _recordLifecycle(
    String alertId,
    String eventType,
    DateTime nowUtc, {
    AlertDismissalReason? reason,
  }) => _database.execute(
    AlertQueries.insertLifecycle,
    parameters: [
      '$alertId:$eventType:${nowUtc.microsecondsSinceEpoch}',
      alertId,
      eventType,
      nowUtc.toIso8601String(),
      null,
      reason?.name,
    ],
  );

  VehicleAlert _alert(List<Object?> row) => VehicleAlert(
    alertId: row[0]! as String,
    vehicleId: row[1]! as String,
    type: AlertType.values.byName(row[2]! as String),
    severity: AlertSeverity.values.byName(row[3]! as String),
    openedAtUtc: row[4]! as DateTime,
    dismissedAtUtc: row[5] as DateTime?,
    dismissalReason: (row[6] as String?) == null
        ? null
        : AlertDismissalReason.values.byName(row[6]! as String),
    undoExpiresAtUtc: row[7] as DateTime?,
  );
}
