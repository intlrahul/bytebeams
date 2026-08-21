# Data-Source Template

## Local boundary

```dart
abstract interface class ExampleLocalDataSource {
  Future<ExampleRecord> getById(String id);
  Future<void> upsert(ExampleRecord record);
}

final class DuckDbExampleLocalDataSource
    implements ExampleLocalDataSource {
  const DuckDbExampleLocalDataSource({required DuckDbExecutor database})
      : _database = database;

  final DuckDbExecutor _database;

  @override
  Future<ExampleRecord> getById(String id) async {
    final row = await _database.queryOne(
      ExampleQueries.selectById,
      parameters: [id],
    );
    return ExampleRecord.fromRow(row);
  }
}
```

## Remote boundary

```dart
abstract interface class ExampleRemoteDataSource {
  Future<ExampleDto> fetchById(String id);
}
```

## Rules

- Data sources speak data-layer types and throw only owned infrastructure exceptions.
- Parameterize SQL and validate transport input.
- Repositories map exceptions to domain/application failures.
- Keep transaction ownership explicit; multi-step authoritative writes use one transaction coordinator.
- Do not create a data source when a repository can cleanly own a single adapter without losing a meaningful boundary.
