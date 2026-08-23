import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/features/alerts/data/duckdb_alert_projector.dart';
import 'package:bytebeams/features/geofences/data/duckdb_geofence_projector.dart';
import 'package:bytebeams/features/sync/data/projection_rebuild_service.dart';
import 'package:bytebeams/features/trips/data/duckdb_trip_projector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'given_duplicate_vehicle_ids_when_rebuilt_then_projects_each_vehicle_once',
    () async {
      final alerts = _Alerts();
      final geofences = _Geofences();
      final trips = _Trips();
      await DuckDbProjectionRebuildService(
        alertProjector: alerts,
        geofenceProjector: geofences,
        tripProjector: trips,
      ).rebuild(_Database(), ['vehicle-1', 'vehicle-1']);
      expect(alerts.ids, ['vehicle-1']);
      expect(geofences.ids, ['vehicle-1']);
      expect(trips.ids, ['vehicle-1']);
    },
  );
}

final class _Alerts implements AlertProjector {
  List<String> ids = [];
  @override
  Future<void> rebuild(
    DatabaseTransaction database,
    Iterable<String> vehicleIds,
  ) async => ids = vehicleIds.toList();
}

final class _Geofences implements GeofenceProjector {
  List<String> ids = [];
  @override
  Future<void> rebuild(
    DatabaseTransaction database,
    Iterable<String> vehicleIds,
  ) async => ids = vehicleIds.toList();
}

final class _Trips implements TripProjector {
  List<String> ids = [];
  @override
  Future<void> rebuild(
    DatabaseTransaction database,
    Iterable<String> vehicleIds,
  ) async => ids = vehicleIds.toList();
}

final class _Database implements AppDatabase {
  @override
  Future<void> close() async {}
  @override
  Future<int> currentSchemaVersion() async => 6;
  @override
  Future<void> execute(
    String sql, {
    List<Object?> parameters = const [],
  }) async {}
  @override
  Future<List<List<Object?>>> query(
    String sql, {
    List<Object?> parameters = const [],
  }) async => const [];
  @override
  Future<T> transaction<T>(
    Future<T> Function(DatabaseTransaction transaction) action,
  ) => action(this);
}
