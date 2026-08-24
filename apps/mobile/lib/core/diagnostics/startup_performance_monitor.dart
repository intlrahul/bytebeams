import 'package:bytebeams/core/diagnostics/app_logger.dart';

/// Records sanitized, debug-only timings for the local-first startup path.
///
/// This is application analytics, not vehicle telemetry. It deliberately emits
/// only durations, stage names, and aggregate counts.
abstract interface class StartupPerformanceMonitor {
  void mark(String stage, {Map<String, Object?> fields = const {}});
}

final class NoOpStartupPerformanceMonitor implements StartupPerformanceMonitor {
  const NoOpStartupPerformanceMonitor();

  @override
  void mark(String stage, {Map<String, Object?> fields = const {}}) {}
}

final class DebugStartupPerformanceMonitor
    implements StartupPerformanceMonitor {
  DebugStartupPerformanceMonitor(this._logger)
    : _startedAt = Stopwatch()..start();

  final AppLogger _logger;
  final Stopwatch _startedAt;
  String? _startupMode;

  @override
  void mark(String stage, {Map<String, Object?> fields = const {}}) {
    final markedMode = fields['startupMode'];
    if (markedMode is String) _startupMode = markedMode;
    _logger.info(
      'startup.performance',
      fields: {
        'stage': stage,
        'elapsedMs': _startedAt.elapsedMilliseconds,
        if (_startupMode != null) 'startupMode': _startupMode,
        ...fields,
      },
    );
  }
}
