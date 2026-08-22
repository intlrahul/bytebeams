import 'package:bytebeams/core/diagnostics/app_logger.dart';
import 'package:bytebeams/core/time/clock.dart';
import 'package:dio/dio.dart';

final class DioApiLoggingInterceptor extends Interceptor {
  DioApiLoggingInterceptor({required this.logger, required this.clock});

  static const _startedAtKey = 'bytebeams.apiLogging.startedAt';

  final AppLogger logger;
  final Clock clock;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startedAtKey] = clock.nowUtc();
    logger.info('api.request', fields: _fields(options));
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    logger.info(
      'api.response',
      fields: {
        ..._fields(response.requestOptions),
        'statusCode': response.statusCode,
        'durationMs': _durationMs(response.requestOptions),
      },
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.warning(
      'api.error',
      fields: {
        ..._fields(err.requestOptions),
        'errorType': err.type.name,
        'statusCode': err.response?.statusCode,
        'durationMs': _durationMs(err.requestOptions),
      },
    );
    handler.next(err);
  }

  Map<String, Object?> _fields(RequestOptions options) => {
    'method': options.method,
    'path': options.uri.path,
  };

  int? _durationMs(RequestOptions options) {
    final startedAt = options.extra[_startedAtKey];
    if (startedAt is! DateTime) return null;
    return clock.nowUtc().difference(startedAt).inMilliseconds;
  }
}
