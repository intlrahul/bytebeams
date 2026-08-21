# AI Contributor Instructions

This file is the mandatory entry point for every human or AI contributor. Read `context.md` and the documents relevant to the requested work before proposing a change.

## Required two-phase workflow

### Phase 1: planning

Every new implementation request starts as a planning conversation.

1. Read the applicable repository instructions and documentation.
2. Inspect the existing implementation, generated artifacts, migrations, and tests.
3. Restate the requested outcome and acceptance criteria.
4. Identify ambiguity, missing context, constraints, risks, and affected components.
5. Ask focused questions. Never silently invent product behavior, data contracts, architectural choices, thresholds, or acceptance criteria.
6. Propose an implementation plan, affected files, data or migration impact, tests, validation commands, and trade-offs.
7. Wait for explicit authorization to implement.

Planning and inspection do not authorize edits. Implementation begins only after an unambiguous instruction such as “write the code,” “implement the approved plan,” or “proceed.”

### Phase 2: implementation

After explicit authorization:

1. Follow the approved plan and documented architecture.
2. Consult the applicable reference in `docs/templates/` after the responsibility and layer are confirmed. Templates guide structure; they do not authorize unused classes or layers.
3. Make the smallest scoped change that satisfies the confirmed requirements.
4. Preserve unrelated user work; never overwrite or discard it.
5. Add or update tests and documentation as part of the change.
6. Run relevant formatting, analysis, generation, test, and build checks.
7. Report exactly what changed, what was verified, and what could not be verified.
8. Return to planning if new information materially changes the approved design.

## Non-negotiable rules

- DuckDB is the mobile app's durable source of truth. The UI must not read authoritative fleet data from an in-memory shadow list.
- Vehicle **telemetry** means vehicle sensor packets only. Use **analytics** for product events, diagnostics, performance, and crash reporting.
- Keep BLoC events, domain use cases, and app-level domain events distinct. See `docs/architecture/app-events.md`.
- Do not use Swift or Kotlin without explicit developer approval and documented technical justification.
- Do not introduce a dependency, shared package, abstraction, service, or native implementation without repository evidence or explicit approval.
- Third-party libraries must sit behind application-owned abstractions; domain and presentation code must not depend directly on infrastructure packages.
- Do not expose secrets, sensitive values, raw vehicle telemetry, or packet payloads through logs or analytics.
- Never declare completion while required checks fail. Explain checks that were not run.
- Commit generated OpenAPI clients/models and verify in CI that regeneration produces no diff.
- Record material architectural changes as Architecture Decision Records (ADRs).
- Keep guidance concise, actionable, non-duplicative, and synchronized with the code.

## Documentation routing

- Current decisions and scope: `context.md`
- Product behavior: `docs/product/`
- Architecture and deterministic algorithms: `docs/architecture/`
- Coding, testing, analytics, and security: `docs/engineering/`
- CI and completion criteria: `docs/delivery/`
- Approved structural and test references: `docs/templates/`

If instructions conflict, stop and ask the developer rather than choosing silently.
