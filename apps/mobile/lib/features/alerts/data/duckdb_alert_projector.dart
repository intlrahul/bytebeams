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
    final ids = vehicleIds.toSet().toList(growable: false);
    if (ids.isEmpty) return;
    final latestRows = await database.query(
      _latestSignalsQuery(ids.length),
      parameters: ids,
    );
    final activeRows = await database.query(
      _activeAlertsQuery(ids.length),
      parameters: [
        ...ids,
        AlertType.lowBattery.name,
        AlertType.batteryOverheating.name,
      ],
    );
    final latestByKey = <String, _LatestSignal>{
      for (final row in latestRows)
        '${row[0]}:${row[1]}': _LatestSignal(
          value: (row[2]! as num).toDouble(),
          eventTimestampUtc: row[3]! as DateTime,
          packetId: row[4]! as String,
        ),
    };
    final activeByKey = <String, _ActiveAlert>{
      for (final row in activeRows)
        '${row[1]}:${row[2]}': _ActiveAlert(
          alertId: row[0]! as String,
          severity: AlertSeverity.values.byName(row[3]! as String),
        ),
    };
    for (final vehicleId in ids) {
      await _apply(
        database,
        vehicleId,
        AlertType.lowBattery,
        latestByKey['$vehicleId:soc'],
        activeByKey['$vehicleId:${AlertType.lowBattery.name}'],
      );
      await _apply(
        database,
        vehicleId,
        AlertType.batteryOverheating,
        latestByKey['$vehicleId:battery_temp'],
        activeByKey['$vehicleId:${AlertType.batteryOverheating.name}'],
      );
    }
  }

  Future<void> _apply(
    DatabaseTransaction database,
    String vehicleId,
    AlertType type,
    _LatestSignal? latest,
    _ActiveAlert? active,
  ) async {
    if (latest == null) return;
    if (latest.eventTimestampUtc.isBefore(
      clock.nowUtc().subtract(const Duration(minutes: 10)),
    )) {
      return;
    }
    final severity = switch (type) {
      AlertType.lowBattery when latest.value < 10 => AlertSeverity.critical,
      AlertType.lowBattery when latest.value < 20 => AlertSeverity.warning,
      AlertType.batteryOverheating when latest.value > 45 =>
        AlertSeverity.critical,
      _ => null,
    };
    if (severity == null) {
      if (active != null) {
        await database.execute(
          AlertQueries.resolveEpisode,
          parameters: [clock.nowUtc().toIso8601String(), active.alertId],
        );
        await _record(database, active.alertId, 'resolved', null);
      }
      return;
    }
    if (active == null) {
      final alertId = '$vehicleId:${type.name}:${latest.packetId}';
      await database.execute(
        AlertQueries.insertEpisode,
        parameters: [
          alertId,
          vehicleId,
          type.name,
          latest.eventTimestampUtc.toIso8601String(),
          latest.packetId,
          severity.name,
        ],
      );
      await _record(database, alertId, 'opened', severity);
      return;
    }
    if (active.severity != AlertSeverity.critical &&
        severity == AlertSeverity.critical) {
      await database.execute(
        AlertQueries.escalateEpisode,
        parameters: [severity.name, active.alertId],
      );
      await _record(database, active.alertId, 'escalated', severity);
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

  String _latestSignalsQuery(int vehicleCount) =>
      '''
WITH ranked AS (
  SELECT vehicle_id, signal_name, number_value, event_timestamp_utc, packet_id,
         ROW_NUMBER() OVER (
           PARTITION BY vehicle_id, signal_name
           ORDER BY event_timestamp_utc DESC,
                    server_received_at_utc DESC NULLS LAST,
                    packet_id DESC
         ) AS rank
  FROM telemetry_events
  WHERE vehicle_id IN (${List.filled(vehicleCount, '?').join(', ')})
    AND classification = 'supportedValid'
    AND signal_name IN ('soc', 'battery_temp')
)
SELECT vehicle_id, signal_name, number_value, event_timestamp_utc, packet_id
FROM ranked
WHERE rank = 1
''';

  String _activeAlertsQuery(int vehicleCount) =>
      '''
SELECT alert_id, vehicle_id, alert_type, severity
FROM alert_episodes
WHERE vehicle_id IN (${List.filled(vehicleCount, '?').join(', ')})
  AND alert_type IN (?, ?)
  AND resolved_at_utc IS NULL
''';
}

final class _LatestSignal {
  const _LatestSignal({
    required this.value,
    required this.eventTimestampUtc,
    required this.packetId,
  });

  final double value;
  final DateTime eventTimestampUtc;
  final String packetId;
}

final class _ActiveAlert {
  const _ActiveAlert({required this.alertId, required this.severity});

  final String alertId;
  final AlertSeverity severity;
}
