# Coding Standards

## General

- Optimize for clarity, deterministic behavior, and reviewability.
- Use names from the project glossary consistently.
- Keep functions and types focused; avoid generic managers and speculative abstractions.
- Make time, IDs, randomness, network, storage, and analytics injectable at testable boundaries.
- Treat warnings as failures in CI where tooling permits.
- Comments explain constraints and reasoning, not syntax.

## Reference templates

Consult `docs/templates/` only after planning confirms the class responsibility and architectural layer. Use the smallest applicable skeleton, replace illustrative names, remove unused pieces, and add its companion tests. A template is not permission to generate every layer or create a placeholder abstraction.

## Dart and Flutter

- Use the FVM-pinned Flutter SDK and repository-owned `analysis_options.yaml` based on `flutter_lints`.
- Prefer immutable models, exhaustive sealed unions, and explicit nullability.
- Use `freezed` and `json_serializable` where they reduce error-prone boilerplate.
- Keep generated files committed and never edit them manually.
- BLoCs contain presentation orchestration, not SQL or infrastructure details.
- Keep widgets small and derive rendering from explicit BLoC state.
- Access `get_it` only in the composition root; use constructor injection elsewhere.
- Use `go_router` through an owned routing configuration.
- Wrap Dio, DuckDB, secure storage, and preferences behind application-owned contracts.
- Do not add Swift or Kotlin without explicit approval and an ADR.

## TypeScript and Node.js

- Use Node `24.19.0`, pnpm, strict TypeScript, and deterministic fixtures.
- Validate all external input at the transport boundary.
- Keep bootstrap/simulation, delivery-log persistence, and HTTP/SSE transport separable.
- Use parameterized SQLite operations and numbered migrations.
- Do not share backend runtime models directly with mobile domain types; share the OpenAPI contract.

## OpenAPI and generation

- `contracts/openapi.yaml` is authoritative for HTTP and SSE payload schemas.
- Commit generated Dart and TypeScript artifacts.
- Generation must be deterministic and pinned.
- CI regenerates and fails if the worktree differs.
- Generated transport DTOs are mapped to domain models.
- Change the schema first, regenerate, update mappers/tests, and document compatibility impact.

## Dependencies

Every new dependency requires a planning note covering purpose, maintenance, license, platform support, size/security impact, alternatives, and abstraction boundary. Pin versions intentionally. Do not upgrade unrelated dependencies during feature work.

Do not add Melos until a second Dart package, coordinated shared-package commands, or repetitive workspace management justifies it.

## Formatting and naming

Use standard Dart and project-selected TypeScript formatters without manual style exceptions. Use past tense for app-level domain facts, request/occurrence language for BLoC events, and action/query language for use cases.
