import {
  existsSync,
  mkdirSync,
  readFileSync,
  rmSync,
  writeFileSync,
} from 'node:fs';
import { dirname, resolve } from 'node:path';
import { spawnSync } from 'node:child_process';

const workspace = resolve(import.meta.dirname, '../..');
const outputRoot = resolve(process.env.BYTEBEAMS_GENERATED_ROOT ?? workspace);
const contract = resolve(workspace, 'contracts/openapi.yaml');
const dartOutput = resolve(outputRoot, 'apps/mobile/generated/api_client');
const typescriptOutput = resolve(outputRoot, 'apps/server/src/generated/openapi.ts');
const canonicalDartLock = resolve(
  workspace,
  'apps/mobile/generated/api_client/pubspec.lock',
);
const existingDartLock = existsSync(canonicalDartLock)
  ? readFileSync(canonicalDartLock)
  : null;

function run(command, args, cwd = workspace) {
  const result = spawnSync(command, args, {
    cwd,
    encoding: 'utf8',
    env: process.env,
    stdio: 'inherit',
  });
  if (result.status !== 0) {
    process.exit(result.status ?? 1);
  }
}

rmSync(dartOutput, { force: true, recursive: true });
mkdirSync(dirname(typescriptOutput), { recursive: true });

run('openapi-generator-cli', [
  'generate',
  '--input-spec',
  contract,
  '--generator-name',
  'dart-dio',
  '--output',
  dartOutput,
  '--additional-properties',
  [
    'pubName=bytebeams_api',
    'pubVersion=0.0.0',
    'pubDescription=Generated_ByteBeams_API_client',
    'pubPublishTo=none',
    'serializationLibrary=json_serializable',
    'hideGenerationTimestamp=true',
    'finalProperties=true',
  ].join(','),
  '--global-property',
  'apiTests=false,modelTests=false',
]);

const generatedPubspec = resolve(dartOutput, 'pubspec.yaml');
const generatedGitignore = resolve(dartOutput, '.gitignore');
writeFileSync(
  generatedPubspec,
  readFileSync(generatedPubspec, 'utf8').replace(
    "sdk: '>=3.5.0 <4.0.0'",
    "sdk: '>=3.13.0 <4.0.0'",
  )
    .replace("dio: '^5.7.0'", "dio: '5.11.0'")
    .replace("copy_with_extension: '^7.1.0'", "copy_with_extension: '7.1.0'")
    .replace("json_annotation: '^4.9.0'", "json_annotation: '4.9.0'")
    .replace('build_runner: any', "build_runner: '2.7.1'")
    .replace('copy_with_extension_gen: ^7.1.0', "copy_with_extension_gen: '7.1.0'")
    .replace("json_serializable: '^6.9.3'", "json_serializable: '6.11.2'")
    .replace("test: '^1.16.0'", "test: '1.26.3'"),
);
writeFileSync(
  generatedGitignore,
  readFileSync(generatedGitignore, 'utf8').replace(
    /# Don't commit pubspec lock file[\s\S]*?pubspec\.lock\n\n/,
    '',
  ),
);

if (existingDartLock !== null) {
  writeFileSync(resolve(dartOutput, 'pubspec.lock'), existingDartLock);
}

run(
  'dart',
  ['pub', 'get', ...(existingDartLock === null ? [] : ['--enforce-lockfile'])],
  dartOutput,
);
run(
  'dart',
  ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
  dartOutput,
);
run('dart', ['format', '.'], dartOutput);

run('openapi-typescript', [contract, '--output', typescriptOutput]);
