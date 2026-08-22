import 'package:bytebeams/features/sync/domain/app_event_bus.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:bytebeams/features/trips/domain/trip_models.dart';
import 'package:bytebeams/features/trips/domain/trip_repository.dart';
import 'package:bytebeams/features/trips/presentation/trips_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'given_loaded_trips_when_data_commits_then_requeries_authoritative_store',
    () async {
      final events = AsyncAppEventBus();
      final repository = _Repository();
      final bloc = TripsBloc(repository: repository, eventBus: events);

      bloc.add(const TripsStarted());
      await bloc.stream.firstWhere((state) => state.trips.isNotEmpty);
      events.publish(const FleetDataCommitted());
      await bloc.stream.firstWhere((_) => repository.calls == 2);

      expect(repository.calls, 2);
      await bloc.close();
      await events.close();
    },
  );
  test('given_filter_and_failure_when_requested_then_exposes_selected_status_and_failure', () async {
    final events = AsyncAppEventBus();
    final repository = _Repository()
      ..result = const Result.failure(TripPersistenceUnavailable());
    final bloc = TripsBloc(repository: repository, eventBus: events);

    bloc.add(const TripsFilterChanged(TripStatus.completed));
    final failed = await bloc.stream.firstWhere(
      (state) => state.failure != null,
    );

    expect(failed.status, TripStatus.completed);
    expect(repository.statuses, [TripStatus.completed]);
    await bloc.close();
    await events.close();
  });
}

final class _Repository implements TripRepository {
  var calls = 0;
  final statuses = <TripStatus?>[];
  TripResult? result;

  @override
  Future<TripResult> getTrips({String? vehicleId, TripStatus? status}) async {
    calls++;
    statuses.add(status);
    return result ??
        Result.success([
          Trip(
            id: 'trip-1',
            vehicleId: 'vehicle-1',
            registrationNumber: 'BB-1',
            origin: 'Hub',
            startedAtUtc: DateTime.utc(2026),
            status: TripStatus.inProgress,
          ),
        ]);
  }
}
