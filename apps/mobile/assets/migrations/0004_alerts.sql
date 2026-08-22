CREATE TABLE alert_episodes (
  alert_id VARCHAR PRIMARY KEY,
  vehicle_id VARCHAR NOT NULL,
  alert_type VARCHAR NOT NULL,
  opened_at_utc TIMESTAMPTZ NOT NULL,
  opened_packet_id VARCHAR NOT NULL,
  severity VARCHAR NOT NULL,
  resolved_at_utc TIMESTAMPTZ,
  dismissed_at_utc TIMESTAMPTZ,
  dismissal_reason VARCHAR,
  undo_expires_at_utc TIMESTAMPTZ,
  undone_at_utc TIMESTAMPTZ,
  UNIQUE(vehicle_id, alert_type, opened_packet_id)
);

CREATE INDEX alert_episodes_current_idx
  ON alert_episodes (vehicle_id, alert_type, resolved_at_utc);

CREATE TABLE alert_lifecycle_events (
  event_id VARCHAR PRIMARY KEY,
  alert_id VARCHAR NOT NULL,
  event_type VARCHAR NOT NULL,
  occurred_at_utc TIMESTAMPTZ NOT NULL,
  severity VARCHAR,
  dismissal_reason VARCHAR
);

CREATE INDEX alert_lifecycle_events_alert_idx
  ON alert_lifecycle_events (alert_id, occurred_at_utc);
