import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/core/data/database/database_failure.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:bytebeams/features/trips/domain/trip_models.dart';
import 'package:bytebeams/features/trips/domain/trip_repository.dart';

final class DuckDbTripRepository implements TripRepository {
  const DuckDbTripRepository(this._database);
  final AppDatabase _database;
  @override
  Future<TripResult> getTrips({String? vehicleId, TripStatus? status}) async {
    try {
      final rows = await _database.query(
        _query,
        parameters: [vehicleId, vehicleId, status?.name, status?.name],
      );
      return Result.success(
        rows
            .map(
              (r) => Trip(
                id: r[0]! as String,
                vehicleId: r[1]! as String,
                registrationNumber: r[2]! as String,
                origin: r[3]! as String,
                destination: r[4] as String?,
                startedAtUtc: r[5]! as DateTime,
                completedAtUtc: r[6] as DateTime?,
                status: TripStatus.values.byName(r[7]! as String),
              ),
            )
            .toList(),
      );
    } on DatabaseFailure {
      return const Result.failure(TripPersistenceUnavailable());
    }
  }

  static const _query = '''
SELECT t.trip_id,t.vehicle_id,v.registration_number,ov.display_name,dv.display_name,t.started_at_utc,t.completed_at_utc,t.status
FROM trips t JOIN vehicles v ON v.vehicle_id=t.vehicle_id
JOIN geofence_versions ov ON ov.geofence_id=t.origin_geofence_id AND ov.version=t.origin_geofence_version
LEFT JOIN geofence_versions dv ON dv.geofence_id=t.destination_geofence_id AND dv.version=t.destination_geofence_version
WHERE (? IS NULL OR t.vehicle_id=?) AND (? IS NULL OR t.status=?)
ORDER BY t.started_at_utc DESC,t.trip_id ASC''';
}
