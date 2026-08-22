import 'dart:async';

abstract interface class AppEventBus {
  Stream<AppEvent> get events;
  void publish(AppEvent event);
  Future<void> close();
}

sealed class AppEvent {
  const AppEvent();
}

final class FleetDataCommitted extends AppEvent {
  const FleetDataCommitted();
}

final class AlertStateChanged extends AppEvent {
  const AlertStateChanged();
}

/// Delivers application-wide events asynchronously so a database commit can
/// complete before listening features re-query their local state.
final class AsyncAppEventBus implements AppEventBus {
  AsyncAppEventBus() : _controller = StreamController<AppEvent>.broadcast();

  final StreamController<AppEvent> _controller;

  @override
  Stream<AppEvent> get events => _controller.stream;

  @override
  void publish(AppEvent event) {
    scheduleMicrotask(() {
      if (!_controller.isClosed) {
        _controller.add(event);
      }
    });
  }

  @override
  Future<void> close() => _controller.close();
}
