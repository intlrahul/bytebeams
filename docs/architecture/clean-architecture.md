# Clean Architecture

## Dependency direction

```text
Presentation → Domain ← Data/Infrastructure
```

### Presentation

Contains Flutter widgets, routes, BLoCs, BLoC events/states, and presentation formatting. A BLoC invokes domain use cases and maps typed failures to explicit UI states. It never executes SQL, calls Dio, reads preferences, or imports generated API models.

### Domain

Contains entities, value objects, repository contracts, use cases, domain policies, failures, and app-level business facts. It imports no Flutter, Dio, DuckDB, `get_it`, storage, code-generation, or provider SDK APIs.

Use cases describe actions and queries such as `GetAllVehicles` or `DismissAlert`. They are not BLoCs and are not event-bus messages.

### Data and infrastructure

Contains repository implementations, database queries, DTOs, mappers, migrations, HTTP/SSE adapters, validation, and third-party wrappers. Infrastructure exceptions are translated at this boundary into application-owned failures.

Generated OpenAPI DTOs stay here:

```text
generated transport DTO → mapper → domain entity/value object
```

## Dependency injection

Use `get_it` only in the application composition root. Domain and presentation objects receive dependencies through constructors. Service location inside business logic, widgets, BLoCs, or repositories is prohibited.

## Abstractions

Own contracts around Dio, DuckDB access, preferences, secure storage, clock/time, analytics, and other external capabilities. Do not create interfaces merely to mirror every class; abstractions must express a boundary, enable substitution, or protect domain policy.

## Error handling

- Domain/application boundaries return typed success/failure results.
- Dio, DuckDB, parsing, SQLite, and storage exceptions do not escape adapters.
- Programming errors are not silently converted into ordinary user failures.
- UI failures are actionable and do not reveal stack traces or internals.
- Debug diagnostics may retain sanitized stack traces.

## Maintainability rules

- Prefer immutable data and explicit state transitions.
- Keep side effects at boundaries.
- Prefer focused use cases and repositories over generic managers.
- Do not add speculative shared packages or base classes.
- Add an ADR before changing dependency direction or source-of-truth ownership.
