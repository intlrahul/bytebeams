# Respond to greeting

> Hi

Hi! What would you like to work on?

> i would like to start buiilding an app it is a demo app i am building as the test for a company for interview. and this is going to be the AI first development. what I need first is the good prompt to create basic AI foundation to create md files which would be context containing monorepo, best practices, rules, do and don'ts, statemanagement, clean archtecture with data, domain and presentation layer, testing strategies(unit and integration), telemetry (observability), CI steps etc. don't just start writing the code lets plan it first. Also add in the context that when a prompt is given first start the planning conversation, grab all the context and then when I say to write then start wrting the code. don't assume anything.&#x20;

You’re describing an “AI engineering constitution” for the repository: a small, maintainable set of Markdown files that tells an AI how to plan, implement, test, verify, and document every change.

I won’t create or modify any files until we finish the planning conversation and you explicitly say to write them.

## Proposed foundation

Rather than one enormous instruction file, I recommend a layered documentation system:

```text
/
├── AGENTS.md                         # Entry point and non-negotiable AI rules
└── docs/
    ├── product/
    │   ├── product-brief.md          # Problem, users, scope, success criteria
    │   └── requirements.md           # Functional/non-functional requirements
    ├── architecture/
    │   ├── overview.md               # System and monorepo architecture
    │   ├── clean-architecture.md     # Data/domain/presentation boundaries
    │   ├── state-management.md       # State ownership and data flow
    │   └── decisions/                # Architecture decision records
    ├── engineering/
    │   ├── coding-standards.md
    │   ├── testing-strategy.md
    │   ├── observability.md
    │   ├── security.md
    │   └── dependency-policy.md
    ├── delivery/
    │   ├── ci-cd.md
    │   └── definition-of-done.md
    └── workflows/
        ├── planning-and-execution.md
        └── pull-request-checklist.md
```

The exact structure should depend on the technology and app requirements. We may combine some files to avoid creating documentation that is impressive-looking but difficult to maintain.

## Core operating rule for the AI

The repository instructions should explicitly establish two separate modes.

### Planning mode

For every new implementation request, the AI must:

1. Read the repository instructions and relevant documentation.
2. Inspect the existing code and tests.
3. Restate the requested outcome.
4. Identify missing or ambiguous requirements.
5. Ask questions instead of silently choosing product or architecture behavior.
6. Discuss the implementation approach and alternatives.
7. Present a concrete plan, affected files, tests, risks, and acceptance criteria.
8. Wait for explicit authorization to implement.

### Implementation mode

Implementation begins only when you clearly say something such as:

- “Write the code.”
- “Implement the approved plan.”
- “Proceed with implementation.”

Once authorized, the AI should:

1. Follow the approved plan.
2. Avoid unrelated changes.
3. Preserve existing user changes.
4. Add or update tests.
5. Run the appropriate verification.
6. Report changes, validation results, and unresolved issues.
7. Return to planning if it discovers a requirement that would materially alter the agreed solution.

Small corrections should not require needless interrogation, but the AI must never invent product behavior, credentials, API contracts, architectural choices, or acceptance criteria.

## Prompt to generate the foundation

After we fill in the missing details, this can serve as the master prompt:

```text
You are helping establish the AI-first engineering foundation for a demo
application being created as part of a company interview.

Do not write application code or create files yet.

Begin with a planning conversation. Gather and confirm all required context
before proposing the final documentation. Do not silently assume product,
platform, architecture, tooling, API, testing, deployment, security, or
observability decisions.

Your first objective is to design a concise set of repository Markdown files
that will act as persistent context for human and AI contributors.

The documentation must cover:

- Product purpose, target users, demo scope, and success criteria
- Monorepo layout, package ownership, and dependency boundaries
- Engineering principles and best practices
- Mandatory rules, prohibited practices, and explicit exceptions
- Clean Architecture using data, domain, and presentation layers
- Dependency direction and communication between layers
- State-management conventions and state ownership
- Error handling and failure modeling
- Networking, persistence, caching, and offline behavior where applicable
- Dependency injection
- Navigation or routing
- Code-generation policy, if applicable
- Unit, integration, UI/component, and end-to-end testing strategy
- Test doubles, fixtures, coverage expectations, and test naming
- Telemetry and observability: logs, metrics, traces, crashes, and privacy
- Security, secrets, configuration, and sensitive-data handling
- Accessibility, performance, and localization expectations
- Formatting, linting, static analysis, and dependency checks
- CI validation stages and merge requirements
- Definition of done and pull-request expectations
- Architecture Decision Record conventions
- Instructions for keeping documentation synchronized with the code

The primary repository instruction file must define a two-phase workflow:

PHASE 1 — PLANNING
For each new request:
1. Read the applicable repository instructions and documentation.
2. Inspect the relevant existing implementation and tests.
3. Restate the objective and acceptance criteria.
4. Identify ambiguities, missing information, constraints, and risks.
5. Ask focused clarification questions.
6. Propose an implementation plan, affected areas, testing plan, and tradeoffs.
7. Wait for explicit implementation approval.

PHASE 2 — IMPLEMENTATION
Only begin editing files after the user explicitly says “write the code,”
“implement,” “proceed,” or gives equivalent unambiguous authorization.
During implementation:
1. Follow the approved plan and documented architecture.
2. Make only scoped changes.
3. Never overwrite unrelated user work.
4. Add or update appropriate tests.
5. Run relevant validation commands.
6. Report exactly what changed and what was verified.
7. Stop and return to planning if new information would materially change
   the approved design.

The instructions must also state:

- Do not invent requirements or claim unverified facts.
- Do not select a library, service, or architectural pattern without either
  existing repository evidence or explicit approval.
- Clearly label assumptions and request confirmation.
- Prefer the smallest maintainable design that satisfies the confirmed scope.
- Avoid speculative abstractions and premature generalization.
- Never expose secrets or sensitive user information in source control,
  logs, tests, screenshots, or telemetry.
- Do not declare completion when required checks are failing or were not run.
- Explain any check that could not be run.
- Treat tests and documentation as part of the feature.
- Record meaningful architectural decisions.
- Keep repository guidance concise, actionable, and non-duplicative.

Before drafting any files, ask me for all missing project decisions. Group the
questions into a small number of focused rounds. For each decision, explain
why it matters and offer reasonable options without selecting one for me.

After the discovery conversation:
1. Summarize the confirmed decisions.
2. Identify any remaining assumptions.
3. Propose the exact documentation tree.
4. Outline the purpose and contents of each file.
5. Wait for my explicit approval.
6. Create the files only after I instruct you to write them.

Known project context:

- Product: [TO BE CONFIRMED]
- Target platforms: [TO BE CONFIRMED]
- Language/framework: [TO BE CONFIRMED]
- Repository state: [NEW / EXISTING — TO BE CONFIRMED]
- Backend/API: [TO BE CONFIRMED]
- Persistence/offline requirements: [TO BE CONFIRMED]
- State management: [TO BE CONFIRMED]
- CI provider: [TO BE CONFIRMED]
- Deployment/distribution: [TO BE CONFIRMED]
- Observability tooling: [TO BE CONFIRMED]
- Interview constraints and deadline: [TO BE CONFIRMED]
```

## First discovery round

Please tell me:

1. What does the app do, who uses it, and what must the demo demonstrate?
2. Is this Android, iOS, Flutter, React Native, web, backend, or a combination?
3. Which language and framework are required or preferred?
4. Is the current repository empty, or does it already contain code/configuration?
5. Why do you want a monorepo—what applications or packages should it contain?
6. Is an API supplied by the company, mocked locally, or part of what you must build?
7. What are the interview deadline, evaluation criteria, and any stated restrictions?
8. Have you already selected state management, dependency injection, networking, database, CI, and telemetry tools, or should we compare options during planning?

Once those are answered, we can design the architecture and documentation tree without guessing. No files have been changed.

> What does the app do, who uses it, and what must the demo demonstrate? - we will add more details going forward. lets start with this for now
>
> 1. Context
>    A fleet operator with 500 electric trucks needs one screen answering: where are my vehicles, are they okay, what
>    needs attention now.
>    Vehicles emit telemetry — small sensor packets over a flaky mobile link. Packets arrive late, out of order,
>    duplicated, or not at all. Vehicles park in basements for hours and then dump a backlog.
>    Glossary. SOC — battery state of charge, %. Range — estimated km remaining. Odometer — lifetime km. Ignition
>    — vehicle switched on. Signal — one named telemetry parameter (soc, speed, battery\_temp, ...). Packet — one
>    timestamped emission from one vehicle, carrying a subset of signals. Stale — last report too old to trust.
>
> 2. Architecture requirement — local-first over DuckDB
>    The app is local-first. Telemetry is written to an embedded DuckDB database on device (dart\_duckdb, currently
>    ^1.2.0 — ships its own binaries, works on Android). The UI reads from DuckDB. It does not read from an
>    in-memory list that DuckDB happens to shadow. If you kill the app and relaunch it, everything the app knew must
>    come back off disk.
>
> 3. Features
>    A — Fleet home
>    List of all vehicles: reg number, model, SOC, range, alert badge, and a status chip (first match wins):
>    Status Rule
>    OFFLINE vehicle-level last ping older than 10 min
>    MOVING speed > 0
>    IDLE speed = 0 and ignition on
>    STOPPED ignition off
>    Filter chips (All / Moving / Idle / Stopped / Offline) with live counts, computed in SQL. Empty
>    results get an empty state.
>
> BYTEBEAM HIRING Page 2
> B — Vehicle detail
> A readings register: one row per signal (SOC, range, speed, battery temperature, odometer, last ping) with label,
> value, its own age, and a verdict pill — NORMAL (fresh, within threshold), ALERT (fresh, outside threshold), STALE
> (grey, too old to judge, no normal/alert claim). A signal that has never reported shows "—" with no pill.
> Include a history sparkline or table for SOC over the retained window. You are storing an event log; show that
> you can query it.
> C — Alerts, dismissal, undo
> Thresholds, on fresh readings only:
> Alert Condition Severity
> Low battery SOC < 20% Warning
> Battery critically low SOC < 10% Critical
> Battery overheating battery temp > 45 °C Critical
> The two SOC alerts are one escalating alert, not two. Dismissal opens a reason sheet — "I am on it", "Wrong
> alert", "Something else...", in that order — removes the alert and shows UNDO for 5 seconds. A condition that
> clears resolves its alert independently of dismissal.
> D — Geofences
> Create, edit, and deactivate persisted circular geofences (name, centre, radius, active state), and show each
> vehicle’s current geofence plus live vehicle counts; seed at least three and retain deactivated geofences for trip
> history.
> Determine entry and exit from event-time location history using a documented deterministic strategy for duplicates,
> late packets, GPS jitter, inaccurate readings, overlaps, missing intervals, and geofence edits.
> E — Automatic trips
> Build trips automatically from confirmed geofence transitions:
> Transition Result
> Confirmed exit Start a trip
> Next confirmed entry Complete the active trip
> No confirmed entry Keep it IN PROGRESS
> Returning to the origin geofence is valid, and a vehicle may have only one active trip. Processing must be
> idempotent and event-time aware: duplicate packets create nothing twice, while late packets may revise trip
> boundaries or destinations without producing duplicate trips.
>
> Is this Android, iOS, Flutter, React Native, web, backend, or a combination?
>
> flutter based - ios android web also i would like to setup a simple nodejs backend server which would provide the apis to be consumed by the app.&#x20;
>
> Which language and framework are required or preferred?
>
> dart mostly - using swift/ kotilin is strictly no until dev says so. and there has to be valid reasoning that why native code is being written.&#x20;
>
> Is the current repository empty, or does it already contain code/configuration?
>
> I am starting this app from scratch for both frontend and backend. backend is mostly hardcoded to make the app demoable.&#x20;
>
> Why do you want a monorepo—what applications or packages should it contain?
>
> i want to keep things simple - if requirement comes that I need to provide a shared code i would write the package which can be shared across.&#x20;
>
> as of now lets contain flutter related packages, unit test packages, dart\_duckdb, and rest we will add as we make more decisions&#x20;
>
> Is an API supplied by the company, mocked locally, or part of what you must build?
>
> we are going to have our own backend for it. it would be simple, mostly hardcoded and nodejs based&#x20;
>
> What are the interview deadline, evaluation criteria, and any stated restrictions?
>
> this i will manage by myself&#x20;
>
> Have you already selected state management, dependency injection, networking, database, CI, and telemetry tools, or should we compare options during planning?
>
> Clean Architecture + BLoC for screens for example GetAllVehicles, SubmitPayment, RetryPayment which are meant for a specific screen  + typed Domain Event Bus for global events for example PaymentCompleted, CardBlocked , KycApproved where events needs to know by other modules. - this would decouple the two screens or modules.&#x20;
>
> dependency injection: get\_it , networking: dio, database: dart\_duckdb for vehicle Telemetry, keychain/ keystore for critical user details. and shared prefs for rest. but all these have to behind abstract class. and not to use directly by the app layer,&#x20;
>
> CI we would use gitlab and observabilty - lets create the abstract class with contract will decide later which one to use later.&#x20;

