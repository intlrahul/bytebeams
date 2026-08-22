import 'package:bytebeams/features/fleet_home/domain/fleet_home_models.dart';

abstract interface class FleetHomeRepository {
  Future<FleetHomeResult> getFleet({
    required FleetFilter filter,
    required DateTime asOfUtc,
  });
}
