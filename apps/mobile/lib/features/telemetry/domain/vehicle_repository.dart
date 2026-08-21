import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';

abstract interface class VehicleRepository {
  Future<Result<void, TelemetryFailure>> upsert(Vehicle vehicle);
}
