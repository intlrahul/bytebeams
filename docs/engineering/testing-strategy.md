# Testing Strategy

## Principles

- Test observable behavior and deterministic rules, not private implementation details.
- Use a real temporary DuckDB database for SQL/persistence integration tests.
- Use injected clocks, deterministic IDs, and deterministic server fixtures.
- A test must reproduce a reported correctness bug before the fix where practical.
- Generated files and platform boilerplate are excluded from coverage; business logic is not.

## Coverage

CI enforces at least **90% line coverage**. Exclusions are limited to:

- Generated Freezed/JSON and OpenAPI files.
- Dependency-registration boilerplate.
- Flutter-generated platform runner code.

Do not exclude domain policies, BLoCs, repositories, SQL integration, mappers, ingestion, alerts, geofences, replay, or trips merely to satisfy the threshold.

Coverage is a guardrail, not a test-design target. Add unit and integration tests because they prove each observable production behavior, branch, failure translation, and boundary condition—not because they increase a percentage. Aim to cover all production behavior; the 10% allowance is reserved only for code that cannot be meaningfully or safely exercised.

## Flutter unit and widget tests

Use `flutter_test`, `bloc_test`, and `mocktail`.

- Table-test validation, freshness boundaries, status fallback, and alert thresholds.
- Test each BLoC's event-to-state behavior and failure states.
- Prefer handwritten stateful fakes where mocks would obscure behavior.
- Test filter counts, empty states, reading verdicts, dismissal reasons, and Undo behavior.
- Golden tests are out of scope.

## DuckDB integration tests

Close and reopen temporary databases to prove durability. Cover:

- Numbered migrations and schema upgrades.
- Atomic bootstrap and recovery from failure.
- Packet deduplication and classification.
- Latest-signal and SQL status/filter projections.
- Alert episodes, escalation, dismissal, expiry, Undo, and replay.
- Geofence versions, accuracy/hysteresis boundaries, overlap tie-breaks, and initial baselines.
- Direct A-to-B transitions, missing intervals, late replay, obsolete-row removal, and trip idempotency.
- Thirty-day retention and quarantine receipt-time behavior.

Use permutations of the same packet set to prove arrival-order independence. Include duplicates and app restart between deliveries.

## Backend tests

Use Vitest and Supertest, a real local server for SSE protocol tests, temporary SQLite, and fake timers/clocks. Cover bootstrap/cursor consistency, deterministic scenarios, `Last-Event-ID`, bounded replay gaps, duplicate delivery, backlog, and restart persistence. Validate requests/responses against OpenAPI.

## Android integration tests

Maintain a small, high-value suite including:

1. Bootstrap → fleet → vehicle detail → alert dismissal → persisted Undo.
2. Late/duplicate locations → transition replay → corrected trip.

Run these asynchronously after a merge to `main`, retain reports/artifacts, and notify through whichever GitLab email/Slack integration is configured.

## Test naming and fixtures

Use `given_<condition>_when_<action>_then_<result>` test names and explicit Given/When/Then organization. Keep fixtures synthetic, minimal, UTC-based, and explain scenario intent. Do not use production or personal data. Use the applicable reference in `docs/templates/tests/` without copying irrelevant setup.

When generating a dynamic test name, use braced Dart interpolation when a variable touches an underscore or alphanumeric text: `${signal}_when`, never `$signal_when`. Do not put shell-style variables or unescaped special syntax in test identifiers.
