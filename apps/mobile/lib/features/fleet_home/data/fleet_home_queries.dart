/// Auditable SQL for the authoritative DuckDB-backed Fleet Home projection.
///
/// The first parameter is the UTC screen time. The second and third are the
/// selected filter name, where `all` returns every derived row.
abstract final class FleetHomeQueries {
  static const selectRows = '''
WITH latest_valid AS (
  SELECT vehicle_id, signal_name, number_value, boolean_value,
         event_timestamp_utc, server_received_at_utc, packet_id,
         ROW_NUMBER() OVER (
           PARTITION BY vehicle_id, signal_name
           ORDER BY event_timestamp_utc DESC,
                    server_received_at_utc DESC NULLS LAST,
                    packet_id DESC
         ) AS rank
  FROM telemetry_events
  WHERE classification = 'supportedValid'
    AND signal_name IN ('last_ping', 'speed', 'ignition', 'soc', 'range', 'battery_temp')
),
signals AS (
  SELECT vehicle_id,
         MAX(CASE WHEN signal_name = 'last_ping' AND rank = 1 THEN event_timestamp_utc END) AS last_ping_at,
         MAX(CASE WHEN signal_name = 'speed' AND rank = 1 THEN number_value END) AS speed,
         MAX(CASE WHEN signal_name = 'ignition' AND rank = 1 THEN boolean_value END) AS ignition,
         MAX(CASE WHEN signal_name = 'soc' AND rank = 1 THEN number_value END) AS soc,
         MAX(CASE WHEN signal_name = 'soc' AND rank = 1 THEN event_timestamp_utc END) AS soc_at,
         MAX(CASE WHEN signal_name = 'range' AND rank = 1 THEN number_value END) AS range_km,
         MAX(CASE WHEN signal_name = 'battery_temp' AND rank = 1 THEN number_value END) AS battery_temp,
         MAX(CASE WHEN signal_name = 'battery_temp' AND rank = 1 THEN event_timestamp_utc END) AS battery_temp_at
  FROM latest_valid
  GROUP BY vehicle_id
),
derived AS (
  SELECT v.vehicle_id, v.registration_number, v.model, s.soc, s.range_km,
         CASE
           WHEN s.last_ping_at IS NULL OR s.last_ping_at < ? THEN 'offline'
           WHEN s.speed > 0 THEN 'moving'
           WHEN s.ignition IS TRUE THEN 'idle'
           ELSE 'stopped'
         END AS status,
         (CASE WHEN s.soc_at >= ? AND s.soc < 20 THEN 1 ELSE 0 END) +
         (CASE WHEN s.battery_temp_at >= ? AND s.battery_temp > 45 THEN 1 ELSE 0 END) AS attention_count
  FROM vehicles v
  LEFT JOIN signals s ON s.vehicle_id = v.vehicle_id
)
SELECT vehicle_id, registration_number, model, soc, range_km, status, attention_count
FROM derived
WHERE ? = 'all' OR status = ?
ORDER BY registration_number ASC, vehicle_id ASC
''';

  static const selectCounts = '''
WITH latest_valid AS (
  SELECT vehicle_id, signal_name, number_value, boolean_value,
         event_timestamp_utc, server_received_at_utc, packet_id,
         ROW_NUMBER() OVER (
           PARTITION BY vehicle_id, signal_name
           ORDER BY event_timestamp_utc DESC,
                    server_received_at_utc DESC NULLS LAST,
                    packet_id DESC
         ) AS rank
  FROM telemetry_events
  WHERE classification = 'supportedValid'
    AND signal_name IN ('last_ping', 'speed', 'ignition')
),
signals AS (
  SELECT vehicle_id,
         MAX(CASE WHEN signal_name = 'last_ping' AND rank = 1 THEN event_timestamp_utc END) AS last_ping_at,
         MAX(CASE WHEN signal_name = 'speed' AND rank = 1 THEN number_value END) AS speed,
         MAX(CASE WHEN signal_name = 'ignition' AND rank = 1 THEN boolean_value END) AS ignition
  FROM latest_valid
  GROUP BY vehicle_id
),
derived AS (
  SELECT CASE
           WHEN s.last_ping_at IS NULL OR s.last_ping_at < ? THEN 'offline'
           WHEN s.speed > 0 THEN 'moving'
           WHEN s.ignition IS TRUE THEN 'idle'
           ELSE 'stopped'
         END AS status
  FROM vehicles v
  LEFT JOIN signals s ON s.vehicle_id = v.vehicle_id
)
SELECT COUNT(*) AS all_count,
       COUNT(*) FILTER (WHERE status = 'moving') AS moving_count,
       COUNT(*) FILTER (WHERE status = 'idle') AS idle_count,
       COUNT(*) FILTER (WHERE status = 'stopped') AS stopped_count,
       COUNT(*) FILTER (WHERE status = 'offline') AS offline_count
FROM derived
''';
}
