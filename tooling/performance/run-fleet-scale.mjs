import { spawn } from "node:child_process";
import { execFile } from "node:child_process";
import { mkdir, writeFile } from "node:fs/promises";
import { promisify } from "node:util";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const execFileAsync = promisify(execFile);
const repositoryRoot = resolve(
  dirname(fileURLToPath(import.meta.url)),
  "../..",
);
const mobileRoot = resolve(repositoryRoot, "apps/mobile");
const artifactPath = resolve(mobileRoot, "build/performance/fleet-scale.json");

export function parseConnectedDevices(output) {
  return output
    .split(/\r?\n/u)
    .slice(1)
    .map((line) => line.trim())
    .filter((line) => /^\S+\s+device(?:\s|$)/u.test(line))
    .map((line) => line.split(/\s+/u)[0]);
}

export function parseKeyValueMetrics(line) {
  return Object.fromEntries(
    [...line.matchAll(/([a-z][a-z0-9_]*)=([^\s]+)/gu)].map((match) => [
      match[1],
      /^\d+$/u.test(match[2]) ? Number(match[2]) : match[2],
    ]),
  );
}

export function parseMeminfo(output) {
  const valueFor = (label) => {
    const match = output.match(
      new RegExp(`^\\s*${label}:\\s*([\\d,]+)`, "imu"),
    );
    return match ? Number(match[1].replaceAll(",", "")) : undefined;
  };
  const totals = output.match(
    /TOTAL PSS:\s*([\d,]+).*?TOTAL RSS:\s*([\d,]+)/su,
  );
  const result = {
    total_pss_kb: totals
      ? Number(totals[1].replaceAll(",", ""))
      : valueFor("TOTAL PSS"),
    total_rss_kb: totals
      ? Number(totals[2].replaceAll(",", ""))
      : valueFor("TOTAL RSS"),
    java_heap_kb: valueFor("Java Heap"),
    native_heap_kb: valueFor("Native Heap"),
    graphics_kb: valueFor("Graphics"),
  };
  if (result.total_pss_kb === undefined || result.total_rss_kb === undefined) {
    throw new Error("Could not parse TOTAL PSS and TOTAL RSS from meminfo");
  }
  return result;
}

async function adb(deviceId, ...args) {
  const result = await execFileAsync("adb", ["-s", deviceId, ...args], {
    encoding: "utf8",
    maxBuffer: 10 * 1024 * 1024,
    timeout: 15000,
  });
  return result.stdout.trim();
}

async function selectDevice() {
  const { stdout } = await execFileAsync("adb", ["devices", "-l"], {
    encoding: "utf8",
    timeout: 15000,
  });
  const devices = parseConnectedDevices(stdout);
  const requested = process.env.PERF_DEVICE_ID;
  if (requested) {
    if (!devices.includes(requested)) {
      throw new Error(
        `PERF_DEVICE_ID=${requested} is not an authorized connected device`,
      );
    }
    return requested;
  }
  if (devices.length !== 1) {
    throw new Error(
      `Expected exactly one Android device, found ${devices.length}. Set PERF_DEVICE_ID when multiple devices are connected.`,
    );
  }
  return devices[0];
}

async function readDeviceMetadata(deviceId) {
  const [avdName, model, api, abi, totalMemory] = await Promise.all([
    adb(deviceId, "shell", "getprop", "ro.boot.qemu.avd_name"),
    adb(deviceId, "shell", "getprop", "ro.product.model"),
    adb(deviceId, "shell", "getprop", "ro.build.version.sdk"),
    adb(deviceId, "shell", "getprop", "ro.product.cpu.abi"),
    adb(deviceId, "shell", "cat", "/proc/meminfo"),
  ]);
  return {
    device_id: deviceId,
    environment: avdName || model,
    model,
    android_api: Number(api),
    abi,
    total_memory_kb: Number(totalMemory.match(/\d+/u)?.[0]),
    instrumentation: "Flutter integration-test debug process",
  };
}

