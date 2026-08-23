# Milestone 11 retention measurements

Run the deterministic 500-vehicle, 10,000-delivery retention harness on Android after implementation:

```sh
pnpm test:flutter:integration
```

The integration output prints one aggregate line in this form:

```text
M11 cleanup_ms=<actual> rebuild_ms=<actual> db_before=<bytes> db_after=<bytes>
```

Record the device/emulator and the actual values below. Approved budgets are cleanup under 3 seconds and rebuild under 5 seconds; database-size reduction has no fixed target.

| Environment                                             | Cleanup |                   Rebuild |       DB before |        DB after |
| ------------------------------------------------------- | ------: | ------------------------: | --------------: | --------------: |
| Android emulator, before set-based rebuild optimization |   67 ms | 17,663 ms (failed budget) | 2,895,872 bytes | 4,730,880 bytes |
| Android developer run                                   |   18 ms |                     89 ms | 2,895,872 bytes | 4,730,880 bytes |

The database grew after cleanup because DuckDB retains allocated storage and the harness adds replay checkpoints before `CHECKPOINT`; no fixed size-reduction target applies. Both enforced latency budgets passed.

## Fleet-scale performance harness

Run the dedicated Android integration benchmark separately from the routine
integration suite:

```sh
pnpm test:flutter:performance
```

The harness creates an isolated DuckDB database with 500 synthetic vehicles
and 2,000,000 deterministic signal rows using set-based SQL. It measures the
production Fleet Home repository, including its rows and filter-count queries,
after 10 warm-up calls and across 100 recorded calls. It also reports the
in-app cold path from reopening the existing database through the first frame
containing a populated Fleet Home list. A host-side runner detects the connected
Android target, waits for the idle-list marker, captures `dumpsys meminfo`, and
writes the combined JSON report to
`apps/mobile/build/performance/fleet-scale.json`.

When more than one Android target is connected, select one explicitly:

```sh
PERF_DEVICE_ID=emulator-5554 pnpm test:flutter:performance
```

The output contains aggregate measurements only:

```text
FLEET_SCALE vehicles=500 signals=2000000 seed_ms=<ms> db_bytes=<bytes> first_painted_ms=<ms> warm_samples=100 query_p50_us=<microseconds> query_p95_us=<microseconds>
```

`first_painted_ms` begins inside the test process before DuckDB is reopened. It
does not include Android process creation or integration-test instrumentation.
The runner automatically records total PSS, total RSS, Java heap, native heap,
and graphics memory while the populated list is idle. These values include
Flutter integration-test/debug instrumentation and must be labelled as such.
OS-level cold process creation remains outside `first_painted_ms`.

| Environment                                                              |     Seed |           DB size | First populated frame |  Query p50 |  Query p95 | Total PSS at rest |
| ------------------------------------------------------------------------ | -------: | ----------------: | --------------------: | ---------: | ---------: | ----------------: |
| Pixel_10_Pro emulator, Android API 37, arm64-v8a, integration-test/debug | 6,971 ms | 214,708,224 bytes |              3,440 ms | 529.102 ms | 615.656 ms |        411,667 KB |

The automated run completed on `emulator-5554` (`sdk_gphone16k_arm64`) with
4,062,432 KB total emulator memory. At rest with the populated list open, the
process reported 411,667 KB total PSS and 527,136 KB total RSS, including
10,080 KB Java heap, 111,952 KB native heap, and 0 KB attributed graphics.
These process figures include Flutter integration-test/debug instrumentation
and should not be interpreted as release-build memory consumption.

No pass/fail budget has been assigned to these measurements. Record the actual
numbers and diagnose observed latency rather than substituting an estimate.

The measured Fleet Home path is slow at this scale. Each repository call runs
two separate projections over the same 2,000,000-row telemetry table: one for
the visible rows and one for filter counts. Both use a window rank over retained
raw signals to recover the latest value per vehicle and signal. The cold path
also includes opening and migrating the 214 MB DuckDB file before executing
those projections and painting the list.

The next optimization would be a transactionally maintained latest-signal
projection keyed by vehicle and signal. Fleet rows and counts could then read
approximately 3,000 latest records instead of ranking the retained raw log
twice. The raw append-only history would remain authoritative for replay, while
the bounded projection would be rebuilt from retained inputs when necessary.
This architectural change requires its own approval, correctness tests for
late and reordered packets, rebuild validation, and new device measurements.

## Retention policy and information loss

Raw valid, invalid, and unsupported telemetry is retained for 30 days by event
time. Already-too-old quarantined arrivals are retained for 30 days by receipt
time. Trips, geofence transitions, alert history, dismissals, geofence
versions, and replay checkpoints are preserved.

Cleanup removes the raw evidence outside those windows. The app therefore
cannot inspect those expired packets or rebuild pre-boundary projections under
a changed algorithm. Packets arriving older than the retained replay boundary
cannot revise that earlier derived history. Recent fleet state and retained
derived history remain available from DuckDB.
