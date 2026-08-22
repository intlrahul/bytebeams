abstract final class AlertQueries {
  static const insertLifecycle = '''
INSERT INTO alert_lifecycle_events (
  event_id, alert_id, event_type, occurred_at_utc, severity, dismissal_reason
) VALUES (?, ?, ?, ?, ?, ?)
ON CONFLICT(event_id) DO NOTHING
''';

  static const selectCurrent = '''
SELECT alert_id, vehicle_id, alert_type, severity, opened_at_utc,
       dismissed_at_utc, dismissal_reason, undo_expires_at_utc
FROM alert_episodes
WHERE vehicle_id = ? AND resolved_at_utc IS NULL
ORDER BY severity DESC, opened_at_utc ASC
''';

  static const selectActiveByType = '''
SELECT alert_id, severity FROM alert_episodes
WHERE vehicle_id = ? AND alert_type = ? AND resolved_at_utc IS NULL
LIMIT 1
''';

  static const selectLatestSignal = '''
SELECT number_value, event_timestamp_utc, packet_id
FROM telemetry_events
WHERE vehicle_id = ? AND classification = 'supportedValid' AND signal_name = ?
ORDER BY event_timestamp_utc DESC, server_received_at_utc DESC NULLS LAST, packet_id DESC
LIMIT 1
''';

  static const insertEpisode = '''
INSERT INTO alert_episodes (
  alert_id, vehicle_id, alert_type, opened_at_utc, opened_packet_id, severity
) VALUES (?, ?, ?, ?, ?, ?)
ON CONFLICT(alert_id) DO NOTHING
''';

  static const resolveEpisode = '''
UPDATE alert_episodes SET resolved_at_utc = ? WHERE alert_id = ?
''';

  static const escalateEpisode = '''
UPDATE alert_episodes
SET severity = ?, dismissed_at_utc = NULL, dismissal_reason = NULL,
    undo_expires_at_utc = NULL, undone_at_utc = NULL
WHERE alert_id = ?
''';

  static const dismiss = '''
UPDATE alert_episodes
SET dismissed_at_utc = ?, dismissal_reason = ?, undo_expires_at_utc = ?, undone_at_utc = NULL
WHERE alert_id = ? AND resolved_at_utc IS NULL
''';

  static const undo = '''
UPDATE alert_episodes
SET dismissed_at_utc = NULL, dismissal_reason = NULL, undo_expires_at_utc = NULL, undone_at_utc = ?
WHERE alert_id = ? AND dismissed_at_utc IS NOT NULL AND undo_expires_at_utc > ?
RETURNING alert_id
''';
}
