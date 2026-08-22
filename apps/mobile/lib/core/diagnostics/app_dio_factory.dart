import 'package:bytebeams/core/diagnostics/app_logger.dart';
import 'package:bytebeams/core/diagnostics/dio_api_logging_interceptor.dart';
import 'package:bytebeams/core/time/clock.dart';
import 'package:dio/dio.dart';

abstract final class AppDioFactory {
  static Dio create({required AppLogger logger, required Clock clock}) => Dio()
    ..interceptors.add(DioApiLoggingInterceptor(logger: logger, clock: clock));
}