This is enough to establish the product direction and begin architecture planning. I’ll keep every undecided point explicit, and I won’t create files or code until you authorize it.

## Confirmed context

The system will be a local-first fleet operations demo for approximately 500 electric trucks. Its main screen must answer:

- Where are the vehicles?
- Are they operating normally?
- What requires attention now?

Telemetry is unreliable by nature: packets may be delayed, duplicated, missing, out of order, or delivered in a backlog.

The repository will initially contain:

```text
apps/
  mobile/       Flutter application
  server/       Simple Node.js demo API

packages/       Added only when code is genuinely shared
```

The exact names remain open. Tests would normally live beside the code they verify rather than in a separate “unit test package,” unless there is a concrete reason for shared test utilities.

## Confirmed technical decisions

- Flutter and Dart for Android, iOS, and web.
- No Swift or Kotlin without explicit approval and documented justification.
- Node.js demo backend with mostly deterministic/hardcoded data.
- Clean Architecture with presentation, domain, and data layers.
- BLoC-based presentation state.
- Typed domain event bus for meaningful cross-module events.
- `get_it` for dependency injection.
- `dio` for networking.
- `dart_duckdb` for persistent telemetry and derived fleet data.
- Secure platform storage for sensitive information.
- Shared preferences for appropriate non-sensitive settings.
- Infrastructure libraries must remain behind application-owned abstractions.
- GitLab CI.
- Vendor-neutral observability contracts initially; provider selected later.
- Avoid packages and abstractions until they solve a demonstrated need.

## Important architectural distinction

Examples such as `GetAllVehicles`, `SubmitPayment`, and `RetryPayment` sound like domain use cases, not BLoCs.

A likely separation would be:

```text
Presentation
  FleetBloc
  VehicleDetailBloc
  AlertsBloc
  GeofencesBloc

Domain use cases
  GetAllVehicles
  GetVehicleDetails
  DismissAlert
  UndoAlertDismissal
  ProcessTelemetryPacket
  RebuildVehicleTrips
```

A screen or feature BLoC invokes domain use cases. The use cases depend on repository abstractions, never on DuckDB, Dio, `get_it`, or Flutter APIs.

The typed event bus should be reserved for events that genuinely cross feature boundaries. It should not replace direct BLoC events, use-case results, database observation, or normal method calls. Otherwise, system behavior becomes difficult to trace and test.

## Proposed dependency direction

```text
Presentation → Domain ← Data
                    ↑
             Infrastructure
```

More precisely:

- Presentation knows domain types and use cases.
- Domain knows no Flutter, DuckDB, Dio, preferences, or secure-storage APIs.
- Data implements domain repository contracts.
- Infrastructure adapters wrap third-party packages.
- Dependency registration is confined to the composition root.
- The backend is a separate application and does not share runtime state with Flutter.
- DuckDB is the Flutter app’s durable source of truth.
- UI state is derived from database-backed queries or streams.
- BLoCs may cache ephemeral presentation state, but not authoritative fleet state.

## Local-first data flow

A provisional flow—not yet an approved design—is:

```text
Node demo API
    ↓ packets
Sync/ingestion adapter
    ↓ validated events
DuckDB transaction
    ├── raw telemetry event log
    ├── latest signal projection
    ├── alert state
    ├── geofence transitions
    └── trips
         ↓
SQL queries / repositories
         ↓
Domain use cases
         ↓
BLoCs
         ↓
UI
```

The raw event log should remain immutable where practical. Current vehicle state, alerts, transitions, and trips can be deterministic projections derived from that log. This gives us a defensible way to handle late data and idempotent reprocessing.

However, we still need to decide whether projections are persisted tables, SQL views, or a hybrid.

## Decisions that require special treatment

Several requirements need explicit algorithms rather than broad “best practice” language:

- Packet identity and duplicate detection
- Event time versus ingestion time
- Per-signal latest-value selection
- Vehicle-level last-ping calculation
- Signal staleness
- Alert escalation, resolution, dismissal, and undo
- Geofence overlap and boundary behavior
- GPS jitter and inaccurate readings
- Late location events that revise transitions
- Trip identity and deterministic reconstruction
- Behavior after geofence edits or deactivation
- Web compatibility and persistence strategy for the selected DuckDB integration

These should eventually become Architecture Decision Records because they materially affect correctness.

## Discovery round 2: data and correctness

Please define or confirm the following.

### 1. Packet contract

What fields should every packet contain?

A reasonable candidate to evaluate is:

```text
packetId
vehicleId
eventTimestamp
serverReceivedTimestamp
signals {
  soc?
  rangeKm?
  speedKph?
  batteryTemperatureC?
  odometerKm?
  ignition?
  latitude?
  longitude?
  gpsAccuracyMeters?
}
```

Key questions:

- Does the source provide a globally unique `packetId`?
- Can two legitimate packets have the same vehicle and event timestamp?
- Are timestamps UTC?
- Can a packet contain only one signal?
- Should invalid signal values be rejected, stored as invalid, or quarantined?

### 2. Sync behavior

How should the mobile app obtain telemetry?

- Poll an HTTP endpoint periodically?
- Manual refresh for the demo?
- Stream over WebSocket/SSE?
- A combination of initial HTTP sync and live updates?

We also need a stable pagination/cursor contract so that relaunching the app does not redownload or lose packets.

### 3. Freshness rules

We know a vehicle is offline when its last ping is more than 10 minutes old, but signal-level staleness is not defined.

Should all signals use the same freshness window, or should it vary? For example, speed may become untrustworthy much sooner than odometer.

Also:

- Is exactly 10 minutes old still online or already offline?
- Is “last ping” the latest packet event time or server receipt time?
- Does any packet update the vehicle ping, even if it contains no recognized signals?

### 4. Status with missing values

The first-match rules are clear once values exist, but these cases need decisions:

- Fresh ignition exists but speed has never reported.
- Fresh speed exists but ignition has never reported.
- Speed is stale but the vehicle ping is fresh.
- Ignition is stale but speed is fresh.
- Speed is negative or extremely small because of sensor noise.

Should status use the last known values regardless of signal staleness, or become `UNKNOWN` when required inputs cannot be trusted? The current specification does not include `UNKNOWN`, so we should not introduce it without confirmation.

### 5. Alert lifecycle

Please confirm:

- Does a dismissed alert remain dismissed while the same condition continues?
- If the condition clears and later returns, should it create a new alert?
- If a low-battery warning is dismissed and SOC later falls below 10%, should it reappear as Critical?
- Is dismissal persisted across app restarts?
- Does Undo merely restore the alert, or also remove the stored dismissal record?
- Is the five-second Undo window based on wall-clock time and allowed to expire while the app is backgrounded?

### 6. Geofence transition strategy

Do you want us to design and document the deterministic strategy, or has the company supplied one?

A robust candidate could consider:

- GPS accuracy before accepting a point.
- A boundary tolerance to prevent jitter.
- Multiple consecutive inside/outside readings before confirming a transition.
- Event-time ordering.
- Deterministic winner when geofences overlap.
- Replay from an affected time when a late event arrives.

We should select exact rules and numbers deliberately rather than invent them during implementation.

### 7. Geofence edits

When a geofence’s centre or radius changes, should historical telemetry be interpreted using:

- The definition that existed when the location event occurred; or
- The newest definition, causing historical transitions and trips to be recalculated?

Retaining versioned geofence definitions is more defensible for historical trip accuracy, but it adds complexity.

### 8. Demo platform priority

Although the stated targets are Android, iOS, and web, which platform must be fully demonstrated first?

We should separately validate the selected DuckDB package’s support and durable-storage behavior on each target before promising identical functionality across all three. If DuckDB cannot satisfy one target, we will need an explicitly approved platform adapter or reduced target scope rather than silently substituting storage.

After this round, the next planning step will cover feature/module boundaries, backend simulation scenarios, database projections, and the testing pyramid. No repository files have been changed.

> there is a confusion i think. Vehicles emit telemetry is called telemetry also we are calling observability telemetry as well. lets call observability as analytics not telemtry.&#x20;

Agreed. We’ll reserve **telemetry** exclusively for vehicle sensor data.

For operational instrumentation, the documentation and code vocabulary will use **analytics**:

- Vehicle telemetry: SOC, speed, location, temperature, odometer, ignition, and packet timing.
- Analytics: application events, diagnostics, performance measurements, errors, and crashes.
- Analytics provider: the future vendor integration.
- Analytics contract: the domain-safe/application-owned abstraction hiding that provider.

Where precision is needed, analytics can be divided into:

- Product analytics: user actions and feature usage.
- Diagnostics: structured application logs and errors.
- Performance analytics: timing and responsiveness.
- Crash reporting: fatal and non-fatal failures.

Proposed naming:

```dart
abstract interface class AnalyticsService {}
abstract interface class DiagnosticsReporter {}
abstract interface class CrashReporter {}
abstract interface class PerformanceMonitor {}
```

I’ll avoid names such as `TelemetryService` or `TelemetryTracker` for observability concerns. “Telemetry” will always mean vehicle-generated packets and signals throughout the repository documentation.

This vocabulary decision should be recorded in the glossary and engineering rules. No files have been changed.

> there is one more confusion domain use cases and domain events via events bus. so yes for making the api calls `GetAllVehicles` `SubmitPayment` `RetryPayment` would be domain use cases but there would be bloc events to invoke those use cases. event bus events are the events which needs to dispatch at the app level like PaymentCOMPLETED for exapmple if dashboardBloc, PaymentBloc or someother bloc needs to listen this event.&#x20;

Yes, the distinction is now clear. We have three separate concepts, and the repository guidance must prevent them from being mixed.

## 1. Domain use cases

Use cases represent business operations or queries:

```text
GetAllVehicles
GetVehicleDetails
DismissAlert
RetryPayment
SubmitPayment
```

They are invoked by BLoCs, depend on domain repository contracts, and return domain results or failures.

A use case does not go on an event bus.

## 2. BLoC events

BLoC events are presentation-layer inputs scoped to a particular BLoC:

```text
FleetRequested
FleetFilterChanged
VehicleRefreshRequested
PaymentSubmitted
PaymentRetryRequested
```

Example flow:

```text
PaymentSubmitted
      ↓
PaymentBloc
      ↓
SubmitPayment use case
      ↓
PaymentBloc state
```

These events express what happened in the UI or what a particular BLoC needs to do. They are not broadcast globally.

## 3. App-level domain events

App-level domain events announce a completed, meaningful business fact that multiple independent modules may need to react to:

```text
PaymentCompleted
CardBlocked
KycApproved
AlertDismissed
GeofenceDeactivated
```

Example:

```text
SubmitPayment use case succeeds
             ↓
       PaymentCompleted
             ↓
       typed event bus
       ↙     ↓      ↘
PaymentBloc  DashboardBloc  Another interested module
```

These events are facts and therefore should normally use past-tense names. `PaymentCompleted` is appropriate; `CompletePayment` would sound like a command.

## Proposed rules

The foundation documentation should establish these rules:

- BLoC events remain private to their owning presentation feature.
- Use cases represent business actions and queries.
- App-level domain events represent facts that have already occurred.
- Only typed events are permitted; no string event names or untyped payload maps.
- A global event must have a clearly documented publisher, payload, and intended consumers.
- A domain event must not be used merely to avoid an ordinary function call.
- The event bus must not become a replacement for repository observation or database-backed state.
- Consumers must not depend on delivery order unless that contract is explicitly designed.
- A subscriber should treat duplicate events safely where practical.
- A listener must be disposed with the lifecycle of its owning BLoC/service.
- One consumer failing must not prevent other consumers from receiving an event.
- Sensitive information must not be placed in event payloads.
- Event publication timing must be explicit: generally after the underlying operation has committed successfully.
- Events important for durable correctness cannot rely only on an in-memory event bus.

That last rule matters for this application. For example, vehicle telemetry, alert state, geofence transitions, and trips must remain correct after a process restart. Therefore, the event bus can notify BLoCs that persisted state changed, but DuckDB remains authoritative.

```text
Persist successful change
        ↓
Publish typed app event
        ↓
Interested BLoCs receive event
        ↓
BLoCs query authoritative repository state
        ↓
Render updated state
```

The app event can prompt a refresh, but its payload should not become a second source of truth.

## Naming convention

To keep the distinction visible:

