# Definition of Done

A change is complete only when all applicable items are true.

## Scope and design

- The developer approved the plan before implementation.
- Acceptance criteria are explicit and satisfied.
- The change follows documented ownership and dependency boundaries.
- New assumptions, dependencies, schemas, native code, or architecture decisions received explicit approval.
- Material decisions have an ADR and relevant context documents are updated.

## Correctness

- Authoritative mobile state persists in DuckDB and survives close/reopen where applicable.
- Duplicate, late, out-of-order, missing, stale, invalid, unsupported, and restart cases are handled when relevant.
- Event-time and wall-clock behavior uses injected clocks and explicit boundaries.
- Migrations and replay are idempotent and preserve history as specified.
- Accessibility, empty, loading, syncing, degraded, and failure states are considered for UI work.

## Quality

- Code is formatted and passes static analysis/type checking.
- Appropriate unit, widget, database integration, backend, contract, and end-to-end tests exist.
- Required line coverage remains at least 90% without unjustified exclusions.
- Generated artifacts are current and regeneration leaves a clean worktree.
- Required builds pass.
- Security and analytics policies are satisfied.

## Handoff

- Documentation describes changed behavior and decisions.
- The implementation report lists changed areas and validation commands/results.
- Skipped or unavailable checks and remaining risks are stated plainly.
- No unrelated user changes were overwritten.
- Do not claim completion while a required check fails.
