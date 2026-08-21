# Backend Service Template

## Responsibility

A service orchestrates backend application behavior. It depends on owned repository and clock/randomness contracts, not Express or SQLite APIs.

```ts
export class ExampleService {
  constructor(
    private readonly repository: ExampleRepository,
    private readonly clock: Clock,
    private readonly ids: IdGenerator,
  ) {}

  async create(input: CreateExampleInput): Promise<Result<Example, ExampleFailure>> {
    const now = this.clock.nowUtc();
    const value = createExample({
      id: this.ids.next(),
      input,
      createdAtUtc: now,
    });

    return this.repository.save(value);
  }
}
```

## Rules

- No Express request/response objects.
- No direct SQLite, filesystem, timer, or random calls.
- Keep scenario timing deterministic through injected clocks/schedulers.
- Return typed results rather than transport status codes.
- Transactions are explicit at repository/unit-of-work boundaries.
- Test with deterministic fakes and all failure paths.
