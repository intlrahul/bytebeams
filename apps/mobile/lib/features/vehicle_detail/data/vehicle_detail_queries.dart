abstract final class VehicleDetailQueries {
  static const selectVehicle = '''
SELECT vehicle_id, registration_number, model
FROM vehicles
WHERE vehicle_id = ?
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
}
