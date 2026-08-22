import 'package:bytebeams/core/time/clock.dart';
import 'package:bytebeams/features/sync/domain/app_event_bus.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:bytebeams/features/vehicle_detail/domain/get_vehicle_detail.dart';
import 'package:bytebeams/features/vehicle_detail/domain/vehicle_detail_models.dart';
import 'package:bytebeams/features/vehicle_detail/domain/vehicle_detail_repository.dart';
import 'package:bytebeams/features/vehicle_detail/presentation/vehicle_detail_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given_commit_before_initial_read_when_bloc_started_then_reads_once_without_loading_race', () async {
    final events = AsyncAppEventBus();
    final repository = _Repository();
    final bloc = VehicleDetailBloc(
      vehicleId: 'vehicle-1',
      getVehicleDetail: GetVehicleDetail(
        repository: repository,
        clock: const _Clock(),
      ),
      eventBus: events,
    );

    events.publish(const FleetDataCommitted());
    await Future<void>.delayed(Duration.zero);

    expect(repository.calls, 0);
    bloc.add(const VehicleDetailStarted());
    final loaded = await bloc.stream.firstWhere(
      (state) => state.detail != null,
    );

    expect(loaded.isLoading, isFalse);
    expect(repository.calls, 1);
    await bloc.close();
    await events.close();
  });

  test('given_loaded_detail_when_data_commits_then_refreshes_without_loading_screen', () async {
    final events = AsyncAppEventBus();
    final repository = _Repository();
    final bloc = VehicleDetailBloc(
      vehicleId: 'vehicle-1',
      getVehicleDetail: GetVehicleDetail(
        repository: repository,
        clock: const _Clock(),
      ),
      eventBus: events,
    );

    bloc.add(const VehicleDetailStarted());
    await bloc.stream.firstWhere((state) => state.detail != null);
    events.publish(const FleetDataCommitted());
    final refreshed = await bloc.stream.firstWhere(
      (_) => repository.calls == 2,
    );

    expect(refreshed.detail, isNotNull);
    expect(refreshed.isLoading, isFalse);
    await bloc.close();
    await events.close();
  });
}

final class _Clock implements Clock {
  const _Clock();

  @override
  DateTime nowUtc() => DateTime.utc(2026, 8, 22, 12);
}

final class _Repository implements VehicleDetailRepository {
  var calls = 0;

  @override
  Future<VehicleDetailResult> getVehicleDetail({
    required String vehicleId,
    required DateTime asOfUtc,
  }) async {
    calls += 1;
    return Result.success(
      VehicleDetail(
        vehicleId: vehicleId,
        registrationNumber: 'BB-001',
        model: 'E-Truck',
        asOfUtc: asOfUtc,
        readings: const [],
        socHistory: const [],
      ),
    );
  }
}
