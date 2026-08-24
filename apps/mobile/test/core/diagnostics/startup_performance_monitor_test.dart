import 'package:bytebeams/core/diagnostics/app_logger.dart';
import 'package:bytebeams/core/diagnostics/startup_performance_monitor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given_resolved_startup_mode_when_later_stage_marked_then_includes_safe_timing_context', () {
    final logger = _Logger();
    final monitor = DebugStartupPerformanceMonitor(logger);

    monitor.mark(
      'database_state_resolved',
      fields: {'startupMode': 'restored'},
    );
    monitor.mark(
      'fleet_list_rendered',
      fields: {'source': 'saved_data', 'rowCount': 500},
    );

    expect(logger.entries, hasLength(2));
    expect(logger.entries.last.message, 'startup.performance');
    expect(logger.entries.last.fields, {
      'stage': 'fleet_list_rendered',
      'elapsedMs': isA<int>(),
      'startupMode': 'restored',
      'source': 'saved_data',
      'rowCount': 500,
    });
  });
}

final class _Logger implements AppLogger {
  final entries = <({String message, Map<String, Object?> fields})>[];

  @override
  void debug(String message, {Map<String, Object?> fields = const {}}) {}

  @override
  void error(String message, {Map<String, Object?> fields = const {}}) {}

  @override
  void info(String message, {Map<String, Object?> fields = const {}}) {
    entries.add((message: message, fields: fields));
  }

  @override
  void warning(String message, {Map<String, Object?> fields = const {}}) {}
}
