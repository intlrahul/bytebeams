# Fleet Home

Fleet Home is a local-first projection. It queries DuckDB through the Fleet
Home repository and never reads API or SSE payloads directly. The initial
query renders persisted data immediately; `FleetDataCommitted` then causes the
Fleet Home BLoC to re-query DuckDB after each successful import.

## Status calculation

The repository passes one injected `as_of_utc` time into SQL. Only the latest
valid explicit `last_ping` controls connectivity. A ping exactly ten minutes
old is online:

1. no valid `last_ping`, or `last_ping < as_of - 10 minutes`: `OFFLINE`;
2. otherwise, `speed > 0`: `MOVING`;
3. otherwise, `ignition = true`: `IDLE`;
4. otherwise: `STOPPED`.

Latest speed and ignition are considered even if individually stale. If they
have never reported, the deterministic final fallback is `STOPPED`.

The authoritative order for each signal is `event_timestamp_utc DESC`, then
`server_received_at_utc DESC NULLS LAST`, then `packet_id DESC`.

## Filtering and attention

`All`, `Moving`, `Idle`, `Stopped`, and `Offline` counts are calculated in SQL
from the same status rules. The selected filter is applied in SQL, not to an
in-memory fleet shadow.

Before Milestone 8 introduces durable alert episodes, a Fleet Home badge is a
non-dismissible current-attention indicator: one count for fresh SOC below 20%
and one for fresh battery temperature above 45°C. It is hidden when zero.
Milestone 8 will replace that projection with persisted alert lifecycle data.

## Presentation and accessibility

Fleet Home receives `GetFleetHome`, `AppEventBus`, and `SyncRepository` via
the composition root. It does not service-locate, execute SQL, or consume
transport payloads. The BLoC exposes loading, saved-data syncing, degraded,
failure, populated, and empty-filter states.

Sparkee owns visual treatment. Each fleet row exposes registration, model,
state, SOC, range, and attention through text and accessibility semantics.
Filter chips announce their label and current SQL count.
