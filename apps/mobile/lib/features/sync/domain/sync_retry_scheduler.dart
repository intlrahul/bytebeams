abstract interface class SyncRetryScheduler {
  Future<void> wait(Duration delay);
}

final class SystemSyncRetryScheduler implements SyncRetryScheduler {
  const SystemSyncRetryScheduler();

  @override
  Future<void> wait(Duration delay) => Future<void>.delayed(delay);
}

final class SyncRetryPolicy {
  const SyncRetryPolicy();

  static const delays = <Duration>[
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 8),
    Duration(seconds: 15),
  ];

  Duration delayForAttempt(int attempt) =>
      delays[attempt.clamp(0, delays.length - 1)];
}
