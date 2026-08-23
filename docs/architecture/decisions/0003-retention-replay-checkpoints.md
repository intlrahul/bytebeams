# 0003: Retention replay checkpoints

- Status: Accepted
- Date: 2026-08-23
- Owners: ByteBeams

## Context

Raw telemetry expires after 30 days, while geofence transitions and trips are retained indefinitely. Rebuilding a vehicle by deleting all derived rows and reading only retained raw locations would erase valid historical transitions after their supporting packets expire. It would also lose the vehicle's confirmed inside/outside state at the retention boundary.

## Decision

Before daily raw cleanup, persist one geofence replay checkpoint per vehicle at the event-time retention boundary. The checkpoint contains the confirmed geofence identity/version or an explicit outside state. It is derived from the latest transition before the cutoff, falling back to the current membership when no transition exists.

Geofence replay preserves transitions before the checkpoint and replaces only transitions at or after it. Replay starts from the checkpoint state and processes retained locations deterministically. Trip replay continues to rebuild from the complete retained transition history, so historical completed trips remain reproducible even after raw location expiry.

Checkpoint creation, projection rebuilds, cleanup, cursor advancement, and packet writes all use the serialized DuckDB writer transaction.

## Consequences

- Raw telemetry can honor its 30-day policy without discarding derived history.
- Late retained locations can revise the replayable window but cannot rewrite history before the retention boundary.
- Migration 7 adds a small durable table with one row per vehicle.
- The checkpoint is derived data and contains no raw telemetry payload.

## Validation

- Migration tests cover clean creation and version-6-to-7 upgrade.
- Real DuckDB Android tests cover cutoff boundaries, close/reopen durability, historical-transition preservation, late/reordered replay, trip identity, and rollback.
- The representative 500-vehicle/10,000-delivery harness enforces the approved cleanup and rebuild budgets.

## Follow-up

Revisit bounded replay only if a larger retained dataset exceeds the approved Android budget.
