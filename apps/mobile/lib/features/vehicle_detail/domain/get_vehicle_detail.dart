import 'package:bytebeams/core/time/clock.dart';
import 'package:bytebeams/features/vehicle_detail/domain/vehicle_detail_models.dart';
import 'package:bytebeams/features/vehicle_detail/domain/vehicle_detail_repository.dart';

final class GetVehicleDetail {
  const GetVehicleDetail({required this.repository, required this.clock});

  final VehicleDetailRepository repository;
  final Clock clock;

  Future<VehicleDetailResult> call(String vehicleId) => repository
      .getVehicleDetail(vehicleId: vehicleId, asOfUtc: clock.nowUtc());
}
