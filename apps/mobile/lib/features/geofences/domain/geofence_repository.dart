import 'package:bytebeams/features/geofences/domain/geofence_models.dart';

abstract interface class GeofenceRepository {
  Future<GeofencesResult> getAll({required DateTime nowUtc});
  Future<GeofenceActionResult> create(
    GeofenceDraft draft, {
    required DateTime nowUtc,
  });
  Future<GeofenceActionResult> edit(
    String id,
    GeofenceDraft draft, {
    required DateTime nowUtc,
  });
  Future<GeofenceActionResult> deactivate(
    String id, {
    required DateTime nowUtc,
  });
  Future<VehicleGeofenceMembership?> membershipForVehicle(String vehicleId);
}
