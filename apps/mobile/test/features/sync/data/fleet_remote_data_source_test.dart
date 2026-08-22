import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bytebeams/features/sync/data/api_endpoint_provider.dart';
import 'package:bytebeams/features/sync/data/fleet_remote_data_source.dart';
import 'package:bytebeams/features/sync/domain/sync_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given_bootstrap_response_when_requested_then_maps_snapshot_through_generated_contract', () async {
    final adapter = _Adapter((_) => _jsonResponse(_bootstrapJson));
    final dataSource = _dataSource(adapter);

    final bootstrap = await dataSource.bootstrap();

    expect(bootstrap.deliveryCursor, '42');
    expect(bootstrap.vehicles.single.vehicleId, 'vehicle-1');
    expect(adapter.requests.single.path, '/bootstrap');
    expect(
      adapter.requests.single.uri.toString(),
      'http://fleet.test/bootstrap',
    );
  });

  test(
    'given_empty_bootstrap_body_when_requested_then_returns_typed_failure',
    () async {
      final dataSource = _dataSource(
        _Adapter((_) => ResponseBody.fromString('', 200)),
      );

      await expectLater(
        dataSource.bootstrap(),
        throwsA(const SyncBootstrapUnavailable()),
      );
    },
  );

  test('given_transport_failure_when_bootstrap_requested_then_returns_typed_failure', () async {
    final dataSource = _dataSource(
      _Adapter((_) => throw StateError('offline')),
    );

    await expectLater(
      dataSource.bootstrap(),
      throwsA(const SyncBootstrapUnavailable()),
    );
  });

  test('given_sse_delivery_when_streamed_then_sends_cursor_and_maps_delivery', () async {
    final adapter = _Adapter(
      (_) => ResponseBody.fromString(
        _sseDelivery,
        200,
        headers: const {'content-type': ['text/event-stream']},
      ),
    );
    final dataSource = _dataSource(adapter);

    final deliveries = await dataSource.deliveries(after: '42').toList();

    expect(deliveries.single.deliveryId, '43');
    expect(deliveries.single.packet.packetId, 'packet-1');
    final request = adapter.requests.single;
    expect(request.queryParameters['after'], '42');
    expect(request.headers['Last-Event-ID'], '42');
  });

  test(
    'given_replay_gap_response_when_streamed_then_returns_typed_gap',
    () async {
      final dataSource = _dataSource(
        _Adapter(
          (_) => _jsonResponse({
            'code': 'replay_gap',
            'requestedCursor': '1',
            'oldestAvailableCursor': '9',
          }, statusCode: 409),
        ),
      );

      await expectLater(
        dataSource.deliveries(after: '1').toList(),
        throwsA(
          const SyncReplayGap(requestedCursor: '1', oldestAvailableCursor: '9'),
        ),
      );
    },
  );

  test(
    'given_malformed_sse_when_streamed_then_returns_typed_transport_failure',
    () async {
      final dataSource = _dataSource(
        _Adapter((_) => ResponseBody.fromString('data: not-json\n\n', 200)),
      );

      await expectLater(
        dataSource.deliveries().toList(),
        throwsA(const SyncTransportUnavailable()),
      );
    },
  );
}

DioFleetRemoteDataSource _dataSource(_Adapter adapter) {
  final dio = Dio()..httpClientAdapter = adapter;
  return DioFleetRemoteDataSource(
    dio: dio,
    endpointProvider: const _EndpointProvider(),
  );
}

ResponseBody _jsonResponse(Map<String, Object?> json, {int statusCode = 200}) =>
    ResponseBody.fromString(
      jsonEncode(json),
      statusCode,
      headers: const {'content-type': ['application/json']},
    );

final class _EndpointProvider implements ApiEndpointProvider {
  const _EndpointProvider();

  @override
  Uri baseUri() => Uri.parse('http://fleet.test');
}

final class _Adapter implements HttpClientAdapter {
  _Adapter(this._handler);

  final FutureOr<ResponseBody> Function(RequestOptions options) _handler;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

const _bootstrapJson = <String, Object?>{
  'vehicles': [
    {
      'vehicleId': 'vehicle-1',
      'registrationNumber': 'BB-001',
      'model': 'E-Truck',
    },
  ],
  'telemetry': [_packetJson],
  'deliveryCursor': '42',
};

const _packetJson = <String, Object?>{
  'packetId': 'packet-1',
  'vehicleId': 'vehicle-1',
  'eventTimestamp': '2026-08-21T00:00:00.000Z',
  'signalName': 'soc',
  'value': {'kind': 'number', 'numberValue': 80},
};

const _sseDelivery =
    'id: 43\n'
    'data: {"deliveryId":"43","packet":{"packetId":"packet-1","vehicleId":"vehicle-1","eventTimestamp":"2026-08-21T00:00:00.000Z","signalName":"soc","value":{"kind":"number","numberValue":80}}}\n'
    '\n';
