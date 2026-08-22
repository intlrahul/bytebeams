# 0002: DuckDB reader and writer connections

- Status: Accepted
- Date: 2026-08-22
- Owners: ByteBeams
- Supersedes: the single-connection access model in ADR 0001

## Context

ByteBeams renders committed fleet state from DuckDB while synchronization writes
bootstrap and telemetry data in the background. ADR 0001 selected one serialized
app-scoped connection as a conservative persistence foundation.

That connection makes an initial Vehicle Detail query wait behind a sync write
transaction. Returning users can therefore see a blocking loading screen even
though a previously committed vehicle snapshot is already durable and suitable
for display. Reading authoritative data from an in-memory shadow would violate
the local-first architecture.

`dart_duckdb` 1.2.0 supports multiple connections to one database handle and
manages each connection through its own background isolate. This permits an
ordinary read to observe the last committed database snapshot while another
connection owns an uncommitted transaction.

## Decision

Own one app-scoped DuckDB database handle with exactly two connections:

- one serialized writer for statements, migrations, and transactions;
- one serialized reader for ordinary application queries.

Queries executed through a `DatabaseTransaction` remain on the writer so they
observe that transaction's own pending changes. Repositories continue to depend
on the application-owned `AppDatabase` contract; no DuckDB type crosses into the
domain or presentation layers.

Open the writer first, complete all pending migrations through it, and then open
the reader. This prevents the reader from observing a partially migrated schema.
New work is rejected once shutdown starts. Shutdown drains both owned queues,
then disposes the reader, writer, and database handle.

DuckDB remains the sole durable source of truth. A UI opens from the reader's
committed snapshot. After the writer commits, the existing payload-free
`FleetDataCommitted` event causes interested BLoCs to re-query DuckDB.

## Consequences

- UI queries are not queued behind application-level sync writes.
- Readers observe committed state and never uncommitted telemetry or projection
  changes.
- Writes remain serialized, preserving cursor and projection transaction
  guarantees.
- The adapter and lifecycle are more complex and own two background isolates.
- DuckDB may still coordinate internally at commit boundaries; Android device
  validation is required before claiming the concurrency behavior works.
- iOS and web support remain unverified and out of scope.

## Validation

- Unit tests prove connection routing, independent reader progress during a held
  writer transaction, transaction-local reads, typed failures, and disposal.
- An Android integration test holds an uncommitted writer update, verifies the
  reader returns the prior committed value, commits, and verifies the reader then
  returns the updated value.
- Existing migration, rollback, close/reopen, ingestion, cursor, BLoC, widget,
  analysis, and coverage checks remain required.
