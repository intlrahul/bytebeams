import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/core/data/database/database_failure.dart';
import 'package:bytebeams/features/telemetry/data/duckdb_vehicle_repository.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given_a_vehicle_when_upserted_then_returns_success', () async {
    final result = await DuckDbVehicleRepository(_Database()).upsert(
      const Vehicle(vehicleId: 'v', registrationNumber: 'R', model: 'M'),
    );
    expect(result, isA<Success<void, TelemetryFailure>>());
  });
  test(
    'given_a_database_failure_when_upserted_then_returns_safe_failure',
    () async {
      final result = await DuckDbVehicleRepository(_Database(fails: true))
          .upsert(
            const Vehicle(vehicleId: 'v', registrationNumber: 'R', model: 'M'),
          );
      expect(result, isA<Failure<void, TelemetryFailure>>());
    },
  );
}

final class _Database implements AppDatabase {
  _Database({this.fails = false});
  final bool fails;
  @override
  Future<void> close() async {}
  @override
  Future<int> currentSchemaVersion() async => 2;
  @override
  Future<void> execute(
    String sql, {
    List<Object?> parameters = const [],
  }) async {
    if (fails) throw const DatabaseOperationFailure(safeMessage: 'x');
  }

  @override
  Future<List<List<Object?>>> query(
    String sql, {
    List<Object?> parameters = const [],
  }) async => [];
  @override
  Future<T> transaction<T>(
    Future<T> Function(DatabaseTransaction transaction) action,
  ) => action(this);
}
