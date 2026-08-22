import 'package:bytebeams/core/time/clock.dart';
import 'package:bytebeams/features/fleet_home/domain/fleet_home_models.dart';
import 'package:bytebeams/features/fleet_home/domain/fleet_home_repository.dart';

final class GetFleetHome {
  const GetFleetHome({required this.repository, required this.clock});

  final FleetHomeRepository repository;
  final Clock clock;

  Future<FleetHomeResult> call(FleetFilter filter) =>
      repository.getFleet(filter: filter, asOfUtc: clock.nowUtc());
}