async function runBenchmark(deviceId) {
  let outputBuffer = "";
  let benchmarkMetrics;
  let memoryPromise;
  const child = spawn(
    "fvm",
    [
      "flutter",
      "test",
      "-d",
      deviceId,
      "integration_test/fleet_scale_performance_test.dart",
      "--suppress-analytics",
      "--dart-define=PERF_MEMORY_HOLD_SECONDS=30",
    ],
    { cwd: mobileRoot, env: process.env, stdio: ["inherit", "pipe", "pipe"] },
  );

  const inspectOutput = (text) => {
    outputBuffer += text;
    const metricLine = outputBuffer
      .split(/\r?\n/u)
      .find((line) => line.includes("FLEET_SCALE vehicles="));
    if (metricLine && !benchmarkMetrics) {
      benchmarkMetrics = parseKeyValueMetrics(metricLine);
    }
    if (outputBuffer.includes("FLEET_SCALE_MEMORY_READY") && !memoryPromise) {
      memoryPromise = adb(
        deviceId,
        "shell",
        "dumpsys",
        "meminfo",
        "com.bytebeams.fleet",
      ).then(
        (output) => {
          try {
            return { value: parseMeminfo(output) };
          } catch (error) {
            return { error };
          }
        },
        (error) => ({ error }),
      );
    }
  };

  child.stdout.on("data", (chunk) => {
    const text = chunk.toString();
    process.stdout.write(text);
    inspectOutput(text);
  });
  child.stderr.on("data", (chunk) => {
    const text = chunk.toString();
    process.stderr.write(text);
    inspectOutput(text);
  });

  const exitCode = await new Promise((resolveCode, reject) => {
    child.once("error", reject);
    child.once("close", resolveCode);
  });
  if (exitCode !== 0) {
    throw new Error(`Flutter performance integration test exited ${exitCode}`);
  }
  if (!benchmarkMetrics) {
    throw new Error("Flutter benchmark did not emit FLEET_SCALE metrics");
  }
  if (!memoryPromise) {
    throw new Error("Flutter benchmark did not emit its memory-ready marker");
  }
  const memoryResult = await memoryPromise;
  if (memoryResult.error) throw memoryResult.error;
  return { benchmarkMetrics, memoryMetrics: memoryResult.value };
}

async function main() {
  process.stdout.write("Selecting Android performance target...\n");
  const deviceId = await selectDevice();
  process.stdout.write(`Collecting metadata from ${deviceId}...\n`);
  const device = await readDeviceMetadata(deviceId);
  process.stdout.write(
    `Running fleet-scale integration test on ${device.environment}...\n`,
  );
  const { benchmarkMetrics, memoryMetrics } = await runBenchmark(deviceId);
  const report = {
    measured_at_utc: new Date().toISOString(),
    device,
    dataset: {
      vehicles: benchmarkMetrics.vehicles,
      signals: benchmarkMetrics.signals,
    },
    timings: {
      seed_ms: benchmarkMetrics.seed_ms,
      first_painted_ms: benchmarkMetrics.first_painted_ms,
      warm_samples: benchmarkMetrics.warm_samples,
      query_p50_us: benchmarkMetrics.query_p50_us,
      query_p95_us: benchmarkMetrics.query_p95_us,
    },
    database_bytes: benchmarkMetrics.db_bytes,
    memory: memoryMetrics,
  };
  await mkdir(dirname(artifactPath), { recursive: true });
  await writeFile(artifactPath, `${JSON.stringify(report, null, 2)}\n`, "utf8");
  process.stdout.write(
    `\nFLEET_SCALE_REPORT\n${JSON.stringify(report, null, 2)}\n`,
  );
  process.stdout.write(`Report written to ${artifactPath}\n`);
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  main().catch((error) => {
    process.stderr.write(`Fleet-scale benchmark failed: ${error.message}\n`);
    process.exitCode = 1;
  });
}
