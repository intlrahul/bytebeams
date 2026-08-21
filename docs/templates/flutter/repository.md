# Repository Template

## Domain contract

Use an abstract interface for a meaningful persistence or remote-data boundary.

```dart
abstract interface class ExampleRepository {
  Future<Result<Example, ExampleFailure>> getById(ExampleId id);

  Stream<Result<List<Example>, ExampleFailure>> watchAll();
}
```

## Data implementation

```dart
final class DuckDbExampleRepository implements ExampleRepository {
  const DuckDbExampleRepository({
    required ExampleLocalDataSource local,
    required ExampleMapper mapper,
  }) : _local = local,
       _mapper = mapper;

  final ExampleLocalDataSource _local;
  final ExampleMapper _mapper;

  @override
  Future<Result<Example, ExampleFailure>> getById(ExampleId id) async {
    try {
      final record = await _local.getById(id.value);
      return Success(_mapper.toDomain(record));
    } on ExampleDatabaseException catch (error, stackTrace) {
      return Failure(mapDatabaseFailure(error, stackTrace));
    }
  }
}
```

## Rules

- Contract vocabulary is domain-owned and infrastructure-free.
- Implementation translates records, DTOs, and infrastructure exceptions.
- Do not expose SQL rows, Dio responses, generated DTOs, or exceptions.
- DuckDB-backed reads remain authoritative.
- Streams/watch APIs require an explicitly designed committed-change notification mechanism.
- Unit-test mapping/failure translation and integration-test real persistence.
