import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/core/time/clock.dart';
import 'package:bytebeams/features/sync/data/duckdb_sync_store.dart';
import 'package:bytebeams/features/sync/data/sync_dto_mapper.dart';
import 'package:bytebeams/features/sync/data/sync_queries.dart';
import 'package:bytebeams/features/telemetry/data/telemetry_packet_classifier.dart';
import 'package:bytebeams/features/telemetry/data/telemetry_queries.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:bytebeams_api/bytebeams_api.dart' as api;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given_no_sync_state_when_cursor_read_then_returns_null', () async {
    final database = _Database();
    final store = _store(database);

    expect(await store.deliveryCursor(), isNull);
  });

  test(
    'given_persisted_cursor_and_vehicle_when_read_then_returns_local_state',
    () async {
      final database = _Database()
        ..responses[selectSyncCursor] = [
          ['101'],
        ]
        ..responses['SELECT COUNT(*) FROM vehicles'] = [
          [1],
        ];
      final store = _store(database);

      expect(await store.deliveryCursor(), '101');
      expect(await store.hasUsableFleetData(), isTrue);
    },
  );

  test(
    'given_empty_vehicle_registry_when_read_then_reports_no_usable_local_fleet',
    () async {
      final database = _Database()
        ..responses['SELECT COUNT(*) FROM vehicles'] = [
          [0],
        ];

      expect(await _store(database).hasUsableFleetData(), isFalse);
    },
  );

  test('given_bootstrap_when_imported_then_writes_registry_telemetry_cursor_and_origin_in_one_transaction', () async {
    final database = _Database();
    final store = _store(database);

    await store.importBootstrap(
      SyncBootstrapDto(
        vehicles: const [
          Vehicle(
            vehicleId: 'vehicle-1',
            registrationNumber: 'BB-001',
            model: 'E-Truck',
          ),
        ],
        telemetry: [_packet('soc', _number(80))],
        deliveryCursor: '10',
      ),
      origin: 'backend',
    );

    expect(database.transactions, 1);
    expect(
      database.executions.map((entry) => entry.sql),
      containsAll([
        upsertVehicle,
        insertTelemetryEvent,
        upsertSyncCursor,
        upsertSyncOrigin,
      ]),
    );
    final telemetry = database.executions.firstWhere(
      (entry) => entry.sql == insertTelemetryEvent,
    );
    expect(telemetry.parameters[9], 80.0);
    expect(telemetry.parameters[10], isNull);
  });

  test('given_boolean_and_location_deliveries_when_ingested_then_stores_typed_values_before_cursor', () async {
    final database = _Database();
    final store = _store(database);

    await store.ingestDelivery(
      SyncDeliveryDto(
        deliveryId: '11',
        packet: _packet(
          'ignition',
          api.SignalValue(
            kind: api.SignalValueKindEnum.boolean,
            booleanValue: true,
          ),
        ),
      ),
    );
    await store.ingestDelivery(
      SyncDeliveryDto(
        deliveryId: '12',
        packet: _packet(
          'location',
          api.SignalValue(
            kind: api.SignalValueKindEnum.location,
            locationValue: api.LocationValue(
              latitude: 12.9,
              longitude: 77.6,
              accuracyMeters: 10,
            ),
          ),
        ),
      ),
    );

    final telemetry = database.executions
        .where((entry) => entry.sql == insertTelemetryEvent)
        .toList();
    expect(telemetry[0].parameters[10], isTrue);
    expect(telemetry[1].parameters.sublist(11, 14), [12.9, 77.6, 10.0]);
    for (final index in [1, 3]) {
      expect(database.executions[index].sql, upsertSyncCursor);
    }
  });

  test('given_invalid_identity_delivery_when_ingested_then_keeps_cursor_without_creating_event', () async {
    final database = _Database();
    final store = _store(database);

    await store.ingestDelivery(
      SyncDeliveryDto(
        deliveryId: '13',
        packet: api.TelemetryPacket(
          packetId: ' ',
          vehicleId: 'vehicle-1',
          eventTimestamp: DateTime.utc(2026, 8, 21),
          signalName: 'soc',
          value: _number(80),
        ),
      ),
    );

    expect(database.executions.map((entry) => entry.sql), [upsertSyncCursor]);
  });

  test('given_delivery_batch_when_ingested_then_writes_all_events_and_advances_cursor_once', () async {
    final database = _Database();
    final store = _store(database);

    await store.ingestDeliveries([
      SyncDeliveryDto(deliveryId: '16', packet: _packet('soc', _number(80))),
      SyncDeliveryDto(deliveryId: '17', packet: _packet('speed', _number(40))),
    ]);

    expect(database.transactions, 1);
    expect(
      database.executions.where((entry) => entry.sql == insertTelemetryEvent),
      hasLength(2),
    );
    final cursorWrites = database.executions
        .where((entry) => entry.sql == upsertSyncCursor)
        .toList();
    expect(cursorWrites, hasLength(1));
    expect(cursorWrites.single.parameters, ['17']);
  });

  test('given_server_refresh_when_replaced_then_removes_only_backend_data_before_importing_snapshot', () async {
    final database = _Database();
    final store = _store(database);

    await store.replaceBackendData(
      SyncBootstrapDto(vehicles: const [], telemetry: [], deliveryCursor: '14'),
    );

    expect(database.transactions, 1);
    expect(database.executions[0].sql, deleteBackendSyncedData);
    expect(database.executions[1].sql, deleteBackendSyncedVehicles);
    expect(database.executions[2].sql, upsertSyncCursor);
    expect(database.executions[3].parameters, ['backend']);
  });

  test('given_packet_write_failure_when_delivery_ingested_then_rolls_back_and_does_not_advance_cursor', () async {
    final database = _Database()..failSql = insertTelemetryEvent;
    final store = _store(database);

    await expectLater(
      store.ingestDelivery(
        SyncDeliveryDto(deliveryId: '15', packet: _packet('soc', _number(80))),
      ),
      throwsStateError,
    );

    expect(database.executions, isEmpty);
  });
}

