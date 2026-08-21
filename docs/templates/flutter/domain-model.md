# Domain Model Template

## Entity

Use for a domain concept with stable identity and business meaning.

```dart
@freezed
class Example with _$Example {
  const Example._();

  const factory Example({
    required ExampleId id,
    required DateTime occurredAtUtc,
    required ExampleStatus status,
  }) = _Example;

  bool get requiresAttention => status == ExampleStatus.alert;
}
```

## Value object

Validate at creation so invalid values cannot masquerade as domain values.

```dart
@freezed
class ExampleId with _$ExampleId {
  const ExampleId._();

  const factory ExampleId._valid(String value) = _ExampleId;

  static Result<ExampleId, ValidationFailure> create(String raw) {
    final value = raw.trim();
    return value.isEmpty
        ? const Failure(ValidationFailure.emptyValue())
        : Success(ExampleId._valid(value));
  }
}
```

## Rules

- Domain models import no Flutter, JSON, database, or API packages.
- Use UTC and name timestamp semantics explicitly.
- Do not add serialization annotations to domain entities.
- Keep derived business behavior near the domain model only when it belongs to that concept.
- Test equality, validation boundaries, and derived behavior.
