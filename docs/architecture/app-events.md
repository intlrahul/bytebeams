# Use Cases, BLoC Events, and App Events

These are separate mechanisms.

## Domain use cases

Use cases are business commands or queries such as `GetAllVehicles`, `DismissAlert`, or `RebuildVehicleTrips`. BLoCs or application services invoke them directly. Use cases do not travel on an event bus.

## BLoC events

BLoC events are presentation inputs scoped to one BLoC, such as `FleetRefreshRequested` or `AlertDismissalSubmitted`. They describe UI/application input and are never globally broadcast.

## App-level domain events

These are typed, past-tense business facts, such as `PaymentCompleted` in a payment domain or `AlertDismissed` in this application. They exist only when independent modules genuinely need to react.

Rules:

- Delivery is asynchronous by default.
- Publish only after the authoritative database transaction commits.
- Keep events typed; string names and untyped payload maps are prohibited.
- Document publisher, payload, and intended consumers.
- Payloads contain no secrets, raw packets, or sensitive telemetry values.
- Subscribers re-query authoritative repositories when they need current state.
- Subscription lifecycle and disposal are explicit.
- Isolate subscriber failures so one consumer cannot block others.
- Consumers handle duplicate notification safely where practical.
- Do not depend on ordering unless an explicit contract and tests define it.
- Durable correctness never depends on the in-memory bus.
- Event handlers must not publish additional app-level domain events. Chaining is prohibited initially; detect and diagnose accidental loops.

Keep a cross-feature event with its owning feature until actual dependencies justify a shared contracts package. Do not use the bus to avoid an ordinary call or database observation.
