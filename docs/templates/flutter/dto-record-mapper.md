# DTO, Record, and Mapper Template

Keep transport, persistence, and domain representations distinct.

## Transport DTO

Use the committed OpenAPI-generated type. Do not hand-edit it.

```dart
// Generated illustration only.
@freezed
class ExampleDto with _$ExampleDto {
  const factory ExampleDto({
    required String id,
    required String occurredAt,
  }) = _ExampleDto;
}
```

## DuckDB record

```dart
@freezed
class ExampleRecord with _$ExampleRecord {
  const factory ExampleRecord({
    required String id,
    required DateTime occurredAtUtc,
    required String status,
  }) = _ExampleRecord;
}
```

## Mapper

```dart
final class ExampleMapper {
  const ExampleMapper();

  Result<Example, MappingFailure> dtoToDomain(ExampleDto dto) {
    // Parse UTC timestamps and validate every domain value explicitly.
    throw UnimplementedError('Illustrative skeleton');
  }

  ExampleRecord domainToRecord(Example value) {
    return ExampleRecord(
      id: value.id.value,
      occurredAtUtc: value.occurredAtUtc,
      status: value.status.name,
    );
  }
}
```

## Rules

- Generated DTOs never enter domain or presentation APIs.
- Preserve raw input separately when diagnostics/replay require it.
- Parsing is explicit about UTC, units, enum fallbacks, nullability, and invalid/unsupported classification.
- Never silently default malformed transport values into valid domain values.
- Table-test successful and failing mappings.
