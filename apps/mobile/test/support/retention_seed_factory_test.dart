import 'retention_seed_factory.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given_representative_seed_when_generated_then_has_stable_500_vehicle_10000_delivery_shape', () {
    final vehicles = RetentionSeedFactory.vehicles();
    final deliveries = RetentionSeedFactory.deliveries();
    expect(vehicles, hasLength(500));
    expect(deliveries, hasLength(10000));
    expect(deliveries.first.packet.packetId, 'retention-packet-0');
    expect(deliveries.last.packet.vehicleId, 'retention-499');
  });
}
