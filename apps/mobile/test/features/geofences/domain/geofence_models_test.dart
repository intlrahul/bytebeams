import 'package:bytebeams/features/geofences/domain/geofence_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given_approved_bounds_when_validated_then_accepts_draft', () {
    expect(
      const GeofenceDraft(
        displayName: '  Demo area  ',
        latitude: -90,
        longitude: 180,
        radiusMeters: 50,
      ).validate(),
      isNull,
    );
  });

  test(
    'given_invalid_values_when_validated_then_returns_documented_failure',
    () {
      expect(
        const GeofenceDraft(
          displayName: ' ',
          latitude: 0,
          longitude: 0,
          radiusMeters: 100,
        ).validate(),
        isA<GeofenceInvalidName>(),
      );
      expect(
        const GeofenceDraft(
          displayName: 'Area',
          latitude: 0,
          longitude: 0,
          radiusMeters: 50001,
        ).validate(),
        isA<GeofenceInvalidRadius>(),
      );
    },
  );
}