| Concept | Naming | Example |
|---|---|---|
| Use case | Imperative/query name | `GetAllVehicles` |
| BLoC event | UI/request occurrence | `FleetRefreshRequested` |
| App-level domain event | Past-tense business fact | `PaymentCompleted` |
| BLoC state | Current presentation condition | `FleetLoadSuccess` |

One point remains to decide later: whether app-level domain events are declared in each owning feature’s domain layer or in a small shared contracts package when several modules consume them. We should decide based on real dependencies rather than creating a shared package preemptively.

I’ll use **app-level domain event** consistently for event-bus messages and **BLoC event** for inputs sent directly to a BLoC. No files have been changed.

> yes `packetId` is unique
>
> no two legitimate packets would not have same vehicle and same event timestamp? duplicate may arrive&#x20;
>
> yes timestamps are UTC
>
> &#x20;one packet would have one signal&#x20;
>
> lets store invalid signals as invalid&#x20;
>
> Sync behavior: lets have SSE implemted and events to be added based on timer and lets add the functionality for Packets arrive late, out of order,
>
> duplicated, or not at all. Vehicles park in basements for hours and then dump a backlog.
>
> this SSE we will implemnt in our nodejs  backend server , handle reconnects using `Last-Event-ID`
>
> Freshness rules: &#x20;
>
> all signals use the same freshness window
>
> exactly 10 minutes old should be considered online
>
> “last ping” is the latest packet event time
>
> packet does not update the vehicle ping
>
> Alert lifecycle
>
> 1. **Yes.** A dismissed alert stays dismissed while the **same alert episode** continues.
> 2. **Yes.** If the condition clears, that alert is resolved. If it later returns, that is a **new alert occurrence/episode**, even though the logical alert type is the same.&#x20;
> 3. **Yes.** A dismissed low-battery Warning should reappear if it escalates to **Critical**. Severity escalation is materially new information and should override the prior dismissal.&#x20;
> 4. **Yes.** Dismissal should be persisted in DuckDB so behavior survives app restart, consistent with the local-first requirement.&#x20;
> 5. **Undo should remove/revert the persisted dismissal state**, not merely show the alert again in memory. After Undo, storage should represent the alert as active again.&#x20;
> 6. **Yes.** Use wall-clock expiry. Persist something like `dismissed_at` / `undo_expires_at`; if the app backgrounds or restarts and the five seconds elapse, Undo should no longer be available. Don’t pause the timer just because the app is backgrounded.
>
> Geofence transition strategy:&#x20;
>
> We process location updates in timestamp order and confirm that a vehicle is clearly inside or outside a geofence before marking an entry or exit. This prevents GPS noise or duplicate/late packets from creating false transitions.
>
> Geofence edits:
>
> Geofence edits apply only going forward. Historical trips continue using the geofence definition that was active at that time.
>
> ### Demo platform priority: Android first&#x20;

Good—these decisions establish the ingestion and alert semantics clearly. I’ll treat them as confirmed, with a few remaining edge cases called out below.

## Confirmed packet model

Each vehicle telemetry packet has:

```text
packetId              globally unique
vehicleId
eventTimestamp        UTC
signalName             exactly one signal per packet
signalValue
serverReceivedAt       UTC, added by backend
```

Location may need a structured value because latitude, longitude, and accuracy must describe one atomic reading. We can model that as one `location` signal whose value contains all three fields.

Rules:

- Deduplicate by `packetId`.
- Legitimate packets do not share the same `(vehicleId, eventTimestamp)`.
- Duplicates may be delivered repeatedly.
- Event-time ordering uses `eventTimestamp`, not arrival order.
- Invalid signals are retained and marked invalid.
- Invalid readings do not participate in latest-value, status, alert, geofence, or trip projections.
- The raw event history remains available for inspection and deterministic replay.

The last exclusion rule is my proposed interpretation; it needs your confirmation.

## Confirmed SSE behavior

The Node.js server will simulate unreliable mobile delivery:

- Normal real-time packets
- Late packets
- Out-of-order packets
- Duplicate packets
- Missing intervals
- Basement/backlog scenarios
- Reconnection and replay

The client will reconnect using `Last-Event-ID`.

We need two different ordering concepts:

```text
SSE delivery ID       Server-assigned, monotonic cursor used for reconnecting
Packet event time     Vehicle timestamp used for business calculations
```

`Last-Event-ID` must refer to the server delivery cursor, not `packetId` or event time. Otherwise, out-of-order and duplicate simulation could make reliable reconnection ambiguous.

The client should persist its last successfully committed SSE cursor. On reconnection, it sends that cursor, and the server replays subsequent delivery records. Each delivery is processed idempotently because the underlying packet has a unique `packetId`.

A subtle but important commit order:

```text
Receive SSE delivery
        ↓
Validate and persist packet
        ↓
Update/recompute affected projections
        ↓
Persist processed SSE cursor
        ↓
Transaction commits
```

This prevents a crash from advancing the cursor before its packet is safely stored.

## Confirmed freshness semantics

- All signals use a 10-minute freshness window.
- `age <= 10 minutes` is fresh.
- `age > 10 minutes` is stale.
- Age is based on the packet’s UTC `eventTimestamp`.
- Vehicle last ping is determined using event time.
- Receiving an arbitrary packet does not automatically update last ping.

This suggests that `last_ping` must be an explicit signal emitted by a vehicle. Please confirm that interpretation.

A shared injectable clock will be important so boundary behavior and Undo expiry can be tested deterministically.

## Confirmed alert episode model

An alert episode begins when a condition changes from inactive to active and ends when it clears.

For SOC, Warning and Critical are severity levels within one logical low-battery alert:

```text
SOC >= 20             no active low-battery alert
10 <= SOC < 20        Warning
SOC < 10              Critical
```

Confirmed behavior:

- A dismissal persists for the current episode.
- A cleared condition resolves the episode independently of dismissal.
- If the condition returns, a new episode is created.
- Warning → Critical is an escalation within the episode.
- Escalation overrides the previous Warning dismissal.
- Dismissal and its reason are persisted in DuckDB.
- Undo reverses the persisted dismissal.
- The five-second Undo deadline uses wall-clock time.
- Undo does not remain available after its persisted expiry, including after backgrounding or restart.
- Stale or invalid values receive no `NORMAL` or `ALERT` claim.

We should preserve the dismissal record for history/audit even after Undo, rather than physically deleting it. “Revert” could be represented with `undone_at`. The effective alert becomes active again while history remains explainable.

## Confirmed geofence versioning

Geofence edits are prospective:

- Editing creates a new effective version.
- Historical location events use the version active at their event time.
- Deactivation closes the active version rather than deleting the geofence.
- Historical trips retain their original interpretation.
- Late packets are evaluated using the geofence definitions that were effective at the late packet’s event time.

This implies versioned geofence definitions even if the UI presents them as a single editable geofence.

## Remaining correctness questions

### 1. Last ping

Is `last_ping` an explicit telemetry signal?

If so, I propose:

- Only a valid `last_ping` signal changes vehicle-level connectivity.
- Its signal value may be empty because its `eventTimestamp` is the ping time.
- Other packets do not change connectivity.
- The detail screen shows the age of the latest valid ping.

### 2. Invalid signal storage

Should invalid records retain:

- Original raw value
- Validation error/reason
- Arrival timestamp
- Packet identity and event time

I recommend retaining all four while excluding invalid readings from derived state.

We also need a policy for unknown signal names. I recommend storing them as valid raw telemetry with an “unsupported” classification rather than calling them invalid, allowing future app versions to understand them.

### 3. SSE retention

How much reconnect history should the backend retain?

For a demo, it could keep a deterministic in-memory delivery log, but restarting the backend would erase the cursor history. A small persisted fixture/delivery log would make the demo repeatable. We should decide whether backend restart recovery is part of the expected demonstration.

### 4. Missing status inputs

The fleet status algorithm still needs a rule when `speed` or `ignition` has never reported or is stale.

Current status choices contain no `UNKNOWN`. Which behavior do you want?

- Use the latest known speed and ignition even when stale.
- Treat the vehicle as `OFFLINE` only from `last_ping`, then use stale last-known values.
- Add an `UNKNOWN` state when the required signals cannot support a status.

I would avoid selecting this silently because it directly changes the required UI.

### 5. Deterministic geofence confirmation

The current geofence strategy is directionally correct but not yet deterministic enough to implement or test. We still need exact rules for:

- Required number of consecutive readings
- Boundary/hysteresis distance
- GPS accuracy cutoff or accuracy-aware boundary
- Overlapping geofences
- Missing intervals
- Multiple late readings inserted into previously processed history
- Whether confirmation time is the first supporting reading or final confirming reading

Those exact choices can be our next focused planning round. Android remains the first fully supported demonstration target; iOS and web stay planned targets whose DuckDB compatibility and persistence behavior must be validated before implementation claims are made.

No files have been created or changed.

> **Last ping:** lets treat `last_ping` as a special explicit signal if that is what the packet model supports. Only a valid `last_ping` updates connectivity, and its `eventTimestamp` is the ping time. Other telemetry should not implicitly refresh connectivity. That keeps `OFFLINE` semantics precise.
>
> **Invalid signal storage:** retain raw value, validation error, arrival timestamp, packet identity, and event time. Invalid readings should be queryable for diagnostics but excluded from derived state. For unknown signal names, your proposal is good: store them as raw telemetry with `unsupported` classification rather than invalid.
>
> **SSE retention:** keep it simple and deterministic. use a **small persisted delivery log** rather than memory-only history, because reconnect behavior becomes reproducible across backend restart. we do not need production-grade retention; even a bounded fixture/event log is enough. Document that the backend is only a demo transport, not the source of truth.
>
> **Missing/stale status inputs:** lets **not add&#x20;****`UNKNOWN`**, because the required UI explicitly defines only five statuses. Use this rule:
>
> - &#x20;If `last_ping > 10 min` → `OFFLINE`&#x20;
> - &#x20;Otherwise use the latest known `speed` and `ignition`, even if individually stale&#x20;
> - &#x20;If either has never reported, fall back conservatively to `STOPPED` only when ignition is explicitly false; otherwise `IDLE` if ignition true and no speed; if ignition itself is absent, choose `STOPPED` as the deterministic fallback and document it.&#x20;
>
> I would call this out in the README because the spec is ambiguous here. The cleaner alternative would be `UNKNOWN`, but I would avoid inventing a new status not requested.
>
> **Geofence confirmation:** lets make the rules concrete:&#x20;
>
> - **2 consecutive readings** to confirm entry or exit.&#x20;
> - &#x20;Hysteresis margin: **max(20 m, reported GPS accuracy)**, capped at something reasonable like 75 m.&#x20;
> - `inside` if `distance <= radius - margin`.&#x20;
> - `outside` if `distance >= radius + margin`.&#x20;
> - &#x20;Between those thresholds = indeterminate; it neither confirms nor resets the prior confirmed state.&#x20;
> - &#x20;Reject readings with accuracy worse than **100 m** for transition confirmation.&#x20;
> - &#x20;Overlap winner: smallest radius, then shortest distance to center, then stable `geofence_id`.&#x20;
> - &#x20;Missing intervals: do not infer the physical crossing time; use the **first supporting reading of the confirmed transition** as transition time.&#x20;
> - &#x20;Late readings: replay the affected vehicle’s event-time window and upsert transitions/trips using deterministic identities, rather than append new ones.&#x20;
> - &#x20;Confirmation time: use the **first supporting reading**, not the second confirming reading. The second point proves the transition; the first point estimates when it began.&#x20;
>
> The last point is worth being very explicit about:
>
> 10:00 inside
>
> 10:05 outside   ← first supporting exit reading
>
> 10:06 outside   ← confirms exit
>
> \
>
> confirmed exit\_at = 10:05
>
> That gives you a stable, testable interpretation and produces more accurate trip boundaries than using `10:06`.

These rules are now sufficiently concrete to become executable specifications and test cases.

## Confirmed status calculation

The status remains limited to the five required values:

```text
OFFLINE, MOVING, IDLE, STOPPED
```

“ALL” is a filter, not a vehicle status.

The deterministic evaluation order is:

```text
1. Valid last_ping age > 10 minutes       → OFFLINE
2. Latest known speed > 0                 → MOVING
3. Latest known ignition == false         → STOPPED
4. Latest known ignition == true          → IDLE
5. Ignition has never reported            → STOPPED
```

Additional implications:

- Exactly 10 minutes old remains online.
- Only a valid explicit `last_ping` signal affects connectivity.
- Stale speed and ignition remain usable for status.
- If ignition is true and speed has never reported, status is `IDLE`.
- If speed is zero and ignition is absent, status falls back to `STOPPED`.
- The ambiguity and fallback will be documented prominently.

