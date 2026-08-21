# Architecture Overview

## Runtime components

```text
Node demo server
  ├── HTTP bootstrap
  ├── deterministic telemetry simulator
  └── persisted SQLite SSE delivery log
             ↓
Flutter ingestion and data adapters
             ↓
DuckDB transaction and deterministic projections
             ↓
domain repositories and use cases
             ↓
BLoCs
             ↓
Flutter UI
```

The mobile app is local-first. Network success enriches DuckDB; it is not required to render previously known fleet state.

## Planned monorepo

```text
apps/mobile
apps/server
contracts/openapi.yaml
packages/                  only after demonstrated sharing
docs/
```

The backend and mobile app own separate runtime concerns. OpenAPI is their transport-contract source of truth. Generated transport types do not replace domain models.

## Mobile feature boundaries

Initial candidate features are `fleet`, `ingestion`, `alerts`, `geofences`, and `trips`, plus a small `app` composition root and genuinely shared `core` primitives. Each feature contains only the clean-architecture layers it needs; do not create empty directories for symmetry.

## Data ownership

- Backend: registry/bootstrap fixtures, live simulation, replayable delivery log.
- DuckDB: ingested registry and telemetry plus all local and derived fleet state.
- BLoCs: ephemeral presentation state only.
- Preferences: non-sensitive UI settings only.
- Secure storage: genuinely sensitive values only; authentication is out of scope.

## Platform policy

Android is required first. iOS and web remain intended targets but require verified DuckDB binary and persistence behavior. No target may silently use an in-memory substitute. Native Swift or Kotlin requires explicit approval and an ADR documenting why Dart cannot satisfy the requirement.
