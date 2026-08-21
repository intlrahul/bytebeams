# Security and Data Handling

## Scope

Authentication is intentionally out of scope for this single-operator take-home. Do not add a fake security boundary that implies production protection.

## Data rules

- Use synthetic fleet and telemetry fixtures only.
- Never commit credentials, tokens, private keys, webhooks, or sensitive values.
- Do not place secrets or raw vehicle telemetry in logs, analytics, exceptions, screenshots, or test reports.
- Store genuinely sensitive values only through an owned secure-storage contract.
- Store only non-sensitive settings through an owned preferences contract.
- Validate and bound all HTTP, SSE, OpenAPI, and persisted input.
- Parameterize DuckDB and SQLite statements; never concatenate untrusted SQL.
- Sanitize errors shown to users and analytics.

## CI and dependencies

- Store CI credentials and Slack webhooks in protected/masked GitLab variables.
- Run available secret and dependency scanning in CI.
- Review dependency provenance, license, maintenance, advisories, platform support, and transitive footprint before approval.
- Pin generators and runtimes; upgrades are explicit reviewed changes.

## Local database behavior

Database corruption or migration failure must not trigger silent destructive recreation. Preserve the file where safe, surface a diagnostic state, and require an explicitly planned recovery path. Demo reset actions must clearly describe deletion and require deliberate user action.
