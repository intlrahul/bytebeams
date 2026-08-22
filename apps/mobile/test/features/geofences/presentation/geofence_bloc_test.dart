import 'package:bytebeams/core/time/clock.dart';
import 'package:bytebeams/features/geofences/domain/geofence_models.dart';
import 'package:bytebeams/features/geofences/domain/geofence_repository.dart';
import 'package:bytebeams/features/geofences/domain/geofence_use_cases.dart';
import 'package:bytebeams/features/geofences/presentation/geofence_bloc.dart';
import 'package:bytebeams/features/sync/domain/app_event_bus.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'given_persistence_failure_when_geofences_started_then_exposes_failure',
    () async {
      final events = AsyncAppEventBus();
      final repository = _FailureRepository();
      final bloc = GeofenceBloc(
        GetGeofences(repository: repository, clock: const _Clock()),
        SaveGeofence(repository: repository, clock: const _Clock()),
        DeactivateGeofence(repository: repository, clock: const _Clock()),
        eventBus: events,
      );

      bloc.add(const GeofencesStarted());
      final state = await bloc.stream.firstWhere(
        (state) => state.failure != null,
      );

      expect(state.isLoading, isFalse);
      expect(state.failure, isA<GeofencePersistenceUnavailable>());
      await bloc.close();
      await events.close();
    },
  );
}

final class _Clock implements Clock {
  const _Clock();
  @override
  DateTime nowUtc() => DateTime.utc(2026);
}

final class _FailureRepository implements GeofenceRepository {
  @override
  Future<GeofencesResult> getAll({required DateTime nowUtc}) async =>
      const Result.failure(GeofencePersistenceUnavailable());
  @override
  Future<GeofenceActionResult> create(
    GeofenceDraft draft, {
    required DateTime nowUtc,
  }) async => const Result.failure(GeofencePersistenceUnavailable());
  @override
  Future<GeofenceActionResult> deactivate(
    String id, {
    required DateTime nowUtc,
  }) async => const Result.failure(GeofencePersistenceUnavailable());
  @override
  Future<GeofenceActionResult> edit(
    String id,
    GeofenceDraft draft, {
    required DateTime nowUtc,
  }) async => const Result.failure(GeofencePersistenceUnavailable());
  @override
  Future<VehicleGeofenceMembership?> membershipForVehicle(
    String vehicleId,
  ) async => null;
}
