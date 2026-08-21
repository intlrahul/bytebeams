CREATE TABLE IF NOT EXISTS schema_migrations (
  version INTEGER PRIMARY KEY,
  name VARCHAR NOT NULL,
  applied_at_utc TIMESTAMPTZ NOT NULL
)
