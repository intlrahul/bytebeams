import 'package:bytebeams/core/time/clock.dart';
import 'package:bytebeams/features/fleet_home/domain/fleet_home_models.dart';
import 'package:bytebeams/features/fleet_home/domain/fleet_home_repository.dart';
import 'package:bytebeams/features/fleet_home/domain/get_fleet_home.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'given_selected_filter_when_fleet_requested_then_uses_injected_clock',
    () async {
      final repository = _Repository();
      final now = DateTime.utc(2026, 8, 22, 12);

      await GetFleetHome(repository: repository, clock: _Clock(now))(
        FleetFilter.idle,
      );

      expect(repository.filter, FleetFilter.idle);
      expect(repository.asOfUtc, now);
    },
  );
}

final class _Clock implements Clock {
  const _Clock(this.value);

  final DateTime value;

  @override
  DateTime nowUtc() => value;
}

final class _Repository implements FleetHomeRepository {
  FleetFilter? filter;
  DateTime? asOfUtc;

  @override
  Future<FleetHomeResult> getFleet({
    required FleetFilter filter,
    required DateTime asOfUtc,
  }) async {
    this.filter = filter;
    this.asOfUtc = asOfUtc;
    return const Result.success(
      FleetHomeSnapshot(
        rows: [],
        counts: FleetFilterCounts(
          all: 0,
          moving: 0,
          idle: 0,
          stopped: 0,
          offline: 0,
        ),
      ),
    );
  }
}
