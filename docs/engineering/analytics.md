# Analytics and Diagnostics

Reserve **telemetry** for vehicle signal packets. Application instrumentation is **analytics**.

## Owned contracts

- `AnalyticsTracker`: product and workflow events.
- `DiagnosticsReporter`: structured debug and error diagnostics.
- `CrashReporter`: fatal and non-fatal exception reporting.
- `PerformanceMonitor`: operation and screen timing.

Initial adapters are `NoOp*` and sanitized `Debug*` implementations. No external vendor or network transmission is approved.

## Console API diagnostics

The app-owned Dio interceptor logs request lifecycle metadata only in debug
builds: HTTP method, URL path without query parameters, response status,
duration, and safe Dio error type. Console severity uses ANSI colours (debug
grey, info cyan, warning yellow, and error red). Release builds use a no-op
logger.

It never logs request or response bodies, headers, query values, SSE frames,
vehicle telemetry, identifiers, secrets, or stack traces. The interceptor is
attached once in the application composition root, not in data sources.

## Rules

- Provider SDKs remain behind owned adapters.
- Analytics failure never changes a business result or crashes the app.
- Use typed or centrally declared event names and properties.
- Never record raw packet payloads, vehicle telemetry values, secrets, secure-storage values, stack traces containing sensitive inputs, or personal data.
- Prefer counts, classifications, durations, and sanitized operation identifiers.
- Debug output is disabled or sanitized in release builds.
- Inject contracts so tests can assert important events without a vendor SDK.

## Suggested operational coverage

The sync coordinator emits `telemetry.packet.received` after a delivery commits locally. Its only property is the safe `signalName`; it never includes packet or vehicle identifiers, raw values, or payloads. It then emits `fleet.data.committed` with the safe `packetCount` immediately before publishing the payload-free app event that causes DuckDB-backed UI reads to refresh.

When implementation is planned, consider sanitized events for bootstrap outcome, SSE connection/reconnect/replay gap, ingestion classification counts, migration outcome, projection/replay duration, and retention cleanup. Event names and properties require approval with the implementing feature; this list is not permission to add them silently.

Analytics never substitutes for durable alert, transition, trip, or sync state.
