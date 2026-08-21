# Use-Case Template

## Use when

A named application operation coordinates domain policy or repository access. A trivial synchronous value calculation may belong on a value object instead.

```dart
final class GetExample {
  const GetExample({required ExampleRepository repository})
      : _repository = repository;

  final ExampleRepository _repository;

  Future<Result<Example, ExampleFailure>> call(ExampleId id) {
    return _repository.getById(id);
  }
}
```

For mutation:

```dart
final class DismissExampleAlert {
  const DismissExampleAlert({
    required AlertRepository repository,
    required Clock clock,
  }) : _repository = repository,
       _clock = clock;

  final AlertRepository _repository;
  final Clock _clock;

  Future<Result<void, AlertFailure>> call(DismissAlertCommand command) {
    return _repository.dismiss(command, dismissedAt: _clock.nowUtc());
  }
}
```

## Rules

- Names are commands or queries, not past-tense events.
- Inject domain contracts; do not depend on concrete adapters.
- Do not read ambient time, generate random IDs, or service-locate.
- Return typed results/failures at the application boundary.
- Publish no BLoC events. App-level event publication follows committed persistence and the approved event policy.
- Unit-test success, each failure, and all boundary conditions.
