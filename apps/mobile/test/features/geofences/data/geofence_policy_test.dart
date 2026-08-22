import 'package:bytebeams/features/geofences/data/geofence_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final geofence = GeofenceVersionRecord(
    id: 'demo-hub',
    version: 1,
    latitude: 12.9016,
    longitude: 77.6877,
    radiusMeters: 100,
    isActive: true,
    effectiveFromUtc: DateTime.utc(2026),
  );

  test('given_location_at_centre_when_classified_then_is_inside', () {
    expect(
      classifyGeofenceReading(
        geofence: geofence,
        latitude: 12.9016,
        longitude: 77.6877,
        accuracyMeters: 10,
      ),
      GeofenceReadingState.inside,
    );
  });

  test('given_boundary_zone_when_classified_then_is_indeterminate', () {
    expect(
      classifyGeofenceReading(
        geofence: geofence,
        latitude: 12.9025,
        longitude: 77.6877,
        accuracyMeters: 20,
      ),
      GeofenceReadingState.indeterminate,
    );
  });

  test('given_accuracy_above_limit_when_classified_then_is_rejected', () {
    expect(
      classifyGeofenceReading(
        geofence: geofence,
        latitude: 12.9016,
        longitude: 77.6877,
        accuracyMeters: 101,
      ),
      GeofenceReadingState.rejected,
    );
  });
}
