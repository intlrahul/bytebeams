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

Automatic SSE reconnection uses `Last-Event-ID`. The bootstrap snapshot and cursor must form a consistent boundary with no delivery gap. After replaying missed deliveries, the backend keeps the SSE response open, emits comment heartbeats every 15 seconds, and broadcasts later deliveries on that same connection. It removes a connection when the client closes it.

For each delivery, atomically persist/deduplicate the packet, update or replay affected projections, and then persist the processed cursor. Never advance the cursor before its packet work commits. A network failure never deletes existing local state.

If the requested cursor predates the bounded backend delivery log, surface an explicit replay-gap outcome; do not silently continue with incomplete history. Preserve the local database and expose a degraded state. An explicit **Refresh from server** replaces only backend-synced registry, telemetry, and cursor in one transaction.

### Mobile synchronization decisions

- `AppEventBus` delivers payload-free `FleetDataCommitted` events asynchronously. Consumers always re-query DuckDB after an event.
- Live SSE deliveries are retained in an in-memory batch and committed transactionally every five seconds or at 100 packets, whichever comes first. A batch inserts all packets and advances its final delivery cursor in the same DuckDB transaction, then emits one `FleetDataCommitted`. App shutdown attempts a final flush. This intentionally risks at most five seconds of uncommitted packets if the process is killed.
- Reconnect delays are deterministic with no jitter: 1, 2, 4, 8, then 15 seconds for every later retry.
- A fresh install whose bootstrap fails exposes an explicit **Use demo data** action. It imports the packaged fixture through the same transactional store; it never silently replaces server data.
- The sync repository retains its current state as well as broadcasting updates, so a screen that subscribes after background bootstrap begins still renders a visible sync indicator or the explicit demo-data action.
- The Android emulator endpoint is `http://10.0.2.2:3000`; iOS, web, and local development use `http://localhost:3000`. Endpoint literals are owned only by the endpoint provider.
- A normal bootstrap upserts its current snapshot and preserves older local retained telemetry. It writes the bootstrap cursor in the same transaction, then SSE resumes using that persisted cursor and `Last-Event-ID`.

### Live delivery batching trade-off

The server can produce one or more live packets per second. Refreshing Fleet Home after every packet would repeatedly run its DuckDB projections and rebuild the list, making scrolling and filtering feel slow even though `ListView` lazily creates row widgets.

The mobile client therefore batches live deliveries for at most five seconds, or commits immediately when 100 packets are pending. It performs one DuckDB transaction for the batch, writes the final delivery cursor in that same transaction, and publishes one payload-free `FleetDataCommitted` event only after the transaction succeeds. Fleet Home then re-queries DuckDB once per committed batch.

This deliberately accepts a bounded durability gap: if the app process is killed before a batch commits, up to five seconds of packets may exist only in memory. The persisted cursor remains at the prior successful batch, so reconnect uses `Last-Event-ID` to replay those deliveries; packet-ID deduplication keeps the replay idempotent. A normal app shutdown attempts a final flush. The 100-packet ceiling prevents large transactions when a vehicle returns from a connectivity gap and sends a backlog.

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

The demo uses seed `bytebeams-demo-v1`, a scripted UTC start time, exactly 500 vehicles, and a 24-hour bootstrap backfill. Retain the newest 10,000 deliveries and no delivery older than seven days. `Last-Event-ID` takes precedence over the `after` query parameter. A cursor before the retained window receives HTTP 409 with `replay_gap`, the requested cursor, and the oldest available cursor.
