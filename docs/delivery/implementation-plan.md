# Implementation Plan

## Purpose

This roadmap orders the approved product into small, verifiable delivery milestones. It is a sequencing document, not blanket authorization to implement every milestone. Before work starts on a milestone, follow `AGENTS.md`: inspect the affected code and documents, resolve that milestone's open decisions, present a concrete implementation plan, and receive explicit approval.

The infrastructure baseline is complete: pinned runtimes, Flutter and Node application shells, OpenAPI generation, quality commands, GitLab validation, smoke tests, and Android debug build are available.

## Status model

Use exactly one status for each milestone:

- `NOT STARTED`: no approved implementation is in progress.
- `PLANNED`: the milestone-specific plan and decisions are approved.
- `IN PROGRESS`: implementation has started.
- `BLOCKED`: a recorded decision or external dependency prevents progress.
- `COMPLETE`: acceptance criteria and applicable Definition of Done checks pass.

Update status only when repository evidence supports it. A milestone is not complete merely because its happy path works.

## Delivery principles

- Deliver dependencies before their consumers and prefer demonstrable vertical slices once persistence and ingestion exist.
- Keep DuckDB authoritative for mobile fleet state; presentation state is never a shadow source of truth.
- Treat event time, idempotency, restart recovery, and deterministic identities as first-class correctness requirements.
- Add numbered migrations with the feature that needs them; do not create speculative schema.
- Keep generated transport models separate from domain models.
- Maintain at least 90% line coverage and run the checks applicable to every milestone.
- Android is the first supported demo target. Do not claim iOS or web storage support until separately verified.
- Do not add handwritten Swift or Kotlin without separate approval and an ADR.

## Milestone 1: delivery hygiene

**Status:** `COMPLETE`

**Goal:** Make contribution and commit validation deterministic before feature work expands.

**Scope**

