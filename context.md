# Project Context

## Product

This is an interview take-home demo for a fleet operator managing approximately 500 electric trucks. The product must answer on one screen: where are the vehicles, are they okay, and what needs attention now?

Vehicles send small telemetry packets over unreliable mobile links. Packets may be late, out of order, duplicated, missing, or delivered in a backlog after a vehicle reconnects.

## Glossary

- **SOC:** battery state of charge, expressed as a percentage.
- **Range:** estimated remaining driving distance in kilometres.
- **Signal:** one named vehicle parameter such as `soc`, `speed`, or `battery_temp`.
- **Packet:** one timestamped emission from one vehicle containing exactly one signal.
- **Stale:** a reading whose event timestamp is more than 10 minutes old.
- **Telemetry:** vehicle-generated signal packets only.
- **Analytics:** product events, diagnostics, performance measurements, errors, and crash reporting.
- **BLoC event:** a presentation input scoped to one BLoC.
- **Domain use case:** a business action or query invoked by a BLoC or application service.
- **App-level domain event:** a typed, asynchronous, past-tense business fact broadcast to interested modules.

## Repository scope

Planned monorepo boundaries:

```text
apps/mobile       Flutter application
apps/server       Node.js/TypeScript demo backend
contracts         OpenAPI source of truth
packages          added only when sharing is justified
docs              persistent product and engineering context
```

The application shells are scaffolded. The approved delivery sequence is maintained in `docs/delivery/implementation-plan.md`. Each milestone still requires its own planning conversation and explicit implementation approval.

Project identity:

- Display name: `ByteBeams`
- Dart package: `bytebeams`
- Android application ID: `com.bytebeams.fleet`
- iOS bundle identifier: `com.bytebeams.fleet`
- Node package: `@bytebeams/fleet`

## Confirmed technology

- Flutter `3.47.0`, pinned with FVM; Dart comes from the pinned Flutter SDK.
- Android is the first fully supported demo target. iOS and web remain intended targets, subject to DuckDB compatibility validation.
- Dart by default. Swift and Kotlin are prohibited without explicit approval and documented justification.
- `flutter_bloc`/BLoC, `get_it`, `dio`, `go_router`, `freezed`, and `json_serializable`.
- `dart_duckdb` `^1.2.0` for durable mobile fleet data, subject to compatibility verification during setup.
- Secure storage for genuinely sensitive values; shared preferences for non-sensitive settings. Both remain behind owned contracts.
- Node.js `24.19.0`, pinned in `.nvmrc`, `package.json`, and CI; TypeScript and pnpm `11.22.0`.
- FVM `4.1.4` and Java 17 are setup-tooling requirements.
- Express 5, Zod, and `better-sqlite3` are approved backend boundaries.
- SQLite for the backend's small persisted SSE delivery log.
- OpenAPI Generator `7.24.0` (`dart-dio`) and `openapi-typescript` generate committed Dart and TypeScript artifacts. The generated Dart client is colocated under `apps/mobile/generated/` and does not justify Melos by itself.
- GitLab CI.
- Repository-owned `analysis_options.yaml` beginning with `flutter_lints`.
- No Melos initially.

## Sources of truth and ownership

- The backend supplies the vehicle registry, bootstrap telemetry, and simulated live telemetry.
- DuckDB is authoritative for everything successfully ingested by the mobile app.
- The UI reads fleet state through DuckDB-backed repositories, never from an in-memory shadow source.
- Geofences, alert dismissals, transitions, and trips are local-device data persisted in DuckDB.
- Trips and geofence transitions are derived entirely on-device from persisted event-time history.
- The Node server is deterministic demo transport, not the mobile application's source of truth.

## Explicitly out of scope

- Authentication for this single-operator take-home.
- A vehicle map.
- Backend synchronization of geofences, dismissals, transitions, or trips.
- Production-grade SSE retention.
- External analytics vendors initially.
- Golden tests.
- Handwritten Swift or Kotlin implementation unless separately approved. Flutter-generated host-runner boilerplate is explicitly allowed.

## Working reminders

- Render existing DuckDB data immediately and synchronize in the background.
- Fresh installs use HTTP bootstrap followed by SSE. Demo fallback requires an explicit **Use demo data** action.
- Reconsider Melos when a second Dart/Flutter package exists, shared packages require coordinated commands, or workspace-wide dependency/version management becomes repetitive.
- Pin upgrades intentionally; never interpret “current stable/LTS” as permission for an automatic version change.
- Validate `dart_duckdb` persistence and binary support independently on Android, iOS, and web before claiming support. Do not silently replace storage on an unsupported target.

## Open decisions

Resolve these during the planning conversation for the relevant implementation:

- Future vehicle timestamp skew tolerance and quarantine behavior.
- Exact bounded size/age of the backend delivery log and replay-gap recovery UX.
- Exact mechanism that notifies database-backed UI queries after committed ingestion.
- Final visual design, accessibility targets beyond platform best practices, and localization scope.

## Documentation map

Start with `AGENTS.md` and `docs/delivery/implementation-plan.md`, then read product requirements, the relevant architecture document, engineering policy, and delivery requirements for the task. After planning confirms a responsibility and layer, use the applicable reference in `docs/templates/`. Templates are illustrative and must not create unused layers or placeholder classes.
