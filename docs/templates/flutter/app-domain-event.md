# App-Level Domain Event Template

## Event

```dart
abstract interface class AppDomainEvent {}

@freezed
class ExampleCompleted with _$ExampleCompleted implements AppDomainEvent {
  const factory ExampleCompleted({
    required ExampleId exampleId,
    required DateTime occurredAtUtc,
  }) = _ExampleCompleted;
}
```

## Subscription

```dart
late final StreamSubscription<ExampleCompleted> _subscription;

void subscribe() {
  _subscription = eventBus.on<ExampleCompleted>().listen((event) {
    add(const ExampleEvent.refreshRequested());
  });
}

Future<void> disposeSubscription() => _subscription.cancel();
```

## Rules

- Use a past-tense business fact only when independent modules must react.
- Publish asynchronously after authoritative persistence commits.
- Payload is typed, minimal, sanitized, and not authoritative state.
- Consumers re-query repositories.
- Isolate listener failure and dispose subscriptions.
- Event handlers must not publish another app-level domain event; chained events are prohibited.
- Do not use the bus instead of a call, BLoC event, or database observation.
