# GitLab CI/CD

## Runtime pins

- Flutter `3.47.0` through FVM.
- Node.js `24.19.0` in `.nvmrc`, `package.json`, and CI image/configuration.
- pnpm and all generators pinned intentionally.

## Merge-request pipeline

```text
validate
  ├── Conventional Commit messages introduced by the merge request
  ├── Markdown/configuration checks
  ├── Dart and TypeScript formatting
  ├── Flutter analysis and TypeScript type-check
  ├── OpenAPI validation
  └── regenerate committed artifacts and require a clean diff

test
  ├── Flutter unit and widget tests
  ├── DuckDB integration tests
  ├── Node unit/API/SSE/SQLite tests
  ├── contract tests
  └── enforce >= 90% line coverage

build
  ├── Android debug APK
  └── Node production build
```

Android is the required build target initially. Add required iOS or web jobs only after their DuckDB support and runner needs are validated and approved.

## Post-merge pipeline

After merge to `main`, run Android end-to-end tests asynchronously. The already-completed merge is not blocked, but:

- The main pipeline clearly records health.
- Reports, logs, screenshots on failure, and other useful artifacts are retained.
- Failure notifies developers using whichever GitLab email or Slack integration is configured.
- Slack secrets, when present, use protected masked variables.
- A failing main integration suite is treated as active breakage and fixed before ordinary feature work continues.

## Generation policy

Generated OpenAPI, Freezed, and JSON artifacts are committed so a clone builds immediately. CI runs the repository generation command and fails when `git diff --exit-code` is not clean. Never repair this check by manually editing generated output.

## Migration verification

CI tests clean schema creation plus supported upgrade paths for DuckDB and backend SQLite. Applied numbered migrations are immutable.

## Reports

Publish machine-readable unit, integration, and coverage reports plus human-readable summaries. A missing required report is a pipeline defect, not a passing result.