DuckDbSyncStore _store(_Database database) => DuckDbSyncStore(
  database: database,
  classifier: TelemetryPacketClassifier(clock: const _Clock()),
);

api.SignalValue _number(double value) =>
    api.SignalValue(kind: api.SignalValueKindEnum.number, numberValue: value);

api.TelemetryPacket _packet(String signal, api.SignalValue value) =>
    api.TelemetryPacket(
      packetId: 'packet-$signal-${value.hashCode}',
      vehicleId: 'vehicle-1',
      eventTimestamp: DateTime.utc(2026, 8, 21),
      signalName: signal,
      value: value,
    );

final class _Clock implements Clock {
  const _Clock();

  @override
  DateTime nowUtc() => DateTime.utc(2026, 8, 21);
}

final class _Execution {
  const _Execution(this.sql, this.parameters);

  final String sql;
  final List<Object?> parameters;
}

final class _Database implements AppDatabase {
  final responses = <String, List<List<Object?>>>{};
  final executions = <_Execution>[];
  int transactions = 0;
  String? failSql;

  @override
  Future<void> close() async {}

  @override
  Future<int> currentSchemaVersion() async => 3;

  @override
  Future<void> execute(
    String sql, {
    List<Object?> parameters = const [],
  }) async {
    if (sql == failSql) {
      throw StateError('write failed');
    }
    executions.add(_Execution(sql, List<Object?>.of(parameters)));
  }

  @override
  Future<List<List<Object?>>> query(
    String sql, {
    List<Object?> parameters = const [],
  }) async => responses[sql] ?? const [];

  @override
  Future<T> transaction<T>(
    Future<T> Function(DatabaseTransaction transaction) action,
  ) async {
    transactions += 1;
    final before = List<_Execution>.of(executions);
    try {
      return await action(this);
    } catch (_) {
      executions
        ..clear()
        ..addAll(before);
      rethrow;
    }
  }
}
