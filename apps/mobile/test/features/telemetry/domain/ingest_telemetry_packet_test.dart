import 'package:bytebeams/features/telemetry/domain/ingest_telemetry_packet.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'given_a_classified_packet_when_ingested_then_returns_repository_outcome',
    () async {
      final repository = _Repository();
      final result = await IngestTelemetryPacket(repository)(_packet);
      expect(repository.storedPacket, _packet);
      expect((result as Success<bool, TelemetryFailure>).value, isTrue);
    },
  );
}

final _packet = ClassifiedTelemetryPacket(
  packetId: 'p',
  vehicleId: 'v',
  eventTimestampUtc: DateTime.utc(2026),
  clientReceivedAtUtc: DateTime.utc(2026),
  signalName: 'soc',
  rawValueJson: '{}',
  classification: TelemetryClassification.supportedValid,
);

final class _Repository implements TelemetryRepository {
  ClassifiedTelemetryPacket? storedPacket;
  @override
  Future<Result<List<ClassifiedTelemetryPacket>, TelemetryFailure>>
  diagnosticsForVehicle(String vehicleId) async => const Result.success([]);
  @override
  Future<Result<bool, TelemetryFailure>> store(
    ClassifiedTelemetryPacket packet,
  ) async {
    storedPacket = packet;
    return const Result.success(true);
  }
}
