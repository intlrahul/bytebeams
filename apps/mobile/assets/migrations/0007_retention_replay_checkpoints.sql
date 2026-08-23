CREATE TABLE geofence_replay_checkpoints (
  vehicle_id VARCHAR PRIMARY KEY,
  geofence_id VARCHAR,
  geofence_version INTEGER,
  checkpoint_at_utc TIMESTAMPTZ NOT NULL
);
