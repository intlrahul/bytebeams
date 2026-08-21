import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_repository.dart';

final class IngestTelemetryPacket {
  const IngestTelemetryPacket(this._repository);

  final TelemetryRepository _repository;

  Future<Result<bool, TelemetryFailure>> call(
    ClassifiedTelemetryPacket packet,
  ) => _repository.store(packet);
}
