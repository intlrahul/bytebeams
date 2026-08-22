const selectSyncCursor = '''
SELECT value FROM sync_state WHERE key = 'delivery_cursor'
''';

const upsertSyncCursor = '''
INSERT INTO sync_state (key, value) VALUES ('delivery_cursor', ?)
ON CONFLICT(key) DO UPDATE SET value = excluded.value
''';

const upsertSyncOrigin = '''
INSERT INTO sync_state (key, value) VALUES ('sync_origin', ?)
ON CONFLICT(key) DO UPDATE SET value = excluded.value
''';

const deleteBackendSyncedData = '''
DELETE FROM telemetry_events
WHERE vehicle_id IN (
  SELECT vehicle_id FROM vehicles
  WHERE vehicle_id NOT LIKE 'demo:%'
)
''';

const deleteBackendSyncedVehicles = '''
DELETE FROM vehicles WHERE vehicle_id NOT LIKE 'demo:%'
''';
