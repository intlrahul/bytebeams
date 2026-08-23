import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/core/time/clock.dart';

abstract interface class RetentionCleanup {
  Future<void> runIfDue(DatabaseTransaction database);
}

final class DuckDbRetentionCleanup implements RetentionCleanup {
  const DuckDbRetentionCleanup({required this.clock});

  static const _key = 'retention_cleanup_utc_day';
  static const _retention = Duration(days: 30);
  final Clock clock;

  @override
  Future<void> runIfDue(DatabaseTransaction database) async {
    final now = clock.nowUtc();
    final day = now.toIso8601String().substring(0, 10);
    final recorded = await database.query(
      'SELECT value FROM sync_state WHERE key = ?',
      parameters: [_key],
    );
    if (recorded.isNotEmpty && recorded.single.single == day) return;
    final cutoffAt = now.subtract(_retention);
    final cutoff = cutoffAt.millisecondsSinceEpoch;
    await database.execute('DELETE FROM geofence_replay_checkpoints');
    await database.execute(
      _insertReplayCheckpoints,
      parameters: [cutoffAt.toIso8601String(), cutoff, cutoff],
    );
    await database.execute(
      "DELETE FROM telemetry_events WHERE classification != 'quarantined' AND epoch_ms(event_timestamp_utc) < ?",
      parameters: [cutoff],
    );
    await database.execute(
      "DELETE FROM telemetry_events WHERE classification = 'quarantined' AND epoch_ms(client_received_at_utc) < ?",
      parameters: [cutoff],
    );
    await database.execute(
      "INSERT INTO sync_state (key, value) VALUES (?, ?) ON CONFLICT(key) DO UPDATE SET value = excluded.value",
      parameters: [_key, day],
    );
  }

  static const _insertReplayCheckpoints = '''
INSERT INTO geofence_replay_checkpoints (
  vehicle_id, geofence_id, geofence_version, checkpoint_at_utc
)
SELECT v.vehicle_id,
       CASE WHEN p.transition_type = 'entry' THEN p.geofence_id
            WHEN p.transition_type = 'exit' THEN NULL
            WHEN n.transition_type = 'exit' THEN n.geofence_id
            WHEN n.transition_type = 'entry' THEN NULL
            ELSE m.geofence_id END,
       CASE WHEN p.transition_type = 'entry' THEN p.geofence_version
            WHEN p.transition_type = 'exit' THEN NULL
            WHEN n.transition_type = 'exit' THEN n.geofence_version
            WHEN n.transition_type = 'entry' THEN NULL
            ELSE m.geofence_version END,
       CAST(? AS TIMESTAMPTZ)
FROM vehicles v
LEFT JOIN (
  SELECT vehicle_id, geofence_id, geofence_version, transition_type,
         ROW_NUMBER() OVER (
           PARTITION BY vehicle_id
           ORDER BY event_timestamp_utc DESC, packet_id DESC, transition_id DESC
         ) AS replay_rank
  FROM geofence_transitions
  WHERE epoch_ms(event_timestamp_utc) < ?
) p ON p.vehicle_id = v.vehicle_id AND p.replay_rank = 1
LEFT JOIN (
  SELECT vehicle_id, geofence_id, geofence_version, transition_type,
         ROW_NUMBER() OVER (
           PARTITION BY vehicle_id
           ORDER BY event_timestamp_utc ASC, packet_id ASC, transition_id ASC
         ) AS replay_rank
  FROM geofence_transitions
  WHERE epoch_ms(event_timestamp_utc) >= ?
) n ON n.vehicle_id = v.vehicle_id AND n.replay_rank = 1
LEFT JOIN vehicle_geofence_memberships m ON m.vehicle_id = v.vehicle_id
''';
}