One remaining clock edge case: a future-dated `last_ping` caused by vehicle clock skew should not produce a negative displayed age. My proposed rule is to retain it but mark it invalid for derived state when it exceeds a documented future-skew tolerance. We can set that tolerance later.

## Confirmed signal classification

Every received record is retained and classified as:

```text
supported_valid
supported_invalid
unsupported
```

A stored record includes:

- Packet ID
- Vehicle ID
- Event timestamp
- Server arrival timestamp
- Client ingestion timestamp
- Signal name
- Raw value
- Parsed/normalized value where valid
- Classification
- Validation error where applicable
- SSE delivery cursor

Only `supported_valid` readings participate in projections. Invalid and unsupported readings remain queryable for diagnostics.

## Confirmed SSE contract

The backend maintains a small persisted, bounded delivery log.

Its responsibilities are:

- Generate deterministic demo scenarios.
- Deliver packets through SSE.
- Replay deliveries after `Last-Event-ID`.
- Preserve replay behavior across backend restarts.
- Simulate delayed, duplicated, out-of-order, missing, and backlog delivery.

It is explicitly not the application’s source of truth. DuckDB is authoritative for everything the client has successfully ingested.

The server’s retention boundary must be visible. If a client requests a cursor older than the retained log, the server should return an explicit “replay unavailable” signal rather than silently continuing with incomplete data. The exact recovery behavior can be decided with the sync design.

## Confirmed geofence classification

For a valid location reading:

```text
margin = min(max(20 m, gpsAccuracy), 75 m)

inside        when distance <= radius - margin
outside       when distance >= radius + margin
indeterminate otherwise
```

A reading with reported accuracy greater than 100 m cannot support a transition.

I interpret “indeterminate neither confirms nor resets” to mean two supporting readings may have indeterminate readings between them:

```text
10:05 outside
10:05:30 indeterminate
10:06 outside
```

This confirms an exit at `10:05`. In other words, “consecutive” means consecutive decisive readings for that candidate transition, not necessarily adjacent raw location packets.

A decisive reading supporting the opposite state resets the candidate.

## Confirmed transition behavior

- Two qualifying readings confirm a state change.
- The first supporting reading supplies the transition event time.
- The second supplies confirmation.
- Poor-accuracy and indeterminate readings neither advance nor reset confirmation.
- Duplicate packets do not count as multiple supporting readings.
- Processing is ordered by event time with deterministic tie-breaking.
- Late data triggers replay of the affected vehicle’s event-time window.
- Transitions and trips are upserted using deterministic identities.
- No crossing time is inferred during missing intervals.
- Overlaps are resolved by:

```text
smallest radius
then shortest center distance
then stable geofenceId
```

- Geofence definitions are versioned and apply over half-open effective intervals:

```text
[effectiveFrom, effectiveUntil)
```

This removes ambiguity at the exact instant an edit becomes effective.

## Required geofence state-machine detail

An exit should only be possible after the vehicle has established a confirmed inside state. Similarly, an entry should only be produced when transitioning from a confirmed outside state.

For a vehicle with no prior confirmed state, I propose:

- Two inside readings establish the initial geofence occupancy without emitting an entry.
- Two outside readings establish initial outside state without emitting an exit.
- Trips begin only from a later confirmed inside → outside transition.

This prevents starting a trip merely because the app began observing a vehicle already on the road.

## Next planning round: trips and retention

Please confirm these remaining behaviors:

1. Initial observation: should establishing the first known inside/outside state avoid emitting a transition, as proposed above?

2. Direct geofence change: if readings move from confirmed inside A to clearly inside B, should the engine produce:

```text
exit A → start trip
entry B → complete trip
```

even when no separately confirmed “outside all geofences” state exists?

3. Same-origin return: for A → outside → A, the completed trip will have origin and destination both A. Confirmed by the specification; should this appear normally without special labeling?

4. Active trip: if a vehicle produces another confirmed exit while it already has an active trip, should that exit be ignored for trip creation but retained as a transition?

5. Late revision: if late data changes a completed trip’s origin, destination, start, or end, may the existing trip be updated visibly in the UI? The requirement implies yes.

6. Deterministic trip identity: I recommend deriving identity from the vehicle plus the confirmed exit transition identity. That keeps the same trip stable when its destination or completion time is revised.

7. Retained telemetry window: how much event history should DuckDB retain—fixed days, fixed packet count, or all demo data?

8. SOC history: should the detail screen show a time window such as the last 24 hours, last seven days, or the full retained history?

No files or code have been created.

> 1. **Initial observation:** yes. The first known state should establish baseline membership only. It should **not emit an entry or exit transition** because we did not observe a crossing.&#x20;
> 2. **Direct A → B change:** yes. If the engine confirms that the vehicle has moved from A to B, lets emit: exit A, entry B
> 3. **Same-origin return:** yes. `A → outside → A` is a normal completed trip with origin = destination = A. No special label is needed unless the UI wants one.&#x20;
> 4. **Another exit while trip active:** yes. Retain the transition, but do **not create a second active trip**. The one-active-trip invariant wins.&#x20;
> 5. **Late revision:** yes. A late packet may visibly revise an existing trip’s start, end, origin, or destination. That is exactly what event-time-aware processing implies.&#x20;
> 6. **Trip identity:**  Use: trip\_id = deterministic(vehicle\_id + exit\_transition\_id)
> 7. **Retention:** I would use a **time-based retention policy**, not packet count. lets use **30 days of raw telemetry**, while retaining compacted/derived data longer.

Confirmed. This gives us a deterministic trip model.

## Trip processing rules

### Baseline establishment

The first confirmed membership establishes the vehicle’s baseline:

- Two inside readings establish that the vehicle is inside a geofence.
- Two outside readings establish that it is outside.
- Baseline establishment emits no entry or exit because no crossing was observed.

### Direct A → B transition

When two qualifying readings confirm B as the winning geofence while the previous confirmed state was A:

```text
Exit A
Entry B
```

Both transitions may use the first B-supporting reading as their event time. The exit starts a trip and the entry immediately completes it.

### Trip lifecycle

```text
Confirmed exit
    ↓
No active trip → create IN_PROGRESS trip
Active trip    → retain transition, create no additional trip

Next confirmed entry
    ↓
Complete active trip
```

Confirmed invariants:

- At most one active trip per vehicle.
- Returning to the origin is valid.
- Origin and destination may be the same.
- No special label is required for same-origin trips.
- Extra exit transitions are retained even when they cannot start another trip.
- A late packet can revise trip start, end, origin, or destination.
- Reprocessing must remove obsolete derived transitions/trips as well as upsert current ones.

Trip identity:

```text
trip_id = deterministic(vehicle_id + exit_transition_id)
```

If replay replaces the originating exit transition itself, the old derived trip must be removed and a new deterministic trip created. If only its destination or completion changes, its identity remains stable.

## Retention policy

Confirmed:

- Raw vehicle telemetry: 30 days.
- Retention is based on event time, not packet count.
- Derived/compacted data is retained longer.

A safe cleanup order will be important:

1. Ensure eligible raw events have been processed.
2. Preserve required derived history.
3. Delete raw records older than the boundary in a transaction or resumable maintenance operation.
4. Never remove data still needed by an unfinished replay.

## Remaining retention decisions

We should define these before documenting the database contract:

1. Should trips, transitions, alerts, dismissals, and geofence versions be retained indefinitely for the demo?

2. What happens when a late packet arrives already older than the 30-day raw retention boundary?

   My recommendation is to store it in a diagnostic/quarantine record but not revise derived state, because immediately inserting and deleting it would make behavior confusing.

3. Should the SOC history view show:

   - Last 24 hours by default
   - Last seven days by default
   - The complete 30-day retained window

   A default window plus optional range selection would demonstrate querying without overcrowding the detail screen.

## Next architecture decisions

We also need to establish ownership of the main data categories:

- Vehicle registry: supplied by the backend or seeded locally?
- Telemetry history: supplied through SSE only, or initial HTTP backfill followed by SSE?
- Geofences: local-device-only, or synchronized with the demo backend?
- Alert dismissals: local-device-only, or sent to the backend?
- Trips: computed exclusively on-device from DuckDB, as the requirement appears to imply?
- Authentication: intentionally excluded from the demo, or represented by a minimal fake sign-in?
- “Where are my vehicles”: does the deliverable require an actual map, or is the fleet list plus current-geofence information sufficient?

The most important transport question is initial synchronization. SSE plus a bounded delivery log handles live delivery and reconnects, but a fresh installation still needs a defined way to acquire the vehicle registry and historical telemetry. A clean model would be:

```text
Initial HTTP snapshot/backfill
            ↓
Transactional DuckDB import
            ↓
SSE from returned delivery cursor
            ↓
Continuous local ingestion
```

That is only a proposal until you confirm it. No files or code have been created.

> Vehicle registry: backend-supplied, with local seeded fallback only for demo/bootstrap. The fleet of 500 vehicles is domain data, so it should conceptually come from the backend and be persisted in DuckDB.
> Telemetry history: use initial HTTP snapshot/backfill + SSE for live updates. This is the cleanest model for fresh install, reconnect, and local-first behavior.
> Geofences: keep them local-device-only for the take-home unless the brief explicitly asks for multi-device sync. Persist them in DuckDB. lets not add backend synchronization for now&#x20;
> Alert dismissals: local-device-only and persisted in DuckDB. The requirement is about local behavior, not collaborative/operator sync.
> Trips: yes, compute them entirely on-device from persisted telemetry/geofence history in DuckDB. That best demonstrates the event-time/idempotency requirement.
> **Authentication:** intentionally exclude it. State in README: “Authentication is out of scope for this single-operator take-home.”
> Map: No, out of scope
>
> synchronization model:&#x20;
> GET /bootstrap
> &#x20;   ↓
> vehicle registry
> telemetry backfill
> delivery cursor
> &#x20;   ↓
> single DuckDB transaction/import
> &#x20;   ↓
> UI becomes available from DuckDB
> &#x20;   ↓
> SSE /telemetry?after=\<cursor>
> &#x20;   ↓
> continuous ingestion
> &#x20;   ↓
> DuckDB remains source of truth

The ownership and synchronization boundaries are now clear.

## Confirmed source-of-truth model

```text
Backend
├── Vehicle registry
├── Initial telemetry backfill
├── SSE delivery log
└── Simulated live vehicle telemetry

DuckDB
├── Persisted vehicle registry
├── Raw telemetry event log
├── Latest-signal projections
├── Geofences and versions
├── Geofence transitions
├── Trips
├── Alerts and dismissals
└── Sync cursor

Flutter UI
└── Reads application data only through DuckDB-backed repositories
```

Local-only data:

- Geofences and their versions
- Alert dismissals
- Derived transitions and trips
- Application preferences

Explicitly excluded:

- Authentication
- Backend geofence synchronization
- Backend alert-dismissal synchronization
- Backend trip calculation
- Vehicle map

## Startup behavior

We should distinguish a fresh installation from a returning installation.

### Fresh installation

```text
GET /bootstrap
    ↓
vehicle registry + telemetry backfill + delivery cursor
    ↓
validate and import in one DuckDB transaction
    ↓
build projections
    ↓
UI reads from DuckDB
    ↓
connect SSE from committed cursor
```

If bootstrap fails and a local demo seed is available, the app may offer or automatically use the documented demo fallback.

### Returning installation

Local-first behavior means the app should not wait for the network:

```text
Open existing DuckDB
    ↓
UI immediately reads persisted state
    ↓
background synchronization begins
    ↓
SSE resumes from committed cursor
    ↓
database changes cause relevant UI queries to refresh
```

A failed reconnect must not remove or replace existing local data. The UI can show a synchronization warning while continuing to display persisted fleet information.

## Cursor semantics

The bootstrap response supplies the server delivery cursor corresponding to its snapshot. The bootstrap data and that cursor are committed atomically on the device.

For SSE:

- Initial connection can use `/telemetry?after=<cursor>`.
- Automatic reconnection uses the standard `Last-Event-ID` behavior.
- Every SSE delivery has a monotonic delivery ID.
- Delivery ID is separate from unique `packetId`.
- Business ordering uses `eventTimestamp`.
- Reconnect ordering uses delivery ID.
- The client persists a cursor only after the associated database work commits.

The backend must ensure that the bootstrap snapshot and returned cursor form a consistent boundary, so packets cannot fall into a gap between bootstrap and SSE.

## Proposed feature boundaries

To keep Clean Architecture useful without turning every screen into a separate pseudo-module, I propose these initial Flutter features:

```text
lib/
├── app/                 composition root, routing, app shell
├── core/                clock, failures, result types, database foundations
└── features/
    ├── fleet/           fleet home and vehicle detail
    ├── ingestion/       bootstrap, SSE, validation, persistence
    ├── alerts/          alert episodes, dismissal, undo
    ├── geofences/       definitions, versions, membership, transitions
    └── trips/           trip derivation and history
```

