# ByteBeams

Local-first electric fleet operations take-home. Product and engineering decisions live in `context.md` and `docs/`; every implementation request follows the planning workflow in `AGENTS.md`.

Development follows the approved milestone sequence in [`docs/delivery/implementation-plan.md`](docs/delivery/implementation-plan.md). The roadmap establishes order and dependencies; each milestone requires a separately approved implementation plan before code changes begin.

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
pnpm commitlint:current
pnpm commitlint:test
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

## Commit messages

New commits use Conventional Commits:

```text
<type>(optional-scope): <imperative summary>
```

Allowed types are `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `build`, `ci`, `perf`, and `style`. Optional scopes are `mobile`, `server`, `contracts`, `tooling`, `docs`, `ci`, and `workspace`.

Write a specific imperative summary shorter than 72 characters, with no trailing period. The local `commit-msg` hook is installed by `pnpm install`; GitLab validates every commit introduced by a merge request.

Valid examples:

```text
feat(mobile): add fleet status filters
fix(server): preserve the delivery cursor
docs: explain Android setup
```

Invalid examples:

```text
FEAT(mobile): add filters
chore: update
fix: fix bug
docs: explain setup.
feat(database): add tables
```

Breaking changes require both the `!` marker and a footer separated from the summary by a blank line:

```text
refactor(contracts)!: rename the packet timestamp

BREAKING CHANGE: eventTime replaces timestamp in packet payloads
```

Commitlint deterministically validates structure and explicitly vague subjects. Broader imperative grammar remains a review responsibility because enforcing it would require an incomplete, restrictive verb dictionary.
