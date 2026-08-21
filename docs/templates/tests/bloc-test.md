# BLoC-Test Template

```dart
void main() {
  group('ExampleBloc', () {
    late FakeGetExample getExample;

    setUp(() {
      getExample = FakeGetExample();
    });

    blocTest<ExampleBloc, ExampleState>(
      'given_success_when_load_requested_then_emits_loading_and_success',
      setUp: () {
        getExample.result = success(exampleFixture());
      },
      build: () => ExampleBloc(getExample: getExample),
      act: (bloc) => bloc.add(const ExampleEvent.loadRequested()),
      expect: () => [
        const ExampleState.loading(),
        ExampleState.success(exampleViewDataFixture()),
      ],
      verify: (_) => expect(getExample.callCount, 1),
    );
  });
}
```

## Required cases

- Initial state.
- Success and each mapped failure.
- Retry and refresh.
- Event concurrency/cancellation semantics.
- Subscription disposal where the BLoC listens to app-level events.
- No unrelated state emission after close.

Avoid arbitrary `wait` durations. Control completion with fakes, completers, or fake async time.
