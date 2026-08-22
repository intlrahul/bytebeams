import 'dart:async';
import 'dart:typed_data';

import 'package:bytebeams/core/diagnostics/app_dio_factory.dart';
import 'package:bytebeams/core/diagnostics/app_logger.dart';
import 'package:bytebeams/core/diagnostics/dio_api_logging_interceptor.dart';
import 'package:bytebeams/core/time/clock.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'given_successful_api_call_when_sent_then_logs_sanitized_lifecycle',
    () async {
      final logger = _RecordingLogger();
      final dio = AppDioFactory.create(logger: logger, clock: const _Clock())
        ..httpClientAdapter = _Adapter(
          (_) => ResponseBody.fromString('secret', 200),
        );

      expect(
        dio.interceptors.whereType<DioApiLoggingInterceptor>(),
        hasLength(1),
      );

      await dio.get('/bootstrap?token=secret');

      expect(logger.entries.map((entry) => entry.message), [
        'api.request',
        'api.response',
      ]);
      expect(logger.entries.first.fields, {
        'method': 'GET',
        'path': '/bootstrap',
      });
      expect(logger.entries.last.fields['statusCode'], 200);
      expect(logger.entries.last.fields.containsKey('body'), isFalse);
    },
  );

  test(
    'given_failed_api_call_when_sent_then_logs_safe_error_metadata',
    () async {
      final logger = _RecordingLogger();
      final dio = AppDioFactory.create(logger: logger, clock: const _Clock())
        ..httpClientAdapter = _Adapter(
          (_) => ResponseBody.fromString('secret', 500),
        );

      await expectLater(
        dio.get('/telemetry?vehicle=private'),
        throwsA(isA<DioException>()),
      );

      final error = logger.entries.last;
      expect(error.message, 'api.error');
      expect(error.fields['path'], '/telemetry');
      expect(error.fields['statusCode'], 500);
      expect(error.fields.containsKey('body'), isFalse);
    },
  );

  test('given_no_op_logger_when_used_then_produces_no_side_effect', () {
    const logger = NoOpAppLogger();

    logger.debug('api.request', fields: {'path': '/bootstrap'});
    logger.info('api.response', fields: {'statusCode': 200});
    logger.warning('api.error', fields: {'errorType': 'connectionError'});
    logger.error('unexpected', fields: {'errorType': 'StateError'});
  });

  test('given_debug_logger_when_messages_are_written_then_colours_levels', () {
    final output = <String>[];
    final logger = DebugAppLogger(sink: output.add);

    logger.debug('debug message');
    logger.info('info message');
    logger.warning('warning message');
    logger.error('error message');

    expect(output, [
      '\x1B[90m[ByteBeams][debug] debug message {}\x1B[0m',
      '\x1B[36m[ByteBeams][info] info message {}\x1B[0m',
      '\x1B[33m[ByteBeams][warning] warning message {}\x1B[0m',
      '\x1B[31m[ByteBeams][error] error message {}\x1B[0m',
    ]);
  });
}

final class _Clock implements Clock {
  const _Clock();

  @override
  DateTime nowUtc() => DateTime.utc(2026, 8, 22, 12);
}

final class _RecordingLogger implements AppLogger {
  final entries = <_LogEntry>[];

  @override
  void debug(String message, {Map<String, Object?> fields = const {}}) =>
      entries.add(_LogEntry(message, fields));

  @override
  void error(String message, {Map<String, Object?> fields = const {}}) =>
      entries.add(_LogEntry(message, fields));

  @override
  void info(String message, {Map<String, Object?> fields = const {}}) =>
      entries.add(_LogEntry(message, fields));

  @override
  void warning(String message, {Map<String, Object?> fields = const {}}) =>
      entries.add(_LogEntry(message, fields));
}

final class _LogEntry {
  const _LogEntry(this.message, this.fields);

  final String message;
  final Map<String, Object?> fields;
}

final class _Adapter implements HttpClientAdapter {
  _Adapter(this._handler);

  final FutureOr<ResponseBody> Function(RequestOptions options) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => _handler(options);

  @override
  void close({bool force = false}) {}
}
