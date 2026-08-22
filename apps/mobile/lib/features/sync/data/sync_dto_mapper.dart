import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart'
    as domain;
import 'package:bytebeams_api/bytebeams_api.dart' as api;

final class SyncBootstrapDto {
  const SyncBootstrapDto({
    required this.vehicles,
    required this.telemetry,
    required this.deliveryCursor,
  });

  final List<domain.Vehicle> vehicles;
  final List<api.TelemetryPacket> telemetry;
  final String deliveryCursor;
}

final class SyncDeliveryDto {
  const SyncDeliveryDto({required this.deliveryId, required this.packet});

  final String deliveryId;
  final api.TelemetryPacket packet;
}

final class SyncDtoMapper {
  const SyncDtoMapper();

  SyncBootstrapDto bootstrap(api.BootstrapResponse response) =>
      SyncBootstrapDto(
        vehicles: response.vehicles
            .map(
              (vehicle) => domain.Vehicle(
                vehicleId: vehicle.vehicleId,
                registrationNumber: vehicle.registrationNumber,
                model: vehicle.model,
              ),
            )
            .toList(growable: false),
        telemetry: response.telemetry,
        deliveryCursor: response.deliveryCursor,
      );

  SyncDeliveryDto delivery(api.TelemetryDelivery delivery) =>
      SyncDeliveryDto(deliveryId: delivery.deliveryId, packet: delivery.packet);
}
