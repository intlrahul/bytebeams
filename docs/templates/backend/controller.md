# Backend Controller Template

## Responsibility

A controller owns HTTP/SSE transport concerns: parsing, schema validation, status codes, headers, serialization, connection lifecycle, and conversion to/from application input/output. It contains no simulation or persistence policy.

```ts
export class ExampleController {
  constructor(private readonly service: ExampleService) {}

  getById = async (request: Request, response: Response): Promise<void> => {
    const parsed = ExampleRequestSchema.safeParse(request.params);
    if (!parsed.success) {
      response.status(400).json(toApiValidationError(parsed.error));
      return;
    }

    const result = await this.service.getById(parsed.data.id);
    matchResult(result, {
      success: (value) => response.status(200).json(toApiResponse(value)),
      failure: (failure) => writeApiFailure(response, failure),
    });
  };
}
```

## SSE additions

- Parse `Last-Event-ID` and initial `after` cursor explicitly.
- Write monotonic delivery IDs separately from packet IDs.
- Close subscriptions on connection termination.
- Send an explicit replay-gap event/outcome when history is unavailable.
- Keep heartbeat/connection mechanics separate from vehicle `last_ping` telemetry.

## Tests

Use Supertest for validation, status mapping, headers, OpenAPI response shape, and failure cases. Use a real local server for SSE framing and reconnect behavior.
