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

| Environment | Cleanup | Rebuild | DB before | DB after |
| --- | ---: | ---: | ---: | ---: |
| Android emulator, before set-based rebuild optimization | 67 ms | 17,663 ms (failed budget) | 2,895,872 bytes | 4,730,880 bytes |
| Android developer run | 18 ms | 89 ms | 2,895,872 bytes | 4,730,880 bytes |

The database grew after cleanup because DuckDB retains allocated storage and the harness adds replay checkpoints before `CHECKPOINT`; no fixed size-reduction target applies. Both enforced latency budgets passed.
