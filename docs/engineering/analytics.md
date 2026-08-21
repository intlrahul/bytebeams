# Analytics and Diagnostics

Reserve **telemetry** for vehicle signal packets. Application instrumentation is **analytics**.

## Owned contracts

- `AnalyticsTracker`: product and workflow events.
- `DiagnosticsReporter`: structured debug and error diagnostics.
- `CrashReporter`: fatal and non-fatal exception reporting.
- `PerformanceMonitor`: operation and screen timing.

Initial adapters are `NoOp*` and sanitized `Debug*` implementations. No external vendor or network transmission is approved.

## Rules

- Provider SDKs remain behind owned adapters.
- Analytics failure never changes a business result or crashes the app.
- Use typed or centrally declared event names and properties.
- Never record raw packet payloads, vehicle telemetry values, secrets, secure-storage values, stack traces containing sensitive inputs, or personal data.
- Prefer counts, classifications, durations, and sanitized operation identifiers.
- Debug output is disabled or sanitized in release builds.
- Inject contracts so tests can assert important events without a vendor SDK.

## Suggested operational coverage

When implementation is planned, consider sanitized events for bootstrap outcome, SSE connection/reconnect/replay gap, ingestion classification counts, migration outcome, projection/replay duration, and retention cleanup. Event names and properties require approval with the implementing feature; this list is not permission to add them silently.

Analytics never substitutes for durable alert, transition, trip, or sync state.
