abstract final class VehicleDetailQueries {
  static const selectVehicle = '''
SELECT v.vehicle_id, v.registration_number, v.model, g.display_name
FROM vehicles v
LEFT JOIN vehicle_geofence_memberships m ON m.vehicle_id = v.vehicle_id
LEFT JOIN geofence_versions g ON g.geofence_id = m.geofence_id
  AND g.version = m.geofence_version
WHERE v.vehicle_id = ?
''';

  static const selectLatestReadings = '''
WITH ranked AS (
  SELECT signal_name, number_value, event_timestamp_utc, server_received_at_utc,
         packet_id,
         ROW_NUMBER() OVER (
           PARTITION BY signal_name
           ORDER BY event_timestamp_utc DESC,
                    server_received_at_utc DESC NULLS LAST,
                    packet_id DESC
         ) AS rank
  FROM telemetry_events
  WHERE vehicle_id = ?
    AND classification = 'supportedValid'
    AND signal_name IN ('soc', 'range', 'speed', 'battery_temp', 'odometer', 'last_ping')
)
SELECT signal_name, number_value, event_timestamp_utc
FROM ranked
WHERE rank = 1
''';

  static const selectSocHistory = '''
SELECT event_timestamp_utc, number_value
FROM telemetry_events
WHERE vehicle_id = ?
  AND classification = 'supportedValid'
  AND signal_name = 'soc'
  AND event_timestamp_utc >= ?
ORDER BY event_timestamp_utc ASC, server_received_at_utc ASC NULLS LAST, packet_id ASC
''';
  static const selectRecentTrips = '''
SELECT ov.display_name, dv.display_name, t.started_at_utc FROM trips t
JOIN geofence_versions ov ON ov.geofence_id=t.origin_geofence_id AND ov.version=t.origin_geofence_version
LEFT JOIN geofence_versions dv ON dv.geofence_id=t.destination_geofence_id AND dv.version=t.destination_geofence_version
WHERE t.vehicle_id=? ORDER BY t.started_at_utc DESC,t.trip_id ASC LIMIT 4
''';
}