- Enforce Conventional Commits with pinned Node tooling and merge-request validation.
- Use `<type>(optional-scope): <imperative summary>` and support `<type>(scope)!: <summary>` with a `BREAKING CHANGE:` footer.
- Allow types `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `build`, `ci`, `perf`, and `style`.
- Allow scopes `mobile`, `server`, `contracts`, `tooling`, `docs`, `ci`, and `workspace`.
- Enforce a header under 72 characters, lowercase type, no trailing period, and rejection of vague subjects such as `update`, `changes`, `fix bug`, and `wip`.
- Document valid and invalid examples. Do not rewrite existing history.

**Acceptance criteria**

- A version-controlled commit-message hook validates new local commits after documented setup.
- GitLab validates commits introduced by a merge request.
- Automated fixtures prove representative valid, invalid, scoped, and breaking messages.
- Existing formatting, generation, test, and build commands remain green.

**Decisions:** Husky installs the version-controlled hook. GitLab validates the complete merge-request range from `CI_MERGE_REQUEST_DIFF_BASE_SHA` through `CI_COMMIT_SHA` with an unshallowed checkout.

## Milestone 2: DuckDB feasibility and persistence foundation

**Status:** `COMPLETE`

**Goal:** Retire the highest-risk local-first dependency before building features on it.

**Scope**

- Verify `dart_duckdb` persistence and packaged binaries on Android using the pinned Flutter toolchain.
- Introduce application-owned database lifecycle and transaction contracts.
- Add a schema-version table and immutable numbered DuckDB migrations.
- Prove create, migrate, close, reopen, and read-back behavior on disk.
- Establish injected clock and deterministic ID boundaries needed by later projections.
- Record material database/bootstrap decisions in an ADR.

**Acceptance criteria**

- An Android integration test writes data, closes the database, reopens it, and reads the same data.
- Clean creation, no-op reopen, and supported upgrade paths are tested.
- Migration failure is diagnostic and never deletes the database automatically.
- No UI or repository treats an in-memory collection as authoritative.

**Excluded:** fleet feature schema, network synchronization, iOS/web support claims, and product screens.

**Resolved decisions:** use the application-support directory, one serialized app-scoped connection, one transaction for pending migrations, and support version-0-to-1 now; each future migration must test the immediately preceding production version. See ADR 0001. Android device-runner integration evidence passed via `pnpm test:flutter:integration`.

## Milestone 3: domain and telemetry model

**Status:** `COMPLETE`

**Goal:** Define the stable language and validation boundaries used by persistence, transport, and features.

**Scope**

- Define immutable domain models for vehicles, packets, supported signals, location, classification, and UTC timestamps.
- Define repository contracts, failures/results, validators, DTO-to-domain mapping, and stable conflicting-event ordering.
- Persist raw valid, invalid, unsupported, and quarantined records with the required diagnostic fields.
- Enforce `packet_id` idempotency and exactly one signal per packet.
- Exclude invalid, unsupported, and quarantined data from derived state.

**Acceptance criteria**

- Boundary-value tests cover every supported signal and classification.
- Duplicate packet ingestion is idempotent.
- Raw invalid values and validation errors remain queryable after restart.
- Equal/conflicting timestamp behavior is documented and deterministic.

**Resolved decisions:** validate the approved lowercase signal catalog and units in `data-and-sync.md`; accept future event timestamps up to five minutes and quarantine arrivals more than 30 days old by event time; preserve opaque nonblank identifiers; and order conflicts by event timestamp, server receipt time, then packet ID. Use domain-owned Freezed `Result` and `TelemetryFailure` unions.

**Validation evidence:** Flutter unit tests passed with 95.09% line coverage. Android integration tests passed, including classified invalid telemetry persisted through close/reopen and restored through diagnostics.

## Milestone 4: deterministic demo backend

**Status:** `COMPLETE`

**Goal:** Supply reproducible registry, bootstrap, and live telemetry transport for the local-first client.

**Scope**

- Add numbered SQLite migrations and a schema-version table.
- Build deterministic fixtures for approximately 500 vehicles.
- Implement `GET /bootstrap` as a consistent registry, backfill, and delivery-cursor boundary.
- Implement a bounded persisted SSE delivery log and `/telemetry` replay using `Last-Event-ID`.
- Simulate normal, delayed, out-of-order, duplicate, missing-interval, and backlog delivery.
- Return an explicit replay-gap result when the requested cursor is unavailable.

**Acceptance criteria**

- Backend restart preserves the bounded delivery log and cursor continuity.
- Identical seeds and scripted time produce identical fixtures and delivery sequences.
- API, SQLite migration, SSE reconnect, replay-gap, and contract tests pass.
- The backend is documented as demo transport, not mobile fleet truth.

**Resolved decisions:** use SQLite at the configured demo path; retain at most 10,000 deliveries and seven days; use seed `bytebeams-demo-v1` with a scripted start time and one-second cadence; return the existing HTTP 409 `replay_gap` contract; and bootstrap exactly 500 vehicles with 24 hours of history. Validation evidence is required before completion.

**Validation evidence:** server formatting, linting, type checking, coverage tests, build, OpenAPI lint, and generated-code freshness all passed.

## Milestone 5: mobile ingestion and synchronization

**Status:** `COMPLETE`

**Goal:** Make DuckDB-backed state converge from bootstrap and SSE while remaining immediately usable offline.

**Scope**

- Open DuckDB and expose persisted state before starting network work.
- Import bootstrap registry, telemetry, and cursor atomically.
- Connect and reconnect SSE using the persisted delivery cursor and `Last-Event-ID`.
- Atomically persist/deduplicate each delivery, update affected projections, then advance the cursor.
- Surface bootstrap failure, replay gap, and an explicit **Use demo data** fallback.
- Notify interested components after commits without making event payloads authoritative.

**Acceptance criteria**

- Returning installs render persisted data before synchronization finishes.
- Fresh bootstrap has no cursor gap between snapshot and SSE.
- Duplicate, late, out-of-order, reconnect, backlog, process restart, and failed-transaction tests pass.
- A failed packet transaction never advances the processed cursor.
- Killing and relaunching the app restores all successfully ingested knowledge from DuckDB.

**Resolved decisions:** publish payload-free `FleetDataCommitted` events asynchronously after successful DuckDB commits; reconnect at 1, 2, 4, 8, then 15 seconds with no jitter; preserve local data on replay gap and offer an explicit backend refresh; and offer explicit packaged demo-data import only after fresh bootstrap failure. Android emulator traffic uses `10.0.2.2`; other local platforms use `localhost`.

**Validation evidence:** Flutter analysis passed. The Flutter unit suite passed with its configured 90% line-coverage gate. The suite includes deterministic HTTP/SSE transport, transactional DuckDB-store, replay-gap, retry, local-first startup, and durable duplicate-delivery behavior tests. Android integration coverage was added for persisted delivery cursor and deduplication.

## Milestone 5.5: Sparkee Design System Foundation

**Status:** `COMPLETE`

**Goal:** Establish the mandatory light-only Sparkee design system before product UI work.

**Scope:** semantic subtle-blue tokens, typography, Material 3 light theme, reusable operational primitives, accessibility contracts, and an internal component catalogue.

**Acceptance criteria:** all product UI consumes Sparkee tokens/components; status has text/icon semantics in addition to colour; light theme is complete and dark theme remains out of scope; component widget tests pass.

## Milestone 6: fleet home vertical slice

**Status:** `COMPLETE`

**Goal:** Deliver the primary fleet-operator screen entirely from DuckDB-backed queries.

**Scope**

- Implement the fleet repository query, use case, BLoC, route, page, and focused widgets.
- Show registration, model, SOC, range, alert badge, and required status chip.
- Compute live `All`, `Moving`, `Idle`, `Stopped`, and `Offline` counts in SQL.
- Implement documented status precedence and deterministic missing-input fallbacks.
- Cover loading, populated, empty-filter, syncing, degraded, and failure states.

**Acceptance criteria**

- Exactly 10-minute-old valid `last_ping` is online; only explicit valid `last_ping` affects connectivity.
- Speed and ignition follow the documented status rules even when individually stale.
- Filtering and counts update after committed database changes and survive restart.
- Unit, SQL integration, BLoC, widget, and Android flow tests pass.

**Decisions before implementation:** fleet-row visual design, database query observation strategy if still open, and approved accessibility target.

**Validation evidence:** Flutter analysis, formatting validation, and the Flutter unit suite passed with the configured 95.52% line-coverage gate. Android integration tests passed. Fleet Home tests cover SQL-query contracts and repository mapping, filter/status rules, BLoC refresh/failure/sync transitions, Sparkee accessibility primitives, widget states, routing, and the Android application smoke flow.

## Milestone 7: vehicle detail vertical slice

**Status:** `IN PROGRESS`

**Goal:** Explain a vehicle's latest condition and retained SOC history.

**Scope**

- Query the latest valid SOC, range, speed, battery temperature, odometer, and `last_ping` independently.
- Show each signal's value, age, and `NORMAL`, `ALERT`, or `STALE` verdict; never-reported signals show `—` with no pill.
- Query and render the default 24-hour SOC history from the event log.
- Add navigation from fleet home to detail.

**Acceptance criteria**

- Freshness and threshold boundaries are covered with an injected clock.
- Invalid and unsupported readings never become latest derived readings.
- SOC history is event-time ordered and queried from DuckDB.
- Unit, query integration, BLoC, widget, and navigation tests pass.

**Resolved decisions:** use an accessible event-time SOC table for the retained 24-hour window. Format values to at most one decimal place, trim trailing `.0`, and use grouped odometer values. Display reading age relative to the injected UTC clock.

## Milestone 8: alerts vertical slice

**Status:** `NOT STARTED`

**Goal:** Produce durable alert episodes with escalation, dismissal, resolution, and Undo behavior.

**Scope**

- Derive low-battery and overheating episodes from fresh valid readings.
- Treat SOC Warning and Critical as one escalating logical alert.
- Persist alert lifecycle, ordered dismissal reasons, dismissal state, and wall-clock Undo expiry.
- Resolve independently when conditions clear; escalation overrides Warning dismissal.
- Expose alerts to fleet/detail presentation through repositories and use cases.

**Acceptance criteria**

- Threshold boundaries, episode recurrence, escalation, clearing, dismissal, and restart behavior are deterministic.
- Undo within five wall-clock seconds reverses persisted dismissal; expired Undo does not reappear after background/restart.
- BLoCs re-query DuckDB after relevant app-level events.
- Unit, DuckDB integration, BLoC, widget, and end-to-end tests pass.

**Decisions before implementation:** alert-history UI extent and exact wall-clock presentation around Undo expiry.

## Milestone 9: geofences vertical slice

**Status:** `NOT STARTED`

**Goal:** Manage versioned circular geofences and deterministic current membership without a map.

**Scope**

- Create, edit, deactivate, seed, and persist geofence versions using prospective effective intervals.
- Retain deactivated and historical definitions.
- Determine event-time membership using two supporting readings, hysteresis, accuracy rejection, and deterministic overlap selection.
- Show current vehicle membership and live counts.

**Acceptance criteria**

- Initial observation establishes a baseline without a transition.
- Margin is `max(20 m, reported accuracy)` capped at 75 m; readings worse than 100 m cannot confirm transitions.
- Boundary-zone readings neither confirm nor reset state.
- Overlaps resolve by smallest radius, shortest centre distance, then stable `geofence_id`.
- CRUD, version history, jitter, inaccurate GPS, overlap, missing interval, late-event, and restart tests pass.

**Decisions before implementation:** geofence management screen design, input validation bounds, and seeded geofence coordinates.

## Milestone 10: automatic trips vertical slice

**Status:** `NOT STARTED`

**Goal:** Build idempotent event-time trips from confirmed geofence transitions.

**Scope**

- Emit direct `A → B` as exit A followed by entry B.
- Start on confirmed exit and complete on the next confirmed entry.
- Retain an in-progress trip without entry and allow same-origin return.
- Retain extra exits while enforcing one active trip per vehicle.
- Replay affected event-time windows for late packets and upsert revised transitions/trips.
- Use deterministic `trip_id = deterministic(vehicle_id + exit_transition_id)`.

**Acceptance criteria**

- Transition time is the first supporting reading once the second reading confirms it.
- Duplicate replay creates no duplicate transition or trip.
- Late data may revise start, end, origin, or destination visibly and deterministically.
- Trips, transitions, and geofence versions survive restart and are retained.
- Algorithm, DuckDB replay, invariant, BLoC, widget, and end-to-end tests pass.

**Decisions before implementation:** trip-list/detail presentation and bounded replay-window optimization that preserves correctness.

## Milestone 11: retention and replay hardening

**Status:** `NOT STARTED`

**Goal:** Prove correctness under prolonged, adversarial telemetry delivery and cleanup.

**Scope**

- Apply 30-day event-time retention to valid, invalid, and unsupported raw telemetry.
- Retain already-too-old quarantined arrivals for 30 days by receipt time.
- Preserve trips, transitions, alert history, dismissals, and geofence versions.
- Prevent cleanup from racing unfinished replay and validate projection rebuilds.
- Exercise large backlogs and late revisions across cleanup boundaries.

**Acceptance criteria**

- Cleanup is idempotent and never removes required retained history.
- Eligible events affect derived state before raw expiry.
- Projection rebuilds reproduce the same state from the same retained inputs.
- Performance and database-size measurements are recorded for representative data.

**Decisions before implementation:** cleanup trigger/schedule, replay locking strategy, and performance budgets.

## Milestone 12: demo readiness

**Status:** `NOT STARTED`

**Goal:** Turn the completed slices into a reliable, explainable Android interview demonstration.

**Scope**

- Validate usability and performance with approximately 500 vehicles.
- Complete accessibility semantics, keyboard/focus behavior where relevant, and responsive layout checks.
- Add application-owned analytics contracts with no-op and debug adapters; do not add an external vendor.
- Run the full deterministic scenario set and Android end-to-end suite.
- Prepare setup instructions, architecture explanation, known limitations, and a concise demo script.
- Reassess iOS/web DuckDB compatibility separately without weakening Android persistence.

**Acceptance criteria**

- A clean checkout follows documented setup and builds the demo.
- Required CI, coverage, generation, migration, Android integration, and build jobs pass.
- No secrets or raw telemetry appear in logs or analytics.
- The demo works offline from persisted state and visibly handles reconnect/backlog scenarios.
- README and architecture documents match implemented behavior and explicitly list remaining limitations.

**Decisions before implementation:** final visual design, localization scope, analytics event catalogue, performance budgets, and whether iOS/web become supported demo targets.

## Milestone dependency sequence

```text
1 Delivery hygiene
  → 2 DuckDB feasibility
    → 3 Domain and telemetry model
      ├→ 4 Demo backend
      └→ 5 Mobile ingestion (also depends on 4)
          → 6 Fleet home
            → 7 Vehicle detail
              → 8 Alerts
          → 9 Geofences
            → 10 Trips
              → 11 Retention and replay hardening
                → 12 Demo readiness
```

Minor presentation work may overlap after its repository contracts are stable, but dependent correctness work must not bypass the sequence.

## Milestone planning checklist

Before changing a milestone from `NOT STARTED` to `PLANNED`, its implementation proposal must state:

1. Confirmed outcome and acceptance criteria.
2. Included and excluded scope.
3. Resolved open decisions and any ADR required.
4. Affected mobile/backend layers and dependency direction.
5. Schema, migration, retention, event-time, and restart impact.
6. Failure, accessibility, security, and analytics behavior where applicable.
7. Unit, widget, BLoC, database, backend, contract, integration, and end-to-end tests that apply.
8. Formatting, analysis, generation, test, migration, and build commands to run.

See `docs/delivery/definition-of-done.md` for the completion gate applied to every milestone.
