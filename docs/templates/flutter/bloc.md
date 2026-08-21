# BLoC Template

## Use when

A screen or workflow has asynchronous operations, multiple meaningful states, or non-trivial presentation transitions. Do not introduce a BLoC for static local rendering.

```dart
@freezed
sealed class ExampleEvent with _$ExampleEvent {
  const factory ExampleEvent.loadRequested() = ExampleLoadRequested;
  const factory ExampleEvent.retryRequested() = ExampleRetryRequested;
}

@freezed
sealed class ExampleState with _$ExampleState {
  const factory ExampleState.initial() = ExampleInitial;
  const factory ExampleState.loading() = ExampleLoading;
  const factory ExampleState.success(ExampleViewData data) = ExampleSuccess;
  const factory ExampleState.failure(PresentationFailure failure) = ExampleFailure;
}

final class ExampleBloc extends Bloc<ExampleEvent, ExampleState> {
  ExampleBloc({required GetExample getExample})
      : _getExample = getExample,
        super(const ExampleState.initial()) {
    on<ExampleLoadRequested>(_onLoadRequested);
    on<ExampleRetryRequested>(_onLoadRequested);
  }

  final GetExample _getExample;

  Future<void> _onLoadRequested(
    ExampleEvent event,
    Emitter<ExampleState> emit,
  ) async {
    emit(const ExampleState.loading());
    final result = await _getExample();
    result.fold(
      onSuccess: (value) => emit(ExampleState.success(mapForView(value))),
      onFailure: (failure) => emit(ExampleState.failure(mapFailure(failure))),
    );
  }
}
```

## Rules

- BLoC events are presentation inputs, not domain events.
- Inject use cases through the constructor; never call `get_it` inside a BLoC.
- No Dio, DuckDB, preferences, routing configuration, or provider SDK access.
- Select concurrency transformers intentionally and test their semantics.
- Use an injected clock for time behavior.
- Side effects such as navigation belong in explicit UI listeners.
- Add a `bloc_test` for every event path, failure, retry, and concurrency decision.
