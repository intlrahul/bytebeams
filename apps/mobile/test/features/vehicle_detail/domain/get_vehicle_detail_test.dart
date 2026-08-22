import 'package:bytebeams/core/time/clock.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:bytebeams/features/vehicle_detail/domain/get_vehicle_detail.dart';
import 'package:bytebeams/features/vehicle_detail/domain/vehicle_detail_models.dart';
import 'package:bytebeams/features/vehicle_detail/domain/vehicle_detail_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'given_vehicle_id_when_detail_requested_then_delegates_with_injected_clock',
    () async {
      final repository = _Repository();
      await GetVehicleDetail(repository: repository, clock: const _Clock())(
        'vehicle-1',
      );
      expect(repository.vehicleId, 'vehicle-1');
      expect(repository.asOfUtc, DateTime.utc(2026, 8, 22, 12));
    },
  );
}

final class _Clock implements Clock {
  const _Clock();
  @override
  DateTime nowUtc() => DateTime.utc(2026, 8, 22, 12);
}

final class _Repository implements VehicleDetailRepository {
  String? vehicleId;
  DateTime? asOfUtc;
  @override
  Future<VehicleDetailResult> getVehicleDetail({
    required String vehicleId,
    required DateTime asOfUtc,
  }) async {
    this.vehicleId = vehicleId;
    this.asOfUtc = asOfUtc;
    return const Result.failure(VehicleDetailFailure.notFound());
  }
}
