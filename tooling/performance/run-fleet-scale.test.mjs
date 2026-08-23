import assert from "node:assert/strict";
import test from "node:test";

import {
  parseConnectedDevices,
  parseKeyValueMetrics,
  parseMeminfo,
} from "./run-fleet-scale.mjs";

test("given_adb_devices_when_parsed_then_returns_only_authorized_devices", () => {
  const output = `List of devices attached
emulator-5554\tdevice product:sdk_gphone model:PIXEL_10_PRO transport_id:1
emulator-5556   device product:sdk_gphone model:PIXEL_9 transport_id:2
offline-1\toffline transport_id:2
unauthorized-1 unauthorized transport_id:3
`;

  assert.deepEqual(parseConnectedDevices(output), [
    "emulator-5554",
    "emulator-5556",
  ]);
});

test("given_benchmark_line_when_parsed_then_returns_numeric_metrics", () => {
  const metrics = parseKeyValueMetrics(
    "FLEET_SCALE vehicles=500 signals=2000000 query_p50_us=537300",
  );

  assert.deepEqual(metrics, {
    vehicles: 500,
    signals: 2000000,
    query_p50_us: 537300,
  });
});

test("given_android_meminfo_summary_when_parsed_then_returns_memory_kilobytes", () => {
  const output = `App Summary
                       Pss(KB)                        Rss(KB)
                        ------                         ------
           Java Heap:    12,345                         18,000
         Native Heap:    23,456                         30,000
            Graphics:     3,210                          4,000
           TOTAL PSS:    45,678            TOTAL RSS:    67,890
`;

  assert.deepEqual(parseMeminfo(output), {
    total_pss_kb: 45678,
    total_rss_kb: 67890,
    java_heap_kb: 12345,
    native_heap_kb: 23456,
    graphics_kb: 3210,
  });
});

test("given_meminfo_without_totals_when_parsed_then_fails", () => {
  assert.throws(
    () => parseMeminfo("No process found"),
    /Could not parse TOTAL PSS and TOTAL RSS/u,
  );
});
