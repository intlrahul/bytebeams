# Backend-Test Template

## Service unit test

```ts
describe('ExampleService', () => {
  it('given_valid_input_when_created_then_persists_deterministic_value', async () => {
    // Given
    const clock = new FakeClock('2026-01-01T12:00:00.000Z');
    const ids = new FakeIdGenerator(['example-001']);
    const repository = new InMemoryExampleRepository();
    const service = new ExampleService(repository, clock, ids);

    // When
    const result = await service.create(exampleInput());

    // Then
    expect(result).toEqual(success(expectedExample()));
    expect(repository.saved).toEqual([expectedExample()]);
  });
});
```

## HTTP test

```ts
it('given_invalid_request_when_posted_then_returns_openapi_error', async () => {
  // Given
  const app = createTestApp({ service: stubExampleService() });

  // When
  const response = await request(app).post('/examples').send({ invalid: true });

  // Then
  expect(response.status).toBe(400);
  expect(response.body).toMatchObject(expectedValidationError());
  expectOpenApiValid(response);
});
```

## Rules

- Use Vitest, Supertest, fake timers/clocks, deterministic IDs, and temporary SQLite.
- Use a real local server for SSE framing, disconnect, and `Last-Event-ID` tests.
- Test restart persistence, bounded replay gaps, duplicates, reorder, backlog, and bootstrap/cursor consistency.
- Restore fake timers and close servers/databases in teardown.
- Never use external network calls or real-time sleeps.
