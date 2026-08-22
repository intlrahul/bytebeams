import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';

final class Geofence {
  const Geofence({
    required this.id,
    required this.version,
    required this.displayName,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.isActive,
    required this.effectiveFromUtc,
    required this.vehicleCount,
  });

  final String id;
  final int version;
  final String displayName;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final bool isActive;
  final DateTime effectiveFromUtc;
  final int vehicleCount;
}

final class GeofenceDraft {
  const GeofenceDraft({
    required this.displayName,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
  });

  final String displayName;
  final double latitude;
  final double longitude;
  final double radiusMeters;

  GeofenceFailure? validate() {
    if (displayName.trim().isEmpty || displayName.trim().length > 80) {
      return const GeofenceInvalidName();
    }
    if (latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      return const GeofenceInvalidCoordinates();
    }
    if (radiusMeters < 50 || radiusMeters > 50000) {
      return const GeofenceInvalidRadius();
    }
    return null;
  }
}

final class VehicleGeofenceMembership {
  const VehicleGeofenceMembership({
    required this.vehicleId,
    required this.geofenceName,
    required this.observedAtUtc,
  });

  final String vehicleId;
  final String? geofenceName;
  final DateTime? observedAtUtc;
}

sealed class GeofenceFailure {
  const GeofenceFailure();
  const factory GeofenceFailure.persistenceUnavailable() =
      GeofencePersistenceUnavailable;
  const factory GeofenceFailure.notFound() = GeofenceNotFound;
  const factory GeofenceFailure.invalidName() = GeofenceInvalidName;
  const factory GeofenceFailure.invalidCoordinates() =
      GeofenceInvalidCoordinates;
  const factory GeofenceFailure.invalidRadius() = GeofenceInvalidRadius;
}

final class GeofencePersistenceUnavailable extends GeofenceFailure {
  const GeofencePersistenceUnavailable();
}

final class GeofenceNotFound extends GeofenceFailure {
  const GeofenceNotFound();
}

final class GeofenceInvalidName extends GeofenceFailure {
  const GeofenceInvalidName();
}

final class GeofenceInvalidCoordinates extends GeofenceFailure {
  const GeofenceInvalidCoordinates();
}

final class GeofenceInvalidRadius extends GeofenceFailure {
  const GeofenceInvalidRadius();
}

typedef GeofencesResult = Result<List<Geofence>, GeofenceFailure>;
typedef GeofenceActionResult = Result<void, GeofenceFailure>;
