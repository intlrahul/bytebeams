CREATE TABLE geofences (
  geofence_id VARCHAR PRIMARY KEY,
  created_at_utc TIMESTAMPTZ NOT NULL
);

CREATE TABLE geofence_versions (
  geofence_id VARCHAR NOT NULL,
  version INTEGER NOT NULL,
  display_name VARCHAR NOT NULL,
  latitude DOUBLE NOT NULL,
  longitude DOUBLE NOT NULL,
  radius_meters DOUBLE NOT NULL,
  is_active BOOLEAN NOT NULL,
  effective_from_utc TIMESTAMPTZ NOT NULL,
  effective_until_utc TIMESTAMPTZ,
  PRIMARY KEY (geofence_id, version)
);

CREATE INDEX geofence_versions_effective_idx
  ON geofence_versions (geofence_id, effective_from_utc, effective_until_utc);

CREATE TABLE vehicle_geofence_memberships (
  vehicle_id VARCHAR PRIMARY KEY,
  geofence_id VARCHAR,
  geofence_version INTEGER,
  observed_at_utc TIMESTAMPTZ,
  packet_id VARCHAR
);

CREATE TABLE geofence_transition_candidates (
  vehicle_id VARCHAR PRIMARY KEY,
  candidate_geofence_id VARCHAR,
  candidate_version INTEGER,
  first_event_timestamp_utc TIMESTAMPTZ,
  first_packet_id VARCHAR,
  supporting_reading_count INTEGER NOT NULL
);

CREATE TABLE geofence_transitions (
  transition_id VARCHAR PRIMARY KEY,
  vehicle_id VARCHAR NOT NULL,
  geofence_id VARCHAR NOT NULL,
  geofence_version INTEGER NOT NULL,
  transition_type VARCHAR NOT NULL,
  event_timestamp_utc TIMESTAMPTZ NOT NULL,
  packet_id VARCHAR NOT NULL
);

CREATE INDEX geofence_transitions_vehicle_order_idx
  ON geofence_transitions (vehicle_id, event_timestamp_utc, packet_id);
