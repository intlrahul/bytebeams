# ByteBeams Fleet

ByteBeams Fleet is a local-first Android demo for operating approximately 500
electric vehicles. A Flutter client persists authoritative fleet data in
DuckDB, while a local Node.js server provides deterministic bootstrap data and
replayable live telemetry over Server-Sent Events (SSE).

## Reviewer access

This is a private GitHub repository. Access has been granted to
`hiring@bytebeam.io` and `pranavk@bytebeam.io` as project collaborators; they
can review the repository at
[github.com/intlrahul/bytebeams](https://github.com/intlrahul/bytebeams).

## AI Chat History

[`PROMPT_HISTORY.md`](PROMPT_HISTORY.md) records the complete development
conversation. I used Codex through a ChatGPT Plus subscription and consumed one
full weekly usage quota plus an additional 15% quota while developing this
project. I did not manually write any line of code: I created the initial plan,
made the product and architecture decisions, reviewed the results, and refined
the plan as the implementation evolved; Codex generated the repository changes
under that direction.

## Start with the documentation

This repository was developed using an **AI-first workflow**. Product intent,
architecture, decisions, acceptance criteria, and validation evidence were
documented before and alongside implementation. Review the documentation as
the foundation of the code:

1. [Project context](context.md)
2. [Product brief](docs/product/product-brief.md)
3. [Architecture overview](docs/architecture/overview.md)
4. [Implementation milestones](docs/delivery/implementation-plan.md)
5. [Performance evidence](docs/delivery/PERFORMANCE.md)
6. [Architecture decisions](docs/architecture/decisions/)
7. [Prompt history](PROMPT_HISTORY.md)

The [OpenAPI contract](contracts/openapi.yaml) is the transport source of
truth. Testing and completion expectations are in the
[testing strategy](docs/engineering/testing-strategy.md) and
[definition of done](docs/delivery/definition-of-done.md).

## Demo data and live telemetry

The normal demo does not use a manual script to insert vehicles or telemetry
directly into the mobile database. The local server supplies synthetic data:

- `GET /bootstrap` returns 500 vehicles, a telemetry backfill, and a consistent
  delivery cursor.
- `GET /telemetry` keeps an SSE connection open and emits deterministic,
  time-based mock events with cursor replay and `Last-Event-ID` reconnection.
- The mobile app commits received data to DuckDB and renders only committed
  local state.

The two-million-row generator is isolated to the performance integration test;
it is not the application demo-data path. See
[data and synchronization](docs/architecture/data-and-sync.md).

## Prerequisites

Install the pinned toolchains rather than substituting newer versions:

- Node.js `24.19.0` (`.nvmrc`)
- pnpm `11.22.0` through Corepack
- FVM `4.1.4` and Flutter `3.47.0`
- Java 17
- Android Studio, Android SDK, and ADB platform tools

## First-time setup

From the repository root:

```sh
nvm use
corepack enable pnpm
corepack prepare pnpm@11.22.0 --activate
pnpm install --frozen-lockfile
fvm install
fvm flutter pub get --directory apps/mobile --enforce-lockfile
pnpm generate:check
fvm flutter doctor -v
adb devices
```

Create and start an Android emulator before running the mobile or integration
commands. Android is the validated target; see the
[project context](context.md) for platform scope.

## Run the demo

Start the backend from the repository root:

```sh
pnpm --filter @bytebeams/fleet dev
```

It creates its SQLite data under `apps/server/.data/` and listens on
`http://localhost:3000`. Keep it running while demonstrating live sync. Android
emulators connect to it through `http://10.0.2.2:3000`.

In another terminal, run the mobile app:

```sh
cd apps/mobile
fvm flutter run -d emulator-5554
```

Replace `emulator-5554` with the identifier reported by `adb devices`.

## Unit tests and quality checks

```sh
pnpm test                  # server plus Flutter unit/widget tests
pnpm lint                  # ESLint plus Flutter analysis
pnpm typecheck             # TypeScript type checking
pnpm format:check
pnpm generate:check        # committed OpenAPI artifacts are current
```

Flutter line coverage has a `90%` minimum (currently `93.84%`).
Server tests enforce their configured coverage thresholds.
The complete validation workflow is available through
[`tooling/preflight.sh`](tooling/preflight.sh).

## Android integration tests

With an emulator or Android device running:

```sh
pnpm test:flutter:integration
```

This exercises the application smoke path and real DuckDB persistence,
migrations, replay, retention, and projection behavior.

## Fleet-scale performance test

Select the Android target and run:

```sh
PERF_DEVICE_ID=emulator-5554 pnpm test:flutter:performance
```

The automated integration harness creates an isolated database containing 500
vehicles and 2,000,000 signal rows, then reports:

- time to the first populated fleet frame;
- warm Fleet Home query p50 and p95;
- database size;
- process PSS/RSS and heap memory while the list is idle.

The JSON report is written to
`apps/mobile/build/performance/fleet-scale.json`. The measured Pixel 10 Pro
emulator baseline is a 3.440 s first populated frame, 529.102 ms query p50,
615.656 ms query p95, and 411,667 KB total PSS under integration-test/debug
instrumentation. Read the method, diagnosis, retention policy, and limitations
in [PERFORMANCE.md](docs/delivery/PERFORMANCE.md).

## Known limitations

- Android is validated; iOS and web DuckDB compatibility remain separate work.
- The backend is deterministic local demo infrastructure, not a production
  telemetry service.
- Authentication is intentionally out of scope for this take-home.
- Current scale measurements are reported honestly and identify the raw-history
  query path as an optimization opportunity.
