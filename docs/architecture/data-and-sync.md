# Data and Synchronization

## Packet contract

Every vehicle telemetry packet has a globally unique `packet_id`, `vehicle_id`, UTC `event_timestamp`, and exactly one signal. The backend also records UTC `server_received_at`; the client records ingestion time and SSE delivery cursor.

Location is one atomic structured signal containing latitude, longitude, and reported accuracy. Legitimate packets do not share the same `(vehicle_id, event_timestamp)`; repeated delivery of the same packet is a duplicate.

## Supported signal catalog and validation

Signal names are lowercase snake case. A known signal with the wrong tagged value type or a value outside its range is `supported_invalid`; retain its raw value and validation reason.

| Signal | Tagged value | Valid value and unit |
| --- | --- | --- |
| `soc` | number | `0 <= value <= 100`, percent |
| `range` | number | `value >= 0`, kilometres |
| `speed` | number | `value >= 0`, kilometres per hour |
| `battery_temp` | number | `-40 <= value <= 100`, degrees Celsius |
| `odometer` | number | `value >= 0`, kilometres |
| `ignition` | boolean | either boolean value |
| `last_ping` | boolean | must be `true` |
| `location` | location | `-90 <= latitude <= 90`, `-180 <= longitude <= 180`, `accuracy_meters >= 0` |

Location accuracy above 100 metres is still valid telemetry. It is only excluded later from geofence-transition confirmation.

## Classification

Persist the raw value and classify every received signal as:

- `supported_valid`: eligible for derived state.
- `supported_invalid`: known signal with invalid value; store validation reason.
- `unsupported`: unknown signal retained for forward compatibility.
- `quarantined`: retained for diagnostics but deliberately excluded from processing, such as an event outside the replayable retention boundary.

Invalid records retain raw value, validation error, arrival time, packet identity, and event time. Only `supported_valid` records influence latest readings, status, alerts, memberships, or trips.

## Timestamp policy

- Treat packet identifiers and vehicle identifiers as opaque, nonblank strings. Do not trim or normalize them.
- Accept an event timestamp up to five minutes later than client receipt time. Its displayed age is clamped to zero.
- Classify an event timestamp more than five minutes after client receipt time as `supported_invalid` with a safe validation reason.
- Classify an event timestamp earlier than `client_received_at - 30 days` as `quarantined`. Exactly 30 days old remains eligible for normal validation.

## Ordering and idempotency

- Deduplicate by `packet_id` using a database constraint/upsert strategy.
- Business calculations use UTC `event_timestamp`.
- SSE replay uses a separate monotonic server delivery ID.
- When records need a deterministic order, sort by `event_timestamp ASC`, then `server_received_at ASC NULLS LAST`, then lexical `packet_id ASC`. Do not rely on insertion order.
- Keep raw events immutable where practical and derive rebuildable projections.

## Bootstrap and live sync

Fresh install:

```text
GET /bootstrap
  → vehicle registry + telemetry backfill + consistent delivery cursor
  → validate/import in one DuckDB transaction
  → build projections
  → render from DuckDB
  → connect /telemetry?after=<cursor>
```

Returning install:

```text
open DuckDB → render immediately → synchronize in background
```

Automatic SSE reconnection uses `Last-Event-ID`. The bootstrap snapshot and cursor must form a consistent boundary with no delivery gap.

For each delivery, atomically persist/deduplicate the packet, update or replay affected projections, and then persist the processed cursor. Never advance the cursor before its packet work commits. A network failure never deletes existing local state.

If the requested cursor predates the bounded backend delivery log, surface an explicit replay-gap outcome; do not silently continue with incomplete history. The recovery UX is an open implementation decision.

## Database-backed UI updates

Every authoritative read goes through DuckDB-backed repositories. An in-memory app event may tell BLoCs that committed data changed, but listeners re-query the repository. An event payload is never a second source of truth.

## Migrations

- Use numbered, immutable SQL migration files and a schema-version table for DuckDB and backend SQLite.
- Apply pending migrations transactionally where supported.
- Never edit an applied migration; add a new migration.
- Test clean creation and upgrades from supported prior schemas.
- Fail safely with a diagnostic if migration cannot complete; do not destroy the database automatically.

## Retention

- Raw valid telemetry: 30 days by event time.
- Invalid and unsupported telemetry: 30 days.
- Already-too-old quarantined arrivals: retain for 30 days by receipt time.
- Derived trip, transition, alert, dismissal, and geofence-version history: no automatic demo expiry.

Cleanup must not race an unfinished replay. Process eligible events and preserve derived history before deleting expired raw data.

## Demo backend

The TypeScript backend stores a small, bounded SQLite delivery log, survives restart, and produces deterministic fixtures for normal, delayed, out-of-order, duplicate, missing-interval, and backlog behavior. It is transport, not fleet truth.
