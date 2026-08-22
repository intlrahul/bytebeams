CREATE TABLE trips (
  trip_id VARCHAR PRIMARY KEY,
  vehicle_id VARCHAR NOT NULL,
  origin_geofence_id VARCHAR NOT NULL,
  origin_geofence_version INTEGER NOT NULL,
  exit_transition_id VARCHAR NOT NULL UNIQUE,
  started_at_utc TIMESTAMPTZ NOT NULL,
  destination_geofence_id VARCHAR,
  destination_geofence_version INTEGER,
  entry_transition_id VARCHAR UNIQUE,
  completed_at_utc TIMESTAMPTZ,
  status VARCHAR NOT NULL,
  active_vehicle_id VARCHAR UNIQUE,
  CHECK (status IN ('inProgress', 'completed')),
  CHECK ((status = 'inProgress' AND destination_geofence_id IS NULL AND destination_geofence_version IS NULL AND entry_transition_id IS NULL AND completed_at_utc IS NULL AND active_vehicle_id = vehicle_id) OR (status = 'completed' AND destination_geofence_id IS NOT NULL AND destination_geofence_version IS NOT NULL AND entry_transition_id IS NOT NULL AND completed_at_utc IS NOT NULL AND active_vehicle_id IS NULL))
);

CREATE INDEX trips_vehicle_started_idx ON trips (vehicle_id, started_at_utc DESC, trip_id ASC);
CREATE INDEX trips_status_started_idx ON trips (status, started_at_utc DESC, trip_id ASC);
