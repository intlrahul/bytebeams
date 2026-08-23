import 'package:bytebeams/features/sync/data/sync_dto_mapper.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:bytebeams_api/bytebeams_api.dart' as api;

final class RetentionSeedFactory {
  const RetentionSeedFactory._();

  static List<Vehicle> vehicles({int count = 500}) => List.generate(
    count,
    (index) => Vehicle(
      vehicleId: 'retention-${index.toString().padLeft(3, '0')}',
      registrationNumber: 'RT-${index.toString().padLeft(3, '0')}',
      model: 'Retention Truck',
    ),
  );

  static List<SyncDeliveryDto> deliveries({
    int count = 10000,
    DateTime? startUtc,
  }) {
    final start = startUtc ?? DateTime.utc(2026, 1, 1);
    return List.generate(count, (index) {
      final vehicle = 'retention-${(index % 500).toString().padLeft(3, '0')}';
      return SyncDeliveryDto(
        deliveryId: '${index + 1}',
        packet: api.TelemetryPacket(
          packetId: 'retention-packet-$index',
          vehicleId: vehicle,
          eventTimestamp: start.add(Duration(minutes: index)),
          signalName: 'soc',
          value: api.SignalValue(
            kind: api.SignalValueKindEnum.number,
            numberValue: 20 + (index % 70).toDouble(),
          ),
        ),
      );
    });
  }
}