Each feature can contain only the layers it genuinely needs:

```text
feature/
├── domain/
├── data/
└── presentation/
```

Not every feature needs all three directories. Empty architectural ceremony should be prohibited.

The Node backend can remain much smaller:

```text
server/
├── bootstrap
├── telemetry simulation
├── persisted delivery log
├── fixtures
└── API/SSE transport
```

## Next focused decisions

Before defining the testing, CI, and coding-standard documents, please confirm:

1. For the Node backend, do you want JavaScript or TypeScript? I recommend TypeScript because packet and bootstrap contracts are central to the correctness of the demo, but I won’t select it without your approval.

2. Which package manager should the monorepo use for Node tooling: npm, pnpm, or Yarn?

3. Should the Flutter/backend API models be maintained independently against a documented JSON contract, or generated from an OpenAPI/schema definition?

4. Should navigation use Flutter’s built-in routing or a package such as `go_router`?

5. Are code-generation tools such as `freezed` and `json_serializable` acceptable, or do you prefer handwritten immutable Dart models?

6. When persisted data already exists, confirm that the app renders it immediately while bootstrap/SSE synchronization proceeds in the background.

7. For demo fallback data, should fallback activate automatically after bootstrap failure or require an explicit “Use demo data” action? Explicit activation is easier to explain and avoids hiding a real sync failure.

8. The earlier retention questions remain open:

   - Retain derived trips, transitions, alert history, dismissals, and geofence versions indefinitely for the demo?
   - Quarantine telemetry that arrives already outside the 30-day retention window?
   - Default SOC history window: 24 hours, seven days, or 30 days?

No files or code have been created.

> Node backend: TypeScript
>
> Package manager: pnpm.
>
> API contracts: generated from OpenAPI/schema.
>
> Navigation: `go_router`
>
> Code generation: yes, use `freezed` + `json_serializable`.use immutable models, unions, equality, and JSON parsing.&#x20;
>
> Existing local data: yes, render immediately
>
> App starts -> Open DuckDB -> Render persisted fleet immediately -> Bootstrap/SSE sync in background -> DuckDB updates -> UI refreshes from DuckDB
>
> Demo fallback: explicit “Use demo data” action
>
> **Retention policy:**
>
> - &#x20;Raw valid telemetry: **30 days**&#x20;
> - &#x20;Invalid/quarantined telemetry: **30 days**&#x20;
> - &#x20;Trips: retained&#x20;
> - &#x20;Geofence transitions: retained&#x20;
> - &#x20;Alert lifecycle/history: retained&#x20;
> - &#x20;Dismissals: retained as part of alert history&#x20;
> - &#x20;Geofence versions: retained&#x20;
> - &#x20;SOC history default: **24 hours**

These choices are confirmed and fit the local-first architecture well.

## Confirmed tooling

```text
Flutter/Dart
├── go_router
├── flutter_bloc / bloc
├── get_it
├── dio
├── dart_duckdb
├── freezed
└── json_serializable

Node.js/TypeScript
└── pnpm

Contract source
└── OpenAPI schema
```

The OpenAPI document will be the source of truth for transport models. Generated Dart models must remain in the data/transport layer and must not become domain entities directly.

```text
Generated API DTO
        ↓ mapper
Domain entity/value object
        ↓
Presentation model/state
```

This prevents backend schema changes from leaking through the entire application.

The SSE endpoint can be documented in OpenAPI, with its event payload referencing the shared packet schema. We should avoid adding AsyncAPI unless OpenAPI becomes genuinely insufficient for this demo.

## Confirmed retention

All raw classifications use the same 30-day event-time retention:

- Valid telemetry: 30 days
- Invalid telemetry: 30 days
- Unsupported telemetry: 30 days
- Quarantined records: 30 days

Retained without an automatic demo expiry:

- Trips
- Geofence transitions
- Alert history and lifecycle
- Dismissals
- Geofence definitions and versions

SOC history defaults to the last 24 hours, queried from DuckDB. This is a default display window, not a separate retention rule.

Telemetry arriving already outside the retained 30-day boundary should be recorded in quarantine long enough to explain why it was ignored. Since quarantine itself has a 30-day event-time policy, an event already older than the boundary would otherwise be deleted immediately. I propose using `received_at` for quarantine retention while using `eventTimestamp` for normal telemetry retention. That lets the diagnostic record remain visible for 30 days after receipt without allowing it into derived state.

## Confirmed startup sequence

```text
Open DuckDB
    ↓
Render persisted fleet immediately
    ↓
Start background bootstrap/recovery and SSE synchronization
    ↓
Commit changes to DuckDB
    ↓
Refresh affected database-backed queries
```

On a fresh install with no local data:

- Attempt bootstrap.
- If it fails, present the failure.
- Offer an explicit **Use demo data** action.
- Never silently switch to fixtures.

## Proposed monorepo boundary

```text
/
├── apps/
│   ├── mobile/
│   └── server/
├── contracts/
│   └── openapi.yaml
├── packages/              created only when sharing is justified
├── docs/
└── pnpm-workspace.yaml
```

We should decide later whether Flutter workspace orchestration needs Melos. With only one Flutter app, adding it now may be unnecessary.

## Next round: testing and delivery

My proposed testing baseline is below. Please approve or adjust it.

### Flutter unit tests

- `flutter_test`
- `bloc_test` for BLoC behavior
- `mocktail` for boundary mocks
- Fake clock for freshness, alert Undo, retention, and event-time tests
- Handwritten fakes preferred for stateful/domain-heavy collaborators
- Table-driven tests for signal validation and status rules
- Property-style/permutation tests for duplicate and out-of-order packets

### Database integration tests

Use a real temporary DuckDB database rather than mocking SQL for:

- Persistence across close/reopen
- Bootstrap transaction atomicity
- Packet deduplication
- Latest-signal projections
- SQL filter counts
- Alert episode lifecycle
- Geofence version queries
- Late-event replay
- Trip idempotency
- Retention cleanup

Because DuckDB is central to the product requirement, mocked database tests would not provide enough confidence.

### Flutter widget and integration tests

- Widget tests for fleet filters, empty states, status chips, readings, alert pills, dismissal sheet, and Undo
- A small number of golden tests for key interview-facing screens
- Android integration test for:

```text
bootstrap → fleet → vehicle detail → alert dismissal → undo
```

- Another Android integration test for:

```text
late/duplicate location packets → transition replay → corrected trip
```

### Backend tests

A likely TypeScript test stack is:

- Vitest
- Supertest for HTTP
- SSE protocol tests using a real local server
- Deterministic fake clock/timer
- Fixture scenarios for duplicates, delays, reordering, missing periods, backlog, and reconnect
- Contract validation against OpenAPI
- Restart test proving delivery-log persistence

### GitLab CI stages

```text
validate
├── formatting
├── static analysis
├── OpenAPI validation
└── generated-code consistency

test
├── Flutter unit/widget tests
├── DuckDB integration tests
├── Node unit/API/SSE tests
└── contract tests

build
├── Android debug APK
├── Node production build
└── optional web build after compatibility validation
```

I recommend Android as the required CI build initially. iOS builds require macOS runners, and web support must be validated against the DuckDB adapter before being made a required gate.

## Decisions needed

1. Approve `bloc_test` and `mocktail`?
2. Approve Vitest and Supertest for the Node server?
3. Should golden tests be included, or is that unnecessary churn for the take-home?
4. Should minimum code coverage be enforced? If yes, one global number can be misleading; I recommend high coverage for domain logic without forcing generated/UI glue to meet the same threshold.
5. Should CI require the repository to remain clean after code generation?
6. Should Android integration tests run on every merge request or only manually/nightly due to runtime?
7. Should analytics initially use only no-op/debug adapters, with no external vendor or network transmission?
8. Do you want Melos now, or should we add it only after a second Dart/Flutter package exists?

No files or code have been created.

> 1. Approved&#x20;
> 2. approved
> 3. out of scope&#x20;
> 4. yes 90+
> 5. yes&#x20;
> 6. for everymerge request the flutter unit tests should run, integration test should run when the MR is merged in main. it should be async and should update the dev about report via mail/slack
> 7. yes, no op / debug adopters&#x20;
> 8. i don't think we need melos for now. remind me when we need it add it in context.md&#x20;

Confirmed.

## Testing and CI decisions

- Flutter: `flutter_test`, `bloc_test`, and `mocktail`.
- Backend: Vitest and Supertest.
- Golden tests are out of scope.
- Coverage must be at least 90%.
- CI must fail if generation changes committed files.
- Flutter unit, widget, and DuckDB integration tests run on every merge request.
- Android end-to-end integration tests run asynchronously after merge to `main`.
- Post-merge integration results notify developers by email or Slack.
- Analytics starts with no-op and debug adapters only.
- Melos will not be added initially.

The future Melos reminder will be included in `context.md`:

> Reconsider Melos when a second Dart/Flutter package is introduced, when shared Dart packages require coordinated commands, or when workspace-wide dependency/version management becomes repetitive.

## Coverage rule requiring one refinement

“90%+” should specify the metric and exclusions. My proposed rule is:

```text
Minimum line coverage: 90%
Minimum branch coverage: 90%, where supported reliably
```

Exclude:

- Generated `freezed` and JSON serialization files
- Generated OpenAPI clients/models
- Dependency-registration boilerplate
- Platform-generated runner code

Do not exclude domain rules, BLoCs, repositories, SQL behavior, mappers, ingestion, alert logic, geofence processing, or trip reconstruction.

Please confirm whether you want both line and branch coverage at 90%, or only line coverage.

## Post-merge integration reporting

The pipeline can run a downstream/asynchronous Android integration job after merge to `main`. “Asynchronous” should not mean invisible:

- The main branch pipeline records the result.
- Test artifacts and reports are retained.
- Failure sends a notification.
- The job does not block the already-completed merge.
- A failure makes `main` visibly unhealthy and should be fixed before normal feature work continues.

Email can rely on GitLab notification settings. Slack requires a webhook/integration secret and therefore additional setup. We should document both but select one default. Which should be required for the demo: GitLab email, Slack, or whichever is configured?

## Next round: application-wide contracts

I propose the following rules for approval.

### Error handling

- Domain and application boundaries return typed success/failure results.
- Exceptions from Dio, DuckDB, parsing, and storage do not escape the data layer.
- Data adapters translate infrastructure exceptions into application-owned failures.
- Programming errors are not silently converted into user-facing failures.
- BLoCs convert failures into explicit presentation states.
- User messages remain actionable and do not expose stack traces or database details.
- Debug diagnostics may include stack traces, but never secrets.

### Analytics

Use separate contracts so “analytics” does not become an unstructured catch-all:

```text
AnalyticsTracker       product and workflow events
DiagnosticsReporter    structured debug/error diagnostics
CrashReporter          fatal and non-fatal exception reporting
PerformanceMonitor     operation and screen timing
```

Initial implementations:

```text
NoOp*
Debug*
```

Rules:

- No vehicle telemetry values are transmitted through analytics.
- No raw packet payloads are sent to analytics.
- No secrets or sensitive storage values are recorded.
- Event names and properties are typed or centrally defined.
- Analytics failures never break business operations.
- Provider-specific SDKs remain behind adapters.
- Debug analytics are disabled or sanitized in release builds.

### Typed app-level domain event bus

- BLoC events stay local to their BLoC.
- App-level domain events are typed, past-tense business facts.
- Events are published only after the authoritative DuckDB transaction commits.
- Subscribers re-query repositories rather than treating event payloads as authoritative state.
- Event subscriptions must be disposed.
- Duplicate handling is safe.
- Subscriber failure is isolated.
- Durable correctness never depends solely on the in-memory bus.
- Cross-feature events live with the owning feature until sharing requires a small contract package.

### Security

- Authentication is explicitly out of scope.
- No secrets in source control, fixtures, logs, analytics, screenshots, or generated code.
- CI credentials and Slack webhooks use protected GitLab variables.
- Secure storage is used only for genuinely sensitive values.
- Shared preferences contain no sensitive information.
- OpenAPI fixtures contain synthetic data only.
- SQL is parameterized.
- Network and parsing inputs are untrusted and validated.
- Dependency and secret scanning run in CI where available.

Please approve or adjust these rules. We also need your choice for:

1. Coverage: line only, or line and branch?
2. Post-merge notification: email, Slack, or configuration-dependent?
3. Should the event bus deliver events asynchronously by default?
4. Should event handlers be allowed to publish additional app-level events, with loop protection, or should chained publication be prohibited initially?

No files or code have been created.

> Coverage: line only&#x20;
> Post-merge notification: configuration-dependent
> Should the event bus deliver events asynchronously by default: yes&#x20;
> No chined app-level events for now

Confirmed:

