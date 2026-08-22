import 'dart:async';

abstract interface class SyncBatchTimer {
  void cancel();
}

abstract interface class SyncBatchScheduler {
  SyncBatchTimer schedule(Duration delay, void Function() callback);
}

final class SystemSyncBatchScheduler implements SyncBatchScheduler {
  const SystemSyncBatchScheduler();

  @override
  SyncBatchTimer schedule(Duration delay, void Function() callback) =>
      _TimerSyncBatchTimer(Timer(delay, callback));
}

final class _TimerSyncBatchTimer implements SyncBatchTimer {
  const _TimerSyncBatchTimer(this._timer);

  final Timer _timer;

  @override
  void cancel() => _timer.cancel();
}
