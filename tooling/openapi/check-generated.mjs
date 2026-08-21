import { mkdtempSync, readFileSync, readdirSync, rmSync, statSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, relative, resolve } from 'node:path';
import { spawnSync } from 'node:child_process';

const workspace = resolve(import.meta.dirname, '../..');
const temporaryRoot = mkdtempSync(join(tmpdir(), 'bytebeams-generated-'));
const targets = [
  'apps/mobile/generated/api_client',
  'apps/server/src/generated/openapi.ts',
];
const ignoredSegments = new Set(['.dart_tool', '.openapi-generator']);

function filesUnder(path, root = path) {
  if (statSync(path).isFile()) return [relative(root, path)];
  return readdirSync(path, { withFileTypes: true })
    .filter((entry) => !ignoredSegments.has(entry.name))
    .flatMap((entry) => {
      const child = join(path, entry.name);
      return entry.isDirectory()
        ? filesUnder(child, root)
        : [relative(root, child)];
    })
    .sort();
}

function compare(target) {
  const committed = resolve(workspace, target);
  const generated = resolve(temporaryRoot, target);
  const committedFiles = filesUnder(committed);
  const generatedFiles = filesUnder(generated);
  if (JSON.stringify(committedFiles) !== JSON.stringify(generatedFiles)) return false;
  return committedFiles.every((file) =>
    readFileSync(join(committed, file)).equals(readFileSync(join(generated, file))),
  );
}

try {
  const result = spawnSync(process.execPath, ['tooling/openapi/generate.mjs'], {
    cwd: workspace,
    env: { ...process.env, BYTEBEAMS_GENERATED_ROOT: temporaryRoot },
    stdio: 'inherit',
  });
  if (result.status !== 0) process.exit(result.status ?? 1);

  const staleTargets = targets.filter((target) => !compare(target));
  if (staleTargets.length > 0) {
    process.stderr.write(`Generated artifacts are stale: ${staleTargets.join(', ')}\n`);
    process.exitCode = 1;
  }
} finally {
  rmSync(temporaryRoot, { force: true, recursive: true });
}
