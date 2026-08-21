import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/core/data/database/database_failure.dart';
import 'package:bytebeams/features/telemetry/data/duckdb_telemetry_repository.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given_duplicate_packet_when_stored_then_reports_not_new', () async {
    final database = _Database();
    final repository = DuckDbTelemetryRepository(database);
    expect(
      await repository.store(_packet),
      isA<Success<bool, TelemetryFailure>>(),
    );
    expect(
      (await repository.store(
        _packet,
      ) as Success<bool, TelemetryFailure>).value,
      isFalse,
    );
  });

  test(
    'given_diagnostics_rows_when_read_then_maps_the_persisted_order',
    () async {
      final database = _Database()
        ..diagnosticRows = [
          [
            'a',
            'vehicle-1',
            '2026-01-01T00:00:00Z',
            '2026-01-01T00:00:01Z',
            'soc',
            '{}',
            'supportedValid',
            null,
            null,
          ],
        ];
      final result = await DuckDbTelemetryRepository(database)
          .diagnosticsForVehicle('vehicle-1');
      expect(
        (result as Success<List<ClassifiedTelemetryPacket>, TelemetryFailure>)
            .value
            .single
            .packetId,
        'a',
      );
    },
  );

  test(
    'given_optional_diagnostic_fields_when_read_then_preserves_them',
    () async {
      final database = _Database()
        ..diagnosticRows = [
          [
            'b',
            'vehicle-1',
            DateTime.utc(2026),
            DateTime.utc(2026),
            'soc',
            '{}',
            'supportedInvalid',
            DateTime.utc(2026),
            'outside range',
          ],
        ];
      final result = await DuckDbTelemetryRepository(database)
          .diagnosticsForVehicle('vehicle-1');
      final packet =
          (result as Success<List<ClassifiedTelemetryPacket>, TelemetryFailure>)
              .value
              .single;
      expect(packet.serverReceivedAtUtc, DateTime.utc(2026));
      expect(packet.validationError, 'outside range');
    },
  );

  test(
    'given_a_database_failure_when_stored_then_returns_safe_failure',
    () async {
      final result = await DuckDbTelemetryRepository(_Database(fails: true))
          .store(_packet);

      expect(result, isA<Failure<bool, TelemetryFailure>>());
    },
  );

  test('given_a_database_failure_when_reading_diagnostics_then_returns_safe_failure', () async {
    final result = await DuckDbTelemetryRepository(_Database(fails: true))
        .diagnosticsForVehicle('vehicle-1');

    expect(
      result,
      isA<Failure<List<ClassifiedTelemetryPacket>, TelemetryFailure>>(),
    );
  });
}

final _packet = ClassifiedTelemetryPacket(
  packetId: 'packet-1',
  vehicleId: 'vehicle-1',
  eventTimestampUtc: DateTime.utc(2026),
  clientReceivedAtUtc: DateTime.utc(2026),
  signalName: 'soc',
  rawValueJson: '{}',
  classification: TelemetryClassification.supportedValid,
  value: TelemetrySignalValue.number(50),
);

final class _Database implements AppDatabase {
  _Database({this.fails = false});

  final bool fails;
  bool inserted = false;
  List<List<Object?>> diagnosticRows = const [];
  @override
  Future<void> close() async {}
  @override
  Future<int> currentSchemaVersion() async => 2;
  @override
  Future<void> execute(
    String sql, {
    List<Object?> parameters = const [],
  }) async {}
  @override
  Future<List<List<Object?>>> query(
    String sql, {
    List<Object?> parameters = const [],
  }) async {
    if (fails) {
      throw const DatabaseOperationFailure(safeMessage: 'test failure');
    }
    if (sql.contains('ORDER BY event_timestamp_utc')) {
      return diagnosticRows;
    }
    if (inserted) return [];
    inserted = true;
    return [
      ['packet-1'],
    ];
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(DatabaseTransaction transaction) action,
  ) => action(this);
}
