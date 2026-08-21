# Backend Repository Template

## Contract

```ts
export interface DeliveryLogRepository {
  append(delivery: Delivery): Promise<Result<void, DeliveryLogFailure>>;
  readAfter(cursor: DeliveryCursor, limit: number): Promise<Result<DeliveryPage, DeliveryLogFailure>>;
  oldestCursor(): Promise<Result<DeliveryCursor | null, DeliveryLogFailure>>;
}
```

## SQLite implementation

```ts
export class SqliteDeliveryLogRepository implements DeliveryLogRepository {
  constructor(private readonly database: SqliteDatabase) {}

  async readAfter(
    cursor: DeliveryCursor,
    limit: number,
  ): Promise<Result<DeliveryPage, DeliveryLogFailure>> {
    try {
      const rows = await this.database.all(READ_AFTER_SQL, [cursor.value, limit]);
      return success(mapDeliveryPage(rows));
    } catch (error: unknown) {
      return failure(mapSqliteFailure(error));
    }
  }
}
```

## Rules

- Use parameterized SQL and numbered immutable migrations.
- Map SQLite rows/errors into owned types.
- Define cursor ordering, bounds, pruning, and transactions explicitly.
- Never expose the database object to controllers/services.
- Integration-test restart persistence, replay gaps, boundaries, and migration upgrades with temporary SQLite files.
