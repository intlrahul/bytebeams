import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

const commitlintCli = fileURLToPath(
  new URL("../../node_modules/@commitlint/cli/cli.js", import.meta.url),
);

const fixtures = [
  {
    name: "unscoped feature",
    message: "feat: add fleet status filters",
    valid: true,
  },
  {
    name: "scoped fix",
    message: "fix(mobile): preserve the telemetry cursor",
    valid: true,
  },
  {
    name: "breaking change",
    message:
      "refactor(contracts)!: rename the packet timestamp\n\nBREAKING CHANGE: eventTime replaces timestamp in packet payloads",
    valid: true,
  },
  {
    name: "uppercase type",
    message: "FEAT(mobile): add fleet status filters",
    valid: false,
  },
  {
    name: "unknown type",
    message: "feature(mobile): add fleet status filters",
    valid: false,
  },
  {
    name: "unknown scope",
    message: "feat(database): add the telemetry schema",
    valid: false,
  },
  {
    name: "vague update",
    message: "chore: update",
    valid: false,
  },
  {
    name: "vague changes",
    message: "chore: changes",
    valid: false,
  },
  {
    name: "vague bug fix",
    message: "fix: fix bug",
    valid: false,
  },
  {
    name: "work in progress",
    message: "chore: wip",
    valid: false,
  },
  {
    name: "trailing period",
    message: "docs: explain local setup.",
    valid: false,
  },
  {
    name: "subject with 72 characters",
    message: `docs: ${"a".repeat(72)}`,
    valid: false,
  },
  {
    name: "breaking marker without footer",
    message: "feat(contracts)!: replace the telemetry packet schema",
    valid: false,
  },
  {
    name: "breaking footer without marker",
    message:
      "feat(contracts): replace the telemetry packet schema\n\nBREAKING CHANGE: clients must regenerate transport models",
    valid: false,
  },
];

const fixtureDirectory = mkdtempSync(join(tmpdir(), "bytebeams-commitlint-"));

try {
  for (const [index, fixture] of fixtures.entries()) {
    const messageFile = join(fixtureDirectory, `${index}.txt`);
    writeFileSync(messageFile, `${fixture.message}\n`, "utf8");

    const result = spawnSync(
      process.execPath,
      [commitlintCli, "--edit", messageFile],
      {
        cwd: process.cwd(),
        encoding: "utf8",
      },
    );
    const actualValid = result.status === 0;

    assert.equal(
      actualValid,
      fixture.valid,
      `${fixture.name}: expected valid=${fixture.valid}, exit=${result.status}\n${result.stdout}${result.stderr}`,
    );
  }

  console.log(`Commit message fixtures passed: ${fixtures.length}`);
} finally {
  rmSync(fixtureDirectory, { recursive: true });
}