- Coverage gate: at least 90% line coverage.
- Generated and platform boilerplate are excluded.
- Post-merge notification: use email or Slack according to configured GitLab integration.
- App-level domain events are delivered asynchronously.
- Chained publication of app-level domain events is prohibited initially.
- Event handlers may update their own BLoC state or invoke reads, but cannot publish another global event.

The no-chaining rule should include loop protection and a diagnostic failure if violated accidentally.

## Proposed foundation documentation

We now have enough context to define the repository’s documentation structure without creating implementation code:

```text
/
├── AGENTS.md
├── context.md
└── docs/
    ├── product/
    │   ├── product-brief.md
    │   └── requirements.md
    ├── architecture/
    │   ├── overview.md
    │   ├── clean-architecture.md
    │   ├── data-and-sync.md
    │   ├── vehicle-status-and-alerts.md
    │   ├── geofences-and-trips.md
    │   ├── app-events.md
    │   └── decisions/
    │       ├── README.md
    │       └── template.md
    ├── engineering/
    │   ├── coding-standards.md
    │   ├── testing-strategy.md
    │   ├── analytics.md
    │   └── security.md
    └── delivery/
        ├── ci-cd.md
        └── definition-of-done.md
```

### `AGENTS.md`

The short, mandatory AI entry point:

- Always begin new work with planning.
- Read relevant context and inspect existing implementation.
- Ask about unresolved product or architecture behavior.
- Do not edit until explicitly told to write or implement.
- Follow the approved plan.
- Do not introduce packages, native code, or architecture changes silently.
- Test and verify implemented changes.
- Report failures and unexecuted checks truthfully.
- Preserve unrelated user changes.
- Route readers to the relevant detailed documents.

### `context.md`

The concise current-project snapshot:

- Product and glossary
- Technology choices
- Repository applications
- Source-of-truth boundaries
- Explicitly out-of-scope items
- Android-first priority
- Confirmed architectural decisions
- Open decisions
- Melos reminder conditions
- Documentation map

This file should remain compact and change as the project evolves.

### Product documents

`product-brief.md` will explain the operator problem, target user, demo objective, and scope.

`requirements.md` will preserve the supplied fleet, vehicle detail, alert, geofence, and trip requirements as testable acceptance criteria.

### Architecture documents

- `overview.md`: monorepo, features, dependency direction, runtime components.
- `clean-architecture.md`: presentation/domain/data responsibilities, use cases, repositories, adapters, and dependency injection.
- `data-and-sync.md`: DuckDB authority, packet classification, bootstrap, SSE cursor semantics, replay, retention, and startup.
- `vehicle-status-and-alerts.md`: precise SQL/status rules, freshness, alert episodes, escalation, dismissal, and Undo.
- `geofences-and-trips.md`: deterministic geometry, confirmation, versioning, event-time replay, transitions, and trip invariants.
- `app-events.md`: BLoC events versus use cases versus asynchronous app-level domain events.
- `decisions/`: lightweight ADR instructions and template.

### Engineering documents

- `coding-standards.md`: Dart/Flutter and TypeScript rules, immutable models, generated code, package boundaries, native-code prohibition, failure handling.
- `testing-strategy.md`: test pyramid, real DuckDB integration testing, clocks, fixtures, 90% line coverage, exclusions.
- `analytics.md`: analytics vocabulary, four abstract contracts, no-op/debug adapters, privacy.
- `security.md`: secrets, storage classifications, validation, parameterized SQL, dependency scanning.

### Delivery documents

- `ci-cd.md`: GitLab validation, test, build, post-merge Android integration, reports, and configuration-dependent notifications.
- `definition-of-done.md`: acceptance criteria, tests, documentation, generated-code cleanliness, successful validation, and implementation reporting.

## Remaining setup decisions

These can be marked as open in `context.md`, but resolving them first would make the foundation stronger:

1. Flutter SDK strategy: pin an exact version using FVM, or use the repository’s declared Flutter constraint without FVM?
2. Node.js version: which major version should CI and local development use?
3. Backend persisted delivery log: SQLite, JSON file, or another simple mechanism?
4. Database migrations: should we maintain numbered SQL migrations with an internal schema-version table?
5. OpenAPI generation: should generated clients be committed, or generated only during bootstrap/CI? The clean-repository CI rule works with either approach but needs one policy.
6. Formatting/linting: use `flutter_lints`, a stricter Dart lint package, or a repository-owned analysis configuration?
7. Are the proposed error-handling, analytics, app-event, and security rules from the previous planning round approved as written?

Once these are answered, I can produce the final master prompt or, when you explicitly say to write, create the approved Markdown foundation. No files have been changed.

> 1. pin an exact version with FVM
> 2. use the current active LTS major and pin it in `.nvmrc` / CI
> 3. use **SQLite**
> 4. yes. Use numbered SQL migrations plus a schema-version table
> 5. commit generated clients/models. - (that makes the repo immediately buildable and avoids requiring codegen before every first run. CI should regenerate and fail if committed generated code is stale)
> 6. use a repository-owned `analysis_options.yaml`, starting from `flutter_lints`
> 7. **Previous rules:** yes

<details><summary>2 previous messages</summary>

> I’ll verify the current Node.js Active LTS major and Flutter stable release from their official sources, then fold those exact pins into the final documentation plan. I’m still only planning—no files will be created.
>
> <details><summary>Searched the web</summary>
>
> Searched the web for `site:nodejs.org/en/about/previous-releases Node.js Active LTS current ...`
>
> </details>
</details>

The foundation plan is now ready.

Version pins verified against official release information:

