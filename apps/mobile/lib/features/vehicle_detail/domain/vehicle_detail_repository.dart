import 'package:bytebeams/features/vehicle_detail/domain/vehicle_detail_models.dart';

abstract interface class VehicleDetailRepository {
  Future<VehicleDetailResult> getVehicleDetail({
    required String vehicleId,
    required DateTime asOfUtc,
  });
}
