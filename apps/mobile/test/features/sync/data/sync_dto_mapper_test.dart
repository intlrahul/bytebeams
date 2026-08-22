import 'package:bytebeams/features/sync/data/sync_dto_mapper.dart';
import 'package:bytebeams_api/bytebeams_api.dart' as api;
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = SyncDtoMapper();

  test('given_generated_bootstrap_when_mapped_then_preserves_contract_identity_and_cursor', () {
    final bootstrap = mapper.bootstrap(
      api.BootstrapResponse(
        vehicles: [
          api.Vehicle(
            vehicleId: 'vehicle-001',
            registrationNumber: 'BB-001',
            model: 'E-Truck',
          ),
        ],
        telemetry: [],
        deliveryCursor: '42',
      ),
    );

    expect(bootstrap.vehicles.single.vehicleId, 'vehicle-001');
    expect(bootstrap.vehicles.single.registrationNumber, 'BB-001');
    expect(bootstrap.deliveryCursor, '42');
  });

  test(
    'given_generated_delivery_when_mapped_then_preserves_delivery_identity',
    () {
      final delivery = mapper.delivery(
        api.TelemetryDelivery(
          deliveryId: '43',
          packet: api.TelemetryPacket(
            packetId: 'packet-001',
            vehicleId: 'vehicle-001',
            eventTimestamp: DateTime.utc(2026, 8, 21),
            signalName: 'soc',
            value: api.SignalValue(
              kind: api.SignalValueKindEnum.number,
              numberValue: 80,
            ),
          ),
        ),
      );

      expect(delivery.deliveryId, '43');
      expect(delivery.packet.packetId, 'packet-001');
    },
  );
}