- Flutter: `3.47.0`, pinned through FVM. Flutter lists 3.47.0 as the latest stable feature release. [Flutter release notes](https://docs.flutter.dev/release/release-notes)
- Node.js: major `24`, currently the latest LTS line; the latest listed patch is `24.19.0`. I recommend pinning `24.19.0` in `.nvmrc`, `package.json`, and GitLab CI for reproducibility. [Node.js releases](https://nodejs.org/en/about/previous-releases)

The foundation will also specify:

- SQLite-backed persisted delivery log for the demo server.
- Numbered DuckDB and SQLite migrations with schema-version tables.
- OpenAPI-generated Dart and TypeScript artifacts committed to Git.
- CI regenerates contracts and fails on a dirty diff.
- Repository-owned `analysis_options.yaml` based on `flutter_lints`.
- 90% minimum line coverage, excluding generated/platform boilerplate.
- No Melos until a second Dart package or coordinated workspace operations justify it.
- Previously approved error handling, analytics, security, and event-bus rules.

A small distinction for the version policy: exact versions remain pinned; upgrades require an intentional change, successful CI, and any necessary migration notes. “Use current stable/LTS” will not cause tools or AI agents to upgrade versions silently.

The next authorized action would create only the planned Markdown foundation—no application or infrastructure code. When you want that, say:

> Write the approved foundation Markdown files. Do not scaffold or implement the application yet.

Until then, no repository files have been changed.

> Write the approved foundation Markdown files. Do not scaffold or implement the application yet.

<details><summary>7 previous messages</summary>

> I’ll create only the approved Markdown foundation. I’ll first inspect the repository and any existing instructions so I can preserve current work, then write and verify the documentation set—no app scaffolding or implementation.
>
> <details><summary>Explored 2 lists, ran 2 commands</summary>
>
> - Ran `pwd && rg --files -g 'AGENTS.md' -g '*.md' -g '!**/.git/**' | sed -n '1,160p' && git status --short`
>
> <details><summary>Explored 2 lists</summary>
>
> - Listed files
> - Listed files in `.`
>
> </details>
>
> - Ran `mkdir -p docs/product docs/architecture/decisions docs/engineering docs/delivery`
>
> </details>
>
> The repository is empty and not yet initialized as Git, so there is no existing work to preserve. I’ve created only the approved documentation directories; I’m now writing the instruction and product-context files.
>
> <details><summary>Created 12 files</summary>
>
> - Wrote `./AGENTS.md` (+55 -0)
> - Wrote `./context.md` (+90 -0)
> - Wrote `./docs/product/product-brief.md` (+32 -0)
> - Wrote `./docs/product/requirements.md` (+79 -0)
> - Wrote `./docs/architecture/app-events.md` (+32 -0)
> - Wrote `./docs/architecture/clean-architecture.md` (+51 -0)
> - Wrote `./docs/architecture/data-and-sync.md` (+76 -0)
> - Wrote `./docs/architecture/decisions/README.md` (+15 -0)
> - Wrote `./docs/architecture/decisions/template.md` (+39 -0)
> - Wrote `./docs/architecture/geofences-and-trips.md` (+58 -0)
> - Wrote `./docs/architecture/overview.md` (+50 -0)
> - Wrote `./docs/architecture/vehicle-status-and-alerts.md` (+49 -0)
>
> </details>
>
> The product and architecture documents are in place, including the deterministic status, alert, geofence, trip, SSE, and event-bus rules. I’m finishing the engineering and GitLab delivery policies, then I’ll cross-check the whole set for contradictions and accidental implementation scope.
>
> <details><summary>Created 6 files, explored 3 searches, a list</summary>
>
> - Wrote `./docs/delivery/ci-cd.md` (+53 -0)
> - Wrote `./docs/delivery/definition-of-done.md` (+36 -0)
> - Wrote `./docs/engineering/analytics.md` (+28 -0)
> - Wrote `./docs/engineering/coding-standards.md` (+50 -0)
> - Wrote `./docs/engineering/security.md` (+27 -0)
> - Wrote `./docs/engineering/testing-strategy.md` (+61 -0)
>
> <details><summary>Explored 3 searches, a list</summary>
>
> - Listed files
> - Searched for `UNKNOWN|telemetry analytics|TelemetryService|Melos|90%|3\.47\.0|24\.19\.0|Do not scaffold|No files` in `.`
> - Searched for `*.md` in `.`
> - Searched for `TODO|TBD|assum|source of truth|source-of-truth` in `AGENTS.md`
>
> </details>
>
> </details>
>
> <details><summary>Plan</summary>
>
> Created and reviewed the approved Markdown-only foundation. The repository remains unscaffolded; product/application code and configuration were not added.
>
> - [x] Create the approved documentation directory structure
> - [x] Write repository, product, architecture, engineering, and delivery guidance
> - [x] Review the Markdown set for consistency, scope, and unresolved decisions
>
> </details>
</details>

Created the approved Markdown-only foundation:

- [AGENTS.md](./AGENTS.md)
- [context.md](./context.md)
- [Product documentation](./docs/product/product-brief.md)
- [Architecture overview](./docs/architecture/overview.md)
- [Engineering standards](./docs/engineering/coding-standards.md)
- [CI/CD policy](./docs/delivery/ci-cd.md)
- [Definition of done](./docs/delivery/definition-of-done.md)

The 18 Markdown files cover:

- Mandatory plan-first AI workflow
- Product requirements and terminology
- Clean Architecture and dependency boundaries
- DuckDB local-first persistence and synchronization
- Status, freshness, and alert lifecycle rules
- Deterministic geofence and trip processing
- BLoC events, use cases, and app-level domain events
- Coding, testing, analytics, and security policies
- GitLab CI, 90% line coverage, generation checks, and post-merge testing
- ADR guidance and template

I reviewed the set for consistency and recorded unresolved implementation decisions explicitly in `context.md`. No Flutter app, Node server, configuration, database, or other implementation files were created. The directory is not currently a Git repository.

> in the docs is it mentioned that implementation has to be done using abstract classes always?

<details><summary>2 previous messages</summary>

> I’ll check the current wording across the foundation docs and distinguish “always use abstract classes” from the narrower boundary-abstraction rule we agreed on.
>
> <details><summary>Explored a search</summary>
>
> - Searched for `abstract|abstraction|interface|contract|third-party|behind` in `AGENTS.md`
>
> </details>
</details>

No. The docs do not say implementation must always use abstract classes.

They currently specify a narrower and healthier rule:

- Third-party infrastructure—Dio, DuckDB, secure storage, preferences, analytics—must sit behind application-owned contracts.
- Domain repository contracts separate domain logic from data implementations.
- Abstractions must represent a genuine boundary, enable substitution, or protect domain policy.
- Creating an interface merely to mirror every concrete class is explicitly discouraged in [clean-architecture.md](./docs/architecture/clean-architecture.md:33).

The key wording is also present in:

- [AGENTS.md](./AGENTS.md:40)
- [coding-standards.md](./docs/engineering/coding-standards.md:22)

So the intended rule is:

> Use abstract interfaces/contracts at architectural and infrastructure boundaries—not for every class.

For example, repository, clock, database, networking, storage, and analytics contracts should generally be abstract interfaces. Entities, value objects, BLoCs, use cases, mappers, validators, and ordinary utilities do not automatically require an abstract class.

> this is fine

Great. We’ll keep the rule as-is: abstractions at meaningful boundaries, not abstract classes everywhere.

> lets add the templates for blocs, router, screens and data classes other meaningful classes and tests so that out come is always deterministic

Yes, but we should template architectural patterns—not every class. Otherwise the repository may produce deterministic boilerplate while still making poor design choices.

No files changed yet; this is the proposed plan.

## Proposed template set

```text
docs/templates/
├── README.md
├── feature-structure.md
├── bloc.md
├── page-and-screen.md
├── routing.md
├── domain-models.md
├── use-case.md
├── repository.md
├── data-source.md
├── dto-and-mapper.md
├── database-query.md
├── app-domain-event.md
├── failure-and-result.md
└── tests/
    ├── unit-test.md
    ├── bloc-test.md
    ├── widget-test.md
    ├── repository-integration-test.md
    ├── duckdb-integration-test.md
    └── backend-test.md
```

Each document would contain:

- When the template should and should not be used
- Canonical file names and locations
- Dependency/import rules
- Minimal Dart or TypeScript skeleton
- Required test companion
- Determinism rules
- Common prohibited patterns
- Completion checklist

## Example conventions

### BLoC

```text
presentation/
├── bloc/
│   ├── fleet_bloc.dart
│   ├── fleet_event.dart
│   └── fleet_state.dart
├── pages/
│   └── fleet_page.dart
└── widgets/
    └── fleet_view.dart
```

Rules:

- BLoC event names describe presentation inputs.
- States are immutable sealed unions.
- Use cases are constructor-injected.
- No `get_it`, Dio, DuckDB, routing, or direct analytics SDK access.
- Every event handler emits deterministic loading/success/failure states.
- Time-dependent behavior uses an injected clock.
- Event transformers must be selected intentionally.
- Every BLoC has a `bloc_test` companion.

### Page versus view

- `*Page` owns route-level dependency wiring and BLoC provision.
- `*View` renders and reacts to BLoC state.
- Reusable UI goes into focused widgets.
- Widgets never query repositories directly.
- Navigation effects use explicit listeners, not widget-build side effects.

### Router

- One owned `go_router` configuration.
- Typed route names and centralized paths.
- Route parameters validated before creating a page.
- Redirect logic contains no direct storage/network calls.
- Routes do not resolve dependencies through global service location except at the approved composition boundary.
- Router behavior receives focused tests.

### Data classes

We should keep distinct templates for:

- Domain entity/value object
- Generated OpenAPI DTO
- DuckDB record
- Mapper
- BLoC state
- App-level domain event

That prevents one “data model” from leaking across every layer.

### Tests

Every test template would use:

```text
Given
When
Then
```

with deterministic:

- Clock
- IDs
- UTC timestamps
- Fixture builders
- Temporary database location
- Cleanup
- Packet ordering
- Random seeds
- Expected SQL results

Tests must avoid real network calls, current wall-clock time, shared databases, arbitrary delays, and test-order dependencies.

## Important limitation

Templates improve structural consistency, but they must not authorize blind generation. `AGENTS.md` should say:

> Select a template only after the planning conversation confirms the class’s responsibility and architectural layer. Do not create every template for every feature. Delete unused template sections and never create placeholder classes solely for symmetry.

## Decisions needed before writing

1. Should these be Markdown reference templates only, keeping the repository implementation-free for now?
2. Should templates include complete compilable examples or smaller illustrative skeletons? I recommend minimal skeletons so they do not become copied demo-domain code.
3. For BLoC states, should the standard be Freezed unions, while simple immutable value objects may use either Freezed or handwritten classes?
4. Should test naming use `given_when_then` descriptions or natural-language behavior descriptions? I recommend natural-language test names with Given/When/Then organization inside the test.
5. Should we include backend controller/service/repository templates now, or limit this round to Flutter plus backend tests?

Once these are confirmed, I’ll present the final file plan and wait for your explicit instruction to write the templates.

> 1. yes
> 2. add minimal illustrative skeletons
> 3. lets use freezed&#x20;
> 4. yes use `given_when_then`
> 5. include backend controller/service/repository templates

<details><summary>1 previous message</summary>

> Confirmed. These will be Markdown reference templates
</details>

Confirmed. The templates will be Markdown references with minimal illustrative skeletons, not application scaffolding.

## Final template plan

```text
docs/templates/
├── README.md
├── flutter/
│   ├── feature-structure.md
│   ├── bloc.md
│   ├── page-view-widget.md
│   ├── router.md
│   ├── domain-model.md
│   ├── use-case.md
│   ├── repository.md
│   ├── data-source.md
│   ├── dto-record-mapper.md
│   ├── database-query.md
│   ├── app-domain-event.md
│   └── failure-result.md
├── backend/
│   ├── controller.md
│   ├── service.md
│   ├── repository.md
│   └── transport-model.md
└── tests/
    ├── unit-test.md
    ├── bloc-test.md
    ├── widget-test.md
    ├── duckdb-integration-test.md
    ├── flutter-integration-test.md
    └── backend-test.md
```

Standards:

- Freezed unions for BLoC events and states.
- Freezed for immutable domain/data models when appropriate.
- Generated OpenAPI DTOs remain transport-layer types.
- Abstract interfaces only at meaningful boundaries.
- Test names follow `given_<condition>_when_<action>_then_<result>`.
- Tests use explicit Given/When/Then sections.
- Fixtures use UTC timestamps, injected clocks, deterministic IDs, fixed random seeds, and isolated temporary databases.
- Backend templates maintain controller → service → repository separation.
- Controllers own transport concerns.
- Services orchestrate application behavior.
- Repositories own persistence boundaries.
- Templates prohibit blind creation of unused layers or placeholder classes.

I’ll also update:

- `AGENTS.md` to require consulting applicable templates after planning.
- `context.md` to add the template documentation route.
- `coding-standards.md` with template selection rules.
- `testing-strategy.md` with the approved naming convention.
- The documentation map so future agents can locate these references.

No files have been changed in this planning round. To authorize the documentation edits, say:

> Write the approved Markdown templates. Do not scaffold application code.

> Write the approved Markdown templates. Do not scaffold application code.

<details><summary>7 previous messages</summary>

> I’ll add only the approved Markdown reference templates and update the existing documentation routes/conventions. I won’t create Flutter, Dart, TypeScript, configuration, or generated application files.
>
> <details><summary>Created 13 files, explored a search, a list, ran a command</summary>
>
> <details><summary>Explored a search, a list</summary>
>
> - Listed files
> - Searched for `template|Test naming|Documentation routing|Documentation map` in `AGENTS.md`
>
> </details>
>
> - Ran `mkdir -p docs/templates/flutter docs/templates/backend docs/templates/tests`
>
> - Wrote `./docs/templates/README.md` (+30 -0)
> - Wrote `./docs/templates/flutter/bloc.md` (+54 -0)
> - Wrote `./docs/templates/flutter/domain-model.md` (+48 -0)
> - Wrote `./docs/templates/flutter/feature-structure.md` (+37 -0)
> - Wrote `./docs/templates/flutter/page-view-widget.md` (+52 -0)
> - Wrote `./docs/templates/flutter/router.md` (+50 -0)
>
> - Wrote `./docs/templates/flutter/app-domain-event.md` (+41 -0)
> - Wrote `./docs/templates/flutter/data-source.md` (+43 -0)
> - Wrote `./docs/templates/flutter/database-query.md` (+36 -0)
> - Wrote `./docs/templates/flutter/dto-record-mapper.md` (+60 -0)
> - Wrote `./docs/templates/flutter/failure-result.md` (+28 -0)
> - Wrote `./docs/templates/flutter/repository.md` (+47 -0)
> - Wrote `./docs/templates/flutter/use-case.md` (+46 -0)
>
> </details>
>
> The Flutter templates now define consistent boundaries without requiring abstract classes everywhere. They also explicitly prohibit copying illustrative behavior blindly. Next I’m adding the TypeScript controller/service/repository references and deterministic test patterns.
>
> <details><summary>Created 10 files, edited 6 files, explored 4 files, ran a command</summary>
>
> - Wrote `./docs/templates/backend/controller.md` (+37 -0)
> - Wrote `./docs/templates/backend/repository.md` (+39 -0)
> - Wrote `./docs/templates/backend/service.md` (+35 -0)
> - Wrote `./docs/templates/backend/transport-model.md` (+25 -0)
>
> - Wrote `./docs/templates/tests/backend-test.md` (+47 -0)
> - Wrote `./docs/templates/tests/bloc-test.md` (+38 -0)
> - Wrote `./docs/templates/tests/duckdb-integration-test.md` (+48 -0)
> - Wrote `./docs/templates/tests/flutter-integration-test.md` (+38 -0)
> - Wrote `./docs/templates/tests/unit-test.md` (+33 -0)
> - Wrote `./docs/templates/tests/widget-test.md` (+31 -0)
>
> <details><summary>Explored 4 files</summary>
>
> - Read `./AGENTS.md`
> - Read `./context.md`
> - Read `./docs/engineering/coding-standards.md`
> - Read `./docs/engineering/testing-strategy.md`
>
> </details>
>
> - Wrote `./AGENTS.md` (+8 -6)
> - Wrote `./context.md` (+1 -1)
> - Wrote `./docs/engineering/coding-standards.md` (+4 -0)
> - Wrote `./docs/engineering/testing-strategy.md` (+1 -1)
>
> - Wrote `./docs/templates/flutter/app-domain-event.md` (+2 -4)
> - Wrote `./docs/templates/flutter/repository.md` (+1 -1)
>
> - Ran ````rg --files docs/templates | sort && rg -n "given_<condition>|docs/templates|abstract interface class|UnimplementedError|IList" AGENTS.md context.md docs && while IFS= read -r file; do count=$(rg -c '^```' "$file"); if [ $((count % 2)) -ne 0 ]; then echo "unbalanced fences: $file ($count)"; fi; done < <(rg --files -g '*.md')````
>
> </details>
>
> All 23 template documents are now added, and the existing AI, context, coding, and testing guidance points to them. I’m completing a final scope check: Markdown fences are balanced, naming rules are consistent, and no application scaffolding has been introduced.
>
> <details><summary>Ran a command</summary>
>
> - Ran `find . -type f | sort | sed -n '1,120p' && printf '%s\n' "Markdown files: $(rg --files -g '*.md' | wc -l | tr -d ' ')" "Template files: $(rg --files docs/templates -g '*.md' | wc -l | tr -d ' ')"`
>
> </details>
>
> <details><summary>Plan</summary>
>
> Added the approved Markdown-only reference templates, linked them from existing guidance, and verified the template inventory and Markdown fence balance. No application or configuration files were created.
>
> - [x] Create the approved Markdown template directories and index
> - [x] Add Flutter, backend, and testing reference templates
> - [x] Update existing documentation routes and verify Markdown-only scope
>
> </details>
</details>

Added 23 Markdown reference templates under [docs/templates](./docs/templates/README.md):

- Flutter: feature structure, BLoC, page/view/widget, router, domain models, use cases, repositories, data sources, DTOs/mappers, database queries, app events, and failures.
- Backend: controllers, services, repositories, and transport models.
- Tests: unit, BLoC, widget, DuckDB integration, Flutter integration, and backend patterns.

Also updated:

- [AGENTS.md](./AGENTS.md:26)
- [context.md](./context.md:90)
- [coding-standards.md](./docs/engineering/coding-standards.md:12)
- [testing-strategy.md](./docs/engineering/testing-strategy.md:59)

The templates enforce Freezed models, meaningful boundary interfaces, `given_when_then` test naming, deterministic clocks/IDs/fixtures, and controller → service → repository backend separation.

Verified all Markdown fences are balanced. No application, configuration, or generated code was scaffolded.

> verify if we have everything to start the implementation

<details><summary>2 previous messages</summary>

> I’ll audit the current foundation against what is required to begin a deterministic first implementation slice. I’ll separate true blockers from decisions that can safely remain feature-specific; I won’t modify anything.
>
> <details><summary>Explored 4 files, a search, a list</summary>
>
> - Listed files
> - Searched for `open decision|open decisions|remains|remain |TBD|TODO|subject to|requires.*decision|before implementation|before schema|not.*selected|illustrative` in `AGENTS.md`
> - Read `./context.md`
> - Read `./docs/architecture/data-and-sync.md`
> - Read `./docs/architecture/geofences-and-trips.md`
> - Read `./docs/product/requirements.md`
>
> </details>
</details>

The architecture foundation is strong enough to begin implementation planning, but not yet sufficient to start coding without making assumptions.

## What is complete

The docs adequately define:

- Product scope and exclusions
- Flutter/Node monorepo boundaries
- Clean Architecture and dependency direction
- BLoC, use-case, and app-event separation
- DuckDB source-of-truth requirements
- Bootstrap and SSE synchronization model
- Packet validation, deduplication, and retention
- Vehicle status and freshness rules
- Alert lifecycle, dismissal, and Undo
- Geofence and trip behavior
- Testing strategy and deterministic templates
- GitLab CI, coverage, generation, and reporting
- Security and analytics boundaries
- Definition of done and AI planning workflow

## Blocking decisions before scaffolding

These cannot safely be invented:

1. Project identity

   - Product/display name
   - Dart package name
   - Android application ID
   - iOS bundle identifier
   - Server package name

2. Backend implementation

   - HTTP framework: Fastify, Express, or another option
   - SQLite driver
   - Runtime schema-validation library
   - Backend port and local mobile-to-server configuration

3. Contract generation

   - OpenAPI generator
   - Dart and TypeScript generation targets
   - Exact generated-code locations
   - SSE event envelope and replay-gap error schema

4. Shared primitives

   - Owned `Result` implementation versus an approved package
   - Clock and deterministic ID contracts
   - App-event bus implementation
   - Database-change notification mechanism

5. Project bootstrap

   - Android minimum SDK
   - Application environments: development/demo/test only, or more
   - Configuration approach for API base URLs
   - Root workspace scripts and command names

## Decisions required before domain processing

These do not block basic repository scaffolding, but must be resolved before their relevant features:

- Future timestamp tolerance
- Stable tie-break for conflicting packet timestamps
- Alert episode/occurrence identity
- Geofence transition identity
- Safe late-event replay window
- SSE delivery-log retention size and replay-gap recovery
- Exact schema for structured signal values
- Exact database tables, indexes, and projection strategy
- Fleet UI visual/accessibility direction

These unresolved areas are correctly visible in [context.md](./context.md:78), [data-and-sync.md](./docs/architecture/data-and-sync.md:20), and [geofences-and-trips.md](./docs/architecture/geofences-and-trips.md:43).

## Recommended first implementation slice

The safest first slice is repository bootstrap only:

```text
1. Pin runtimes and workspace tooling
2. Create Flutter and Node applications
3. Establish formatting, linting, and test commands
4. Add minimal OpenAPI contract and deterministic generation
5. Configure GitLab validation/test jobs
6. Add smoke tests proving both applications build
```

It should not yet implement fleet features, DuckDB schemas, SSE processing, or business logic.

So the verdict is: **the engineering foundation is ready, but we need one focused setup-planning round before implementation begins.** No files were modified during this audit.

> lets do this.&#x20;
>
> 1. Pin runtimes and workspace tooling
> 2. Create Flutter and Node applications
> 3. Establish formatting, linting, and test commands
> 4. Add minimal OpenAPI contract and deterministic generation
> 5. Configure GitLab validation/test jobs
> 6. Add smoke tests proving both applications build

<details><summary>4 previous messages</summary>

> I’ll treat this as the setup slice entering its required planning phase. I’ll inspect the available toolchain and current documentation, then propose exact packages, generators, commands, and CI jobs. I won’t scaffold or edit until you approve that concrete plan and explicitly tell me to implement it.
>
> <details><summary>Ran a command</summary>
>
> - Ran `command -v fvm || true
> command -v flutter || true
> command -v dart || true
> command -v node || true
> command -v pnpm || true
> command -v java || true
> fvm --version 2>/dev/null || true
> flutter --version 2>/dev/null || true
> node --version 2>/dev/null || true
> pnpm --version 2>/dev/null || true
> java -version 2>&1 | sed -n '1,3p'
> rg --files -g '!**/.DS_Store' | sort`
>
> </details>
>
> The workspace currently has no Flutter/FVM, Node/pnpm, or usable Java runtime on `PATH`. That doesn’t prevent planning, but it means implementation and smoke verification will require installing or exposing the pinned toolchains. I’m checking the generator choices now because the Dart client must use Dio and local generation must remain reproducible.
>
> <details><summary>Searched the web</summary>
>
> Searched the web for `site:openapi-generator.tech/docs/generators/dart-dio OpenAPI Generator dart dio ...`
>
> Searched the web for `site:nodejs.org/docs/latest-v24.x/api/sqlite.html node sqlite stability ...`
>
> </details>
</details>

This setup slice is well-defined, but implementation needs a few explicit decisions first. The local machine currently has no Flutter/FVM, Node/pnpm, or usable Java runtime available on `PATH`.

## Proposed setup plan

### Repository layout

```text
/
├── apps/
│   ├── mobile/
│   └── server/
├── contracts/
│   └── openapi.yaml
├── tooling/
│   └── openapi/
├── docs/
├── .gitlab-ci.yml
├── .nvmrc
├── package.json
├── pnpm-lock.yaml
└── pnpm-workspace.yaml
```

No `packages/` workspace will be created until sharing is justified.

### Flutter application

Create the mobile application with:

- Flutter `3.47.0` through FVM
- Android, iOS, and web runner projects
- Repository-owned `analysis_options.yaml` extending `flutter_lints`
- Minimal untouched app entry point
- One smoke widget test
- Root commands for format, analyze, test, and build
- No fleet features, DuckDB schema, routing, BLoCs, or business logic yet

Flutter scaffolding generates Kotlin/Swift host-runner boilerplate. This needs a narrow exception to the native-code prohibition: generated platform runner code is allowed, but handwritten native implementation remains prohibited.

### Node application

Recommended stack:

- Express 5 because Supertest is already approved
- Strict TypeScript with ESM
- Zod for runtime boundary validation
- Vitest and Supertest
- Prettier
- ESLint flat configuration with type-aware `typescript-eslint`
- Minimal health endpoint and smoke test
- No telemetry simulator or SQLite implementation yet

For SQLite, I recommend `better-sqlite3` later rather than selecting `node:sqlite` now; Node currently marks its built-in SQLite API as release-candidate stability. [Node SQLite documentation](https://nodejs.org/api/sqlite.html)

### OpenAPI

Recommended tooling:

- OpenAPI Generator pinned to `7.24.0`
- `dart-dio` generator for the committed Dart client; it is officially classified as stable. [Dart Dio generator](https://openapi-generator.tech/docs/generators/dart-dio/)
- `openapi-typescript` for committed TypeScript server contract types
- Redocly CLI or Spectral for contract linting
- CI regenerates both targets and fails on a dirty diff

OpenAPI Generator requires Java 11 or later locally, even through its npm wrapper. [OpenAPI Generator CLI](https://github.com/OpenAPITools/openapi-generator-cli)

Minimal endpoints:

```text
GET /health
GET /bootstrap
GET /telemetry?after=<cursor>
```

Minimal schemas:

```text
Vehicle
TelemetryPacket
TelemetryValue
TelemetryDelivery
BootstrapResponse
ApiError
ReplayGap
```

The packet remains generic enough to retain unsupported signals:

```text
packetId
vehicleId
eventTimestamp
signalName
value: number | boolean | string | location object | null
```

### Commands

Proposed root commands:

```text
pnpm format
pnpm format:check
pnpm lint
pnpm typecheck
pnpm test
pnpm test:coverage
pnpm generate
pnpm generate:check
pnpm build
```

Flutter-specific commands will be wrapped through FVM so local and CI execution use the same SDK.

### GitLab CI

Merge-request jobs:

```text
contract_validate
generated_code_check
server_format_lint_typecheck
server_test
server_build
flutter_format_analyze
flutter_test
flutter_build_android
```

The post-merge Android end-to-end job will be configured structurally but can remain inactive until an actual integration test exists. A fake passing integration job would be misleading.

## Decisions required

Please provide or approve these:

1. Product identity:

   - Display name
   - Dart package name
   - Android application ID
   - iOS bundle identifier
   - Node package name

2. Approve generated Kotlin/Swift platform-runner boilerplate while continuing to prohibit handwritten native code?

3. Approve Express 5, Zod, `better-sqlite3`, ESLint flat config, typescript-eslint, and Prettier?

4. Approve OpenAPI Generator `dart-dio` plus `openapi-typescript` and a Java 17 local/CI requirement?

5. Should I initialize a local Git repository? The directory is not currently a Git repository. I would initialize it without configuring a remote or creating a commit.

6. Toolchain installation will require downloads and system/user-level setup. When implementation begins, should I install FVM, Flutter 3.47.0, Node 24.19.0, pnpm, and Java 17 where missing, or should I only create the repository files and leave installation instructions?

After these are confirmed, I’ll produce the final affected-file and verification plan and wait for the explicit implementation command.

> Display name: ByteBeams&#x20;
> Dart package name: bytebeams
> Android application ID: com.bytebeams.fleet
> iOS bundle identifier: com.bytebeams.fleet
> Node package name: @bytebeams/fleet
>
> Approved
>
> Approved
>
> Approved
>
> No - i will do that myself
>
> yes

All setup decisions are confirmed.

## Approved configuration

```text
Display name:           ByteBeams
Dart package:           bytebeams
Android application ID: com.bytebeams.fleet
iOS bundle identifier:  com.bytebeams.fleet
Node package:           @bytebeams/fleet
```

Also approved:

- Generated Kotlin and Swift runner boilerplate only
- No handwritten native implementation without later approval
- Express 5, Zod, `better-sqlite3`
- ESLint flat configuration, type-aware typescript-eslint, Prettier
- OpenAPI Generator `dart-dio`
- `openapi-typescript`
- Java 17 requirement
- Installation of FVM, Flutter 3.47.0, Node 24.19.0, pnpm, and Java 17
- No Git initialization; you will handle that yourself

## Implementation sequence

1. Install and verify the approved toolchains.
2. Create the pnpm workspace and root commands.
3. Scaffold Flutter for Android, iOS, and web.
4. Scaffold the strict TypeScript/Express server.
5. Add the minimal OpenAPI contract.
6. Configure deterministic Dart and TypeScript generation.
7. Commit generated sources into the workspace.
8. Configure formatting, analysis, linting, type-checking, testing, coverage, and builds.
9. Add Flutter and server smoke tests.
10. Add GitLab merge-request jobs.
11. Update `context.md` with the newly resolved setup decisions.
12. Run generation, format checks, analysis, tests, server build, and Android debug build.

Because the directory will remain outside Git until you initialize it, the local generation check will compare regenerated temporary output. GitLab CI will additionally use Git’s clean-diff check.

Toolchain installation writes outside the workspace and downloads packages, so the environment may show approval prompts during implementation.

No files were changed during this planning round. To authorize execution, say:

> Implement the approved setup plan.

> Implement the approved setup plan.

<details><summary>4 previous messages</summary>

> I’m starting the approved setup implementation now. I’ll install the pinned toolchains first, then scaffold the two applications and contracts, wire validation/CI, and finish by running the smoke builds and tests. I’ll keep application features and business logic out of this slice.
>
> <details><summary>Ran 2 commands</summary>
>
> - Ran `uname -m
> command -v brew || true
> command -v curl || true
> command -v git || true
> command -v xcodebuild || true
> command -v docker || true
> ls -la`
> - Ran `mkdir -p .toolchains/fvm-cache/versions .toolchains/pub-cache .toolchains/downloads && curl -fL https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.47.0-stable.zip -o .toolchains/downloads/flutter.zip && unzip -q .toolchains/downloads/flutter.zip -d .toolchains/downloads/flutter-extract && mv .toolchains/downloads/flutter-extract/flutter .toolchains/fvm-cache/versions/3.47.0 && curl -fL https://nodejs.org/dist/v24.19.0/node-v24.19.0-darwin-arm64.tar.gz -o .toolchains/downloads/node.tar.gz && tar -xzf .toolchains/downloads/node.tar.gz -C .toolchains && ln -sfn node-v24.19.0-darwin-arm64 .toolchains/node && curl -fL 'https://api.adoptium.net/v3/binary/latest/17/ga/mac/aarch64/jdk/hotspot/normal/eclipse' -o .toolchains/downloads/java.tar.gz && mkdir -p .toolchains/java-extract && tar -xzf .toolchains/downloads/java.tar.gz -C .toolchains/java-extract && mv .toolchains/java-extract/*/Contents/Home .toolchains/java-17`
>
> </details>
>
> The pinned Flutter archive is downloading successfully; it is unusually large (about 2.1 GB for this macOS release), so toolchain setup is the slowest part of the slice. The workspace content itself remains untouched so far except for the ignored local toolchain staging directory.
>
> <details><summary>Plan</summary>
>
> - [ ] Install and verify pinned FVM, Flutter, Node, pnpm, and Java toolchains
> - [ ] Create pnpm workspace and scaffold Flutter and TypeScript applications
> - [ ] Add OpenAPI contract and deterministic committed generation
> - [ ] Configure formatting, linting, tests, builds, and GitLab CI
> - [ ] Run smoke verification and update project context
>
> </details>
</details>
