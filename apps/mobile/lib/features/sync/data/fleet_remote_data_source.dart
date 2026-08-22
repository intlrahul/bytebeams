import 'dart:async';
import 'dart:convert';

import 'package:bytebeams/features/sync/data/api_endpoint_provider.dart';
import 'package:bytebeams/features/sync/data/sse_frame_parser.dart';
import 'package:bytebeams/features/sync/data/sync_dto_mapper.dart';
import 'package:bytebeams/features/sync/domain/sync_models.dart';
import 'package:bytebeams_api/bytebeams_api.dart' as api;
import 'package:dio/dio.dart';

abstract interface class FleetRemoteDataSource {
  Future<SyncBootstrapDto> bootstrap();

  Stream<SyncDeliveryDto> deliveries({String? after});
}

final class DioFleetRemoteDataSource implements FleetRemoteDataSource {
  DioFleetRemoteDataSource({
    required this._dio,
    required this._endpointProvider,
    this._mapper = const SyncDtoMapper(),
    this._frameParser = const SseFrameParser(),
  });

  final Dio _dio;
  final ApiEndpointProvider _endpointProvider;
  final SyncDtoMapper _mapper;
  final SseFrameParser _frameParser;

  Dio _client() {
    _dio.options.baseUrl = _endpointProvider.baseUri().toString();
    return _dio;
  }

  @override
  Future<SyncBootstrapDto> bootstrap() async {
    try {
      final response = await api.DefaultApi(_client()).getBootstrap();
      final data = response.data;
      if (data == null) {
        throw const SyncBootstrapUnavailable();
      }
      return _mapper.bootstrap(data);
    } on SyncFailure {
      rethrow;
    } on Object {
      throw const SyncBootstrapUnavailable();
    }
  }

  @override
  Stream<SyncDeliveryDto> deliveries({String? after}) async* {
    try {
      final response = await _client().get<ResponseBody>(
        '/telemetry',
        queryParameters: {'after': ?after},
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Last-Event-ID': ?after},
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if (response.statusCode == 409 && response.data != null) {
        final error = jsonDecode(
          await utf8.decodeStream(response.data!.stream),
        ) as Map<String, dynamic>;
        throw SyncReplayGap(
          requestedCursor: error['requestedCursor']! as String,
          oldestAvailableCursor: error['oldestAvailableCursor']! as String,
        );
      }
      if (response.statusCode != 200 || response.data == null) {
        throw const SyncTransportUnavailable();
      }
      await for (final frame in _frameParser.parse(response.data!.stream)) {
        final raw = jsonDecode(frame.data) as Map<String, dynamic>;
        yield _mapper.delivery(api.TelemetryDelivery.fromJson(raw));
      }
    } on SyncFailure {
      rethrow;
    } on Object {
      throw const SyncTransportUnavailable();
    }
  }
}
