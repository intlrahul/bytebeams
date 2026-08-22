import 'dart:math' as math;

enum GeofenceReadingState { inside, outside, indeterminate, rejected }

final class GeofenceVersionRecord {
  const GeofenceVersionRecord({
    required this.id,
    required this.version,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.isActive,
    required this.effectiveFromUtc,
    this.effectiveUntilUtc,
  });

  final String id;
  final int version;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final bool isActive;
  final DateTime effectiveFromUtc;
  final DateTime? effectiveUntilUtc;

  bool appliesAt(DateTime eventTimestampUtc) =>
      !eventTimestampUtc.isBefore(effectiveFromUtc) &&
      (effectiveUntilUtc == null ||
          eventTimestampUtc.isBefore(effectiveUntilUtc!));
}

GeofenceReadingState classifyGeofenceReading({
  required GeofenceVersionRecord geofence,
  required double latitude,
  required double longitude,
  required double accuracyMeters,
}) {
  if (accuracyMeters > 100) return GeofenceReadingState.rejected;
  final margin = math.min(math.max(20, accuracyMeters), 75).toDouble();
  final distance = distanceMeters(
    latitude,
    longitude,
    geofence.latitude,
    geofence.longitude,
  );
  if (distance <= geofence.radiusMeters - margin) {
    return GeofenceReadingState.inside;
  }
  if (distance >= geofence.radiusMeters + margin) {
    return GeofenceReadingState.outside;
  }
  return GeofenceReadingState.indeterminate;
}

double distanceMeters(
  double latitudeA,
  double longitudeA,
  double latitudeB,
  double longitudeB,
) {
  const earthRadiusMeters = 6371000.0;
  final latDelta = _radians(latitudeB - latitudeA);
  final lonDelta = _radians(longitudeB - longitudeA);
  final a =
      math.pow(math.sin(latDelta / 2), 2) +
      math.cos(_radians(latitudeA)) *
          math.cos(_radians(latitudeB)) *
          math.pow(math.sin(lonDelta / 2), 2);
  return earthRadiusMeters * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

double _radians(double degrees) => degrees * math.pi / 180;
