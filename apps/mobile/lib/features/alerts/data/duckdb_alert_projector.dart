import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/core/time/clock.dart';
import 'package:bytebeams/features/alerts/data/alert_queries.dart';
import 'package:bytebeams/features/alerts/domain/alert_models.dart';

abstract interface class AlertProjector {
  Future<void> rebuild(
    DatabaseTransaction database,
    Iterable<String> vehicleIds,
  );
}

final class DuckDbAlertProjector implements AlertProjector {
  const DuckDbAlertProjector({required this.clock});
  final Clock clock;

  @override
  Future<void> rebuild(
    DatabaseTransaction database,
    Iterable<String> vehicleIds,
  ) async {
    for (final vehicleId in vehicleIds.toSet()) {
      await _apply(database, vehicleId, AlertType.lowBattery, 'soc');
      await _apply(
        database,
        vehicleId,
        AlertType.batteryOverheating,
        'battery_temp',
      );
    }
  }

  Future<void> _apply(
    DatabaseTransaction database,
    String vehicleId,
    AlertType type,
    String signal,
  ) async {
    final latest = await database.query(
      AlertQueries.selectLatestSignal,
      parameters: [vehicleId, signal],
    );
    if (latest.isEmpty) return;
    final row = latest.single;
    final timestamp = row[1]! as DateTime;
    if (timestamp.isBefore(
      clock.nowUtc().subtract(const Duration(minutes: 10)),
    )) {
      return;
    }
    final value = (row[0]! as num).toDouble();
    final severity = switch (type) {
      AlertType.lowBattery when value < 10 => AlertSeverity.critical,
      AlertType.lowBattery when value < 20 => AlertSeverity.warning,
      AlertType.batteryOverheating when value > 45 => AlertSeverity.critical,
      _ => null,
    };
    final active = await database.query(
      AlertQueries.selectActiveByType,
      parameters: [vehicleId, type.name],
    );
    if (severity == null) {
      if (active.isNotEmpty) {
        await database.execute(
          AlertQueries.resolveEpisode,
          parameters: [clock.nowUtc().toIso8601String(), active.single[0]],
        );
        await _record(database, active.single[0]! as String, 'resolved', null);
      }
      return;
    }
    if (active.isEmpty) {
      final packetId = row[2]! as String;
      final alertId = '$vehicleId:${type.name}:$packetId';
      await database.execute(
        AlertQueries.insertEpisode,
        parameters: [
          alertId,
          vehicleId,
          type.name,
          timestamp.toIso8601String(),
          packetId,
          severity.name,
        ],
      );
      await _record(database, alertId, 'opened', severity);
      return;
    }
    if (active.single[1] != AlertSeverity.critical.name &&
        severity == AlertSeverity.critical) {
      await database.execute(
        AlertQueries.escalateEpisode,
        parameters: [severity.name, active.single[0]],
      );
      await _record(
        database,
        active.single[0]! as String,
        'escalated',
        severity,
      );
    }
  }

  Future<void> _record(
    DatabaseTransaction database,
    String alertId,
    String eventType,
    AlertSeverity? severity,
  ) => database.execute(
    AlertQueries.insertLifecycle,
    parameters: [
      '$alertId:$eventType',
      alertId,
      eventType,
      clock.nowUtc().toIso8601String(),
      severity?.name,
      null,
    ],
  );
}
