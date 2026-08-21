import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';

abstract interface class TelemetryRepository {
  Future<Result<bool, TelemetryFailure>> store(
    ClassifiedTelemetryPacket packet,
  );

  Future<Result<List<ClassifiedTelemetryPacket>, TelemetryFailure>>
  diagnosticsForVehicle(String vehicleId);
}
