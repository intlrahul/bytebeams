CREATE TABLE vehicles (
  vehicle_id VARCHAR PRIMARY KEY,
  registration_number VARCHAR NOT NULL,
  model VARCHAR NOT NULL
);

CREATE TABLE telemetry_events (
  packet_id VARCHAR PRIMARY KEY,
  vehicle_id VARCHAR NOT NULL,
  event_timestamp_utc TIMESTAMPTZ NOT NULL,
  server_received_at_utc TIMESTAMPTZ,
  client_received_at_utc TIMESTAMPTZ NOT NULL,
  signal_name VARCHAR NOT NULL,
  classification VARCHAR NOT NULL,
  raw_value_json VARCHAR NOT NULL,
  validation_error VARCHAR,
  number_value DOUBLE,
  boolean_value BOOLEAN,
  latitude DOUBLE,
  longitude DOUBLE,
  accuracy_meters DOUBLE
);

CREATE INDEX telemetry_events_vehicle_order_idx
  ON telemetry_events (vehicle_id, event_timestamp_utc, server_received_at_utc, packet_id);
