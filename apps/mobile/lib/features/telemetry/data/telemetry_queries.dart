const insertTelemetryEvent = '''
INSERT INTO telemetry_events (
  packet_id, vehicle_id, event_timestamp_utc, server_received_at_utc,
  client_received_at_utc, signal_name, classification, raw_value_json,
  validation_error, number_value, boolean_value, latitude, longitude, accuracy_meters
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
ON CONFLICT (packet_id) DO NOTHING
RETURNING packet_id
''';

const upsertVehicle = '''
INSERT INTO vehicles (vehicle_id, registration_number, model)
VALUES (?, ?, ?)
ON CONFLICT (vehicle_id) DO UPDATE SET
  registration_number = excluded.registration_number,
  model = excluded.model
''';

const selectTelemetryDiagnosticsForVehicle = '''
SELECT packet_id, vehicle_id, event_timestamp_utc, client_received_at_utc,
  signal_name, raw_value_json, classification, server_received_at_utc, validation_error
FROM telemetry_events
WHERE vehicle_id = ?
ORDER BY event_timestamp_utc ASC, server_received_at_utc ASC NULLS LAST, packet_id ASC
''';
