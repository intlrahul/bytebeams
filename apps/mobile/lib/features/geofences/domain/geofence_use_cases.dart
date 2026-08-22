import 'package:bytebeams/core/time/clock.dart';
import 'package:bytebeams/features/geofences/domain/geofence_models.dart';
import 'package:bytebeams/features/geofences/domain/geofence_repository.dart';

final class GetGeofences {
  const GetGeofences({required this.repository, required this.clock});
  final GeofenceRepository repository;
  final Clock clock;
  Future<GeofencesResult> call() => repository.getAll(nowUtc: clock.nowUtc());
}

final class SaveGeofence {
  const SaveGeofence({required this.repository, required this.clock});
  final GeofenceRepository repository;
  final Clock clock;
  Future<GeofenceActionResult> create(GeofenceDraft draft) =>
      repository.create(draft, nowUtc: clock.nowUtc());
  Future<GeofenceActionResult> edit(String id, GeofenceDraft draft) =>
      repository.edit(id, draft, nowUtc: clock.nowUtc());
}

final class DeactivateGeofence {
  const DeactivateGeofence({required this.repository, required this.clock});
  final GeofenceRepository repository;
  final Clock clock;
  Future<GeofenceActionResult> call(String id) =>
      repository.deactivate(id, nowUtc: clock.nowUtc());
}
