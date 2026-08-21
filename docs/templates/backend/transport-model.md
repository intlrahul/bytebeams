# Backend Transport Model Template

OpenAPI is authoritative. Generated request/response types remain at the transport boundary.

```ts
// Shape is illustrative; use generated OpenAPI types in implementation.
type ExampleApiResponse = components['schemas']['Example'];

export function toApiResponse(value: Example): ExampleApiResponse {
  return {
    id: value.id.value,
    occurredAt: value.occurredAtUtc.toISOString(),
  };
}
```

## Rules

- Validate incoming data at runtime; TypeScript types alone do not validate JSON.
- Map between generated transport and service/domain types.
- Use ISO-8601 UTC timestamps and documented units.
- Preserve SSE delivery ID separately from packet ID and event time.
- Never edit generated artifacts manually.
- Regenerate after schema changes and require a clean Git diff in CI.
- Contract-test representative success and error responses against OpenAPI.
