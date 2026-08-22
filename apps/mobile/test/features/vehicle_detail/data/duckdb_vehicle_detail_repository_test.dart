import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/core/data/database/database_failure.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:bytebeams/features/vehicle_detail/data/duckdb_vehicle_detail_repository.dart';
import 'package:bytebeams/features/vehicle_detail/domain/vehicle_detail_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final asOf = DateTime.utc(2026, 8, 22, 12);

  test(
    'given_latest_valid_rows_when_detail_read_then_maps_verdicts_and_history',
    () async {
      final result = await DuckDbVehicleDetailRepository(_Database())
          .getVehicleDetail(vehicleId: 'vehicle-1', asOfUtc: asOf);
      final detail =
          (result as Success<VehicleDetail, VehicleDetailFailure>).value;

      expect(detail.readings[0].verdict, VehicleReadingVerdict.alert);
      expect(detail.readings[1].verdict, VehicleReadingVerdict.stale);
      expect(detail.readings[2].hasReported, isFalse);
      expect(detail.socHistory.map((point) => point.soc), [30, 10]);
    },
  );

  test(
    'given_missing_vehicle_when_detail_read_then_returns_not_found',
    () async {
      final result = await DuckDbVehicleDetailRepository(
        _Database(vehicle: const []),
      ).getVehicleDetail(vehicleId: 'missing', asOfUtc: asOf);
      expect(result, isA<Failure<VehicleDetail, VehicleDetailFailure>>());
    },
  );

  test(
    'given_database_failure_when_detail_read_then_returns_safe_failure',
    () async {
      final result = await DuckDbVehicleDetailRepository(_Database(fails: true))
          .getVehicleDetail(vehicleId: 'vehicle-1', asOfUtc: asOf);
      expect(result, isA<Failure<VehicleDetail, VehicleDetailFailure>>());
    },
  );
}

final class _Database implements AppDatabase {
  _Database({
    this.vehicle = const [
      ['vehicle-1', 'BB-001', 'E-Truck', null],
    ],
    this.fails = false,
  });
  final List<List<Object?>> vehicle;
  final bool fails;
  var call = 0;
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
  Future<T> transaction<T>(
    Future<T> Function(DatabaseTransaction transaction) action,
  ) => action(this);
  @override
  Future<List<List<Object?>>> query(
    String sql, {
    List<Object?> parameters = const [],
  }) async {
    if (fails) throw const DatabaseOperationFailure(safeMessage: 'unavailable');
    call += 1;
    return switch (call) {
      1 => vehicle,
      2 => [
        ['soc', 10.0, DateTime.utc(2026, 8, 22, 11, 55)],
        ['range', 50.0, DateTime.utc(2026, 8, 22, 11, 45)],
      ],
      _ => [
        [DateTime.utc(2026, 8, 21, 13), 30.0],
        [DateTime.utc(2026, 8, 22, 11), 10.0],
      ],
    };
  }
}
