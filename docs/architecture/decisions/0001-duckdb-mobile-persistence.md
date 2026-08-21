# 0001: DuckDB mobile persistence foundation

- Status: Accepted
- Date: 2026-08-21
- Owners: ByteBeams

## Context

ByteBeams is local-first: the mobile UI must restore known fleet state from durable on-device storage. Android is the first required demo target. The app needs a small, application-owned DuckDB foundation that supports safe startup, schema upgrades, close/reopen durability, and future deterministic event-time processing without exposing DuckDB to domain or presentation code.

## Decision drivers

- Verify actual packaged Android persistence before feature development depends on it.
- Preserve DuckDB as the authoritative mobile store.
- Keep database access and third-party APIs in the data layer.
- Make migration order, failures, and time inputs deterministic and testable.
- Avoid prematurely committing to background-isolate concurrency or iOS/web support.

## Options considered

### DuckDB with one app-scoped connection

Use `dart_duckdb` behind an owned `AppDatabase` contract. Resolve an app-private support-directory path, serialize access through the app connection, and use one transactional migration run on startup.

### DuckDB with multiple or isolate-owned connections immediately

This could increase throughput later, but introduces connection ownership, transaction coordination, and lifecycle complexity before measured need.

### In-memory or platform-specific storage fallback

This would violate the local-first source-of-truth requirement and would not prove Android restart durability.

## Decision

Use `dart_duckdb` 1.2.0 behind the data-layer `AppDatabase` contract. This exact version is retained because its Android native artifacts are available to the pinned build; dependency upgrades require another packaged-Android verification. The Android database file lives in the application support directory and uses one app-scoped connection, serialized at the owned adapter boundary. `dart_duckdb` itself runs connection work on a dedicated background isolate; ByteBeams will not add its own isolate or multiple connection model until a measured requirement is approved.

Database migrations are immutable, numbered SQL assets. A `schema_migrations` table records the version, migration name, and clock-provided UTC application time. All pending migrations run in one DuckDB transaction. A failure rolls back pending migration SQL and version records, reports a typed safe failure, and never deletes the database.

The first supported upgrade is a new version-0 database to version 1. Future migrations must test at least the immediately previous production schema version.

`Clock` and `IdGenerator` are application-owned contracts. Only the clock is used in this milestone; a concrete ID generation strategy remains deferred until a feature actually needs generated IDs.

## Consequences

- DuckDB, `path_provider`, and `path` stay behind application-owned data-layer contracts.
- Domain and presentation code do not import DuckDB or path-provider packages.
- An Android integration test is included to prove a write survives close and reopen in app-private storage on the configured Android device runner.
- iOS and web are not yet supported claims; each needs independent persistence validation.
- A single connection is intentionally conservative. A future multi-isolate design needs a new ADR and concurrency/transaction tests.
- The current Android build emits a third-party `dart_duckdb` Kotlin Gradle Plugin compatibility warning. No native code is added here; reassess the package before the Flutter built-in Kotlin migration becomes mandatory.

## Validation

- Unit tests cover adapter lifecycle, parameter binding, transaction rollback, clean creation, no-op migration reruns, duplicate migration rejection, unsupported-version handling, and rollback of a failed pending migration. The adapter is exercised through an owned DuckDB driver boundary so host tests do not depend on a desktop native binary.
- The Android integration test opens an app-private DuckDB file, writes a probe row, closes, reopens, and reads the row. It passed through `pnpm test:flutter:integration` and remains configured for the Android device runner after merge to the default branch.
- Flutter analysis, tests, Android debug build, and generated-code validation run in CI/local validation.

## Follow-up

- Add feature schema only with the feature that owns it.
- Plan database-change notification, sync cursor state, and event-time ingestion in Milestone 5.
- Verify iOS and web storage separately before enabling either as a supported target.
