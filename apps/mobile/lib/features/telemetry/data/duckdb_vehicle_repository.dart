import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/core/data/database/database_failure.dart';
import 'package:bytebeams/features/telemetry/data/telemetry_queries.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:bytebeams/features/telemetry/domain/vehicle_repository.dart';

final class DuckDbVehicleRepository implements VehicleRepository {
  const DuckDbVehicleRepository(this._database);

  final AppDatabase _database;

  @override
  Future<Result<void, TelemetryFailure>> upsert(Vehicle vehicle) async {
    try {
      await _database.execute(
        upsertVehicle,
        parameters: [
          vehicle.vehicleId,
          vehicle.registrationNumber,
          vehicle.model,
        ],
      );
      return const Result.success(null);
    } on DatabaseFailure {
      return const Result.failure(TelemetryFailure.persistenceUnavailable());
    }
  }
}
