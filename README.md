# ByteBeams

Local-first electric fleet operations take-home. Product and engineering decisions live in `context.md` and `docs/`; every implementation request follows the planning workflow in `AGENTS.md`.

## Workspace

```text
apps/mobile                    Flutter application
apps/mobile/generated         committed generated Dart API client
apps/server                    TypeScript demo server
contracts/openapi.yaml         transport contract source of truth
tooling                        deterministic generation and coverage checks
```

## Prerequisites

- FVM `4.1.4`
- Flutter `3.47.0` / Dart `3.13.0`
- Node.js `24.19.0`
- pnpm `11.22.0` through Corepack
- Java 17 for OpenAPI Generator and Android builds

Use `.nvmrc`, `.fvmrc`, and the committed package-manager metadata rather than substituting newer versions.

## First setup

```sh
nvm use
corepack enable pnpm
corepack prepare pnpm@11.22.0 --activate
pnpm install --frozen-lockfile
fvm install
pnpm generate:check
fvm flutter pub get --directory apps/mobile --enforce-lockfile
```

## Commands

```sh
pnpm openapi:lint
pnpm generate
pnpm generate:check
pnpm format
pnpm format:check
pnpm lint
pnpm typecheck
pnpm test
pnpm test:flutter:integration
pnpm build:server
pnpm build:flutter
```

The integration command requires a running Flutter-supported device. GitLab runs it after a push to the default branch on a runner tagged `android-emulator`; set `ANDROID_DEVICE_ID` for that runner. GitLab email notifications remain project configuration, while the optional masked `SLACK_WEBHOOK_URL` enables the failure-notification job.

`pnpm generate` recreates the committed Dart Dio client and TypeScript contract types. Never edit generated files manually.

The server starts with `pnpm --filter @bytebeams/fleet dev` and defaults to `http://localhost:3000`. Only `/health` is implemented in this setup slice; bootstrap and SSE remain contract-only until their feature plan is approved.
