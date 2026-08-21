# Reference Templates

These Markdown templates make recurring structures predictable. They are references, not generators and not permission to create every layer for every feature.

## Required workflow

1. Complete the planning conversation and confirm the responsibility, layer, dependencies, and acceptance criteria.
2. Select only the applicable template.
3. Replace illustrative names; do not copy example domain behavior blindly.
4. Remove unused sections and dependencies.
5. Add the required companion tests.
6. Return to planning if the real requirement does not fit the template cleanly.

## Determinism rules

- Inject clocks, ID generators, random sources, and external boundaries.
- Use UTC timestamps and explicit boundary semantics.
- Use immutable Freezed models and exhaustive unions where applicable.
- Keep ordering and tie-breaks explicit.
- Never use arbitrary delays, ambient wall-clock time, shared mutable fixtures, or test-order dependence.
- Keep generated transport types out of the domain layer.
- Use abstract interfaces only at meaningful boundaries, not for every class.

## Catalog

- `flutter/`: feature structure, BLoC, UI, routing, domain/data classes, persistence, and app events.
- `backend/`: controller, service, repository, and transport boundaries.
- `tests/`: unit, BLoC, widget, DuckDB, Flutter integration, and backend tests.

These skeletons are intentionally incomplete. Imports, generated `part` files, and concrete names must follow the approved feature plan.
