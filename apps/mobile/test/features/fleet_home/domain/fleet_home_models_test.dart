import 'package:bytebeams/features/fleet_home/domain/fleet_home_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given_each_filter_when_status_read_then_returns_required_mapping', () {
    expect(FleetFilter.all.status, isNull);
    expect(FleetFilter.moving.status, FleetStatus.moving);
    expect(FleetFilter.idle.status, FleetStatus.idle);
    expect(FleetFilter.stopped.status, FleetStatus.stopped);
    expect(FleetFilter.offline.status, FleetStatus.offline);
  });

  test(
    'given_equal_vehicle_rows_when_compared_then_are_equal_with_same_hash',
    () {
      const row = FleetVehicleRow(
        vehicleId: 'vehicle-1',
        registrationNumber: 'BB-001',
        model: 'E-Truck',
        status: FleetStatus.idle,
        soc: 78,
        rangeKm: 242,
        attentionCount: 1,
      );
      const same = FleetVehicleRow(
        vehicleId: 'vehicle-1',
        registrationNumber: 'BB-001',
        model: 'E-Truck',
        status: FleetStatus.idle,
        soc: 78,
        rangeKm: 242,
        attentionCount: 1,
      );
      const changed = FleetVehicleRow(
        vehicleId: 'vehicle-1',
        registrationNumber: 'BB-001',
        model: 'E-Truck',
        status: FleetStatus.offline,
        soc: 78,
        rangeKm: 242,
        attentionCount: 1,
      );

      expect(row, same);
      expect(row.hashCode, same.hashCode);
      expect(row, isNot(changed));
    },
  );
}
