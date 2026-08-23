import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/features/alerts/data/duckdb_alert_projector.dart';
import 'package:bytebeams/features/geofences/data/duckdb_geofence_projector.dart';
import 'package:bytebeams/features/trips/data/duckdb_trip_projector.dart';

abstract interface class ProjectionRebuildService {
  Future<void> rebuild(
    DatabaseTransaction database,
    Iterable<String> vehicleIds,
  );
}

final class DuckDbProjectionRebuildService implements ProjectionRebuildService {
  const DuckDbProjectionRebuildService({
    this.alertProjector,
    this.geofenceProjector,
    this.tripProjector,
  });

  final AlertProjector? alertProjector;
  final GeofenceProjector? geofenceProjector;
  final TripProjector? tripProjector;

  @override
  Future<void> rebuild(
    DatabaseTransaction database,
    Iterable<String> vehicleIds,
  ) async {
    final ids = vehicleIds.toSet().toList(growable: false);
    await alertProjector?.rebuild(database, ids);
    await geofenceProjector?.rebuild(database, ids);
    await tripProjector?.rebuild(database, ids);
  }
}
