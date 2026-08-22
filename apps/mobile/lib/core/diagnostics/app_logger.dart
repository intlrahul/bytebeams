import 'package:flutter/foundation.dart';

abstract interface class AppLogger {
  void debug(String message, {Map<String, Object?> fields = const {}});

  void info(String message, {Map<String, Object?> fields = const {}});

  void warning(String message, {Map<String, Object?> fields = const {}});

  void error(String message, {Map<String, Object?> fields = const {}});
}

final class NoOpAppLogger implements AppLogger {
  const NoOpAppLogger();

  @override
  void debug(String message, {Map<String, Object?> fields = const {}}) {}

  @override
  void error(String message, {Map<String, Object?> fields = const {}}) {}

  @override
  void info(String message, {Map<String, Object?> fields = const {}}) {}

  @override
  void warning(String message, {Map<String, Object?> fields = const {}}) {}
}

/// Debug-only console diagnostics. Callers must provide sanitized fields.
final class DebugAppLogger implements AppLogger {
  DebugAppLogger({this.name = 'ByteBeams', DebugLogSink? sink})
    : _sink = sink ?? debugPrint;

  final String name;
  final DebugLogSink _sink;

  @override
  void debug(String message, {Map<String, Object?> fields = const {}}) =>
      _write('debug', message, fields);

  @override
  void error(String message, {Map<String, Object?> fields = const {}}) =>
      _write('error', message, fields);

  @override
  void info(String message, {Map<String, Object?> fields = const {}}) =>
      _write('info', message, fields);

  @override
  void warning(String message, {Map<String, Object?> fields = const {}}) =>
      _write('warning', message, fields);

  void _write(String level, String message, Map<String, Object?> fields) {
    final color = switch (level) {
      'debug' => _dim,
      'info' => _cyan,
      'warning' => _yellow,
      'error' => _red,
      _ => _reset,
    };
    _sink('$color[$name][$level] $message $fields$_reset');
  }

  static const _reset = '\x1B[0m';
  static const _dim = '\x1B[90m';
  static const _cyan = '\x1B[36m';
  static const _yellow = '\x1B[33m';
  static const _red = '\x1B[31m';
}

typedef DebugLogSink = void Function(String message);
