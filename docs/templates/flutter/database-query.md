# Database Query Template

## Query catalog

```dart
abstract final class ExampleQueries {
  static const selectById = '''
    SELECT id, occurred_at_utc, status
    FROM examples
    WHERE id = ?
    LIMIT 1
  ''';
}
```

## Transaction

```dart
Future<void> persistDelivery(Delivery delivery) {
  return database.transaction((transaction) async {
    await transaction.insertPacketIfAbsent(delivery.packet);
    await transaction.rebuildAffectedProjection(delivery.packet);
    await transaction.updateCursor(delivery.cursor);
  });
}
```

## Rules

- Parameterize all values.
- Name every selected column; avoid `SELECT *` in owned queries.
- Specify ordering and stable tie-breaks whenever order affects behavior.
- Advance the SSE cursor only in the same successful transaction as packet processing.
- Keep schema changes in immutable numbered migrations.
- Filter counts and authoritative fleet views are calculated in SQL.
- Integration-test queries against a temporary real DuckDB, including reopen and migration paths.
