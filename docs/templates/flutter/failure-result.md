# Failure and Result Template

Use the repository's selected Result implementation consistently; do not introduce competing result packages.

```dart
@freezed
sealed class ExampleFailure with _$ExampleFailure {
  const factory ExampleFailure.notFound() = ExampleNotFound;
  const factory ExampleFailure.invalidData(String safeReason) = ExampleInvalidData;
  const factory ExampleFailure.storageUnavailable() = ExampleStorageUnavailable;
  const factory ExampleFailure.unexpected(String diagnosticId) = ExampleUnexpected;
}

@freezed
sealed class Result<S, F> with _$Result<S, F> {
  const factory Result.success(S value) = Success<S, F>;
  const factory Result.failure(F failure) = Failure<S, F>;
}
```

## Rules

- Failures use domain/application vocabulary and contain safe information.
- Adapters translate Dio, DuckDB, SQLite, parsing, and storage exceptions.
- Do not catch programming errors as expected failures.
- Preserve sanitized diagnostic correlation separately from user messaging.
- BLoCs exhaustively map failures to presentation states.
- Test every translation and ensure secrets/raw packet data never enters failure text.
