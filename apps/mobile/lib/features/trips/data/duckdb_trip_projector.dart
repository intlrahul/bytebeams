import 'package:bytebeams/core/data/database/app_database.dart';

abstract interface class TripProjector {
  Future<void> rebuild(
    DatabaseTransaction database,
    Iterable<String> vehicleIds,
  );
}

final class DuckDbTripProjector implements TripProjector {
  const DuckDbTripProjector();

  @override
  Future<void> rebuild(
    DatabaseTransaction database,
    Iterable<String> vehicleIds,
  ) async {
    final ids = vehicleIds.toSet().toList(growable: false);
    if (ids.isEmpty) return;
    await database.execute(
      'DELETE FROM trips WHERE vehicle_id IN (${List.filled(ids.length, '?').join(', ')})',
      parameters: ids,
    );
    final rows = await database.query(
      _transitions(ids.length),
      parameters: ids,
    );
    final byVehicle = <String, List<List<Object?>>>{};
    for (final row in rows) {
      (byVehicle[row[1]! as String] ??= []).add(row);
    }
    for (final vehicleId in ids) {
      _OpenTrip? active;
      for (final row in byVehicle[vehicleId] ?? const []) {
        final type = row[5]! as String;
        if (type == 'exit' && active == null) {
          active = _OpenTrip.fromRow(row);
        } else if (type == 'entry' && active != null) {
          await _insert(database, active, row);
          active = null;
        }
      }
      if (active != null) await _insert(database, active, null);
    }
  }

  Future<void> _insert(
    DatabaseTransaction database,
    _OpenTrip trip,
    List<Object?>? entry,
  ) => database.execute(
    'INSERT INTO trips (trip_id, vehicle_id, origin_geofence_id, origin_geofence_version, exit_transition_id, started_at_utc, destination_geofence_id, destination_geofence_version, entry_transition_id, completed_at_utc, status, active_vehicle_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    parameters: [
      '${trip.vehicleId}:${trip.transitionId}',
      trip.vehicleId,
      trip.geofenceId,
      trip.version,
      trip.transitionId,
      trip.timestamp,
      entry?[2],
      entry?[3],
      entry?[0],
      entry?[4],
      entry == null ? 'inProgress' : 'completed',
      entry == null ? trip.vehicleId : null,
    ],
  );

  String _transitions(int vehicleCount) =>
      '''
SELECT transition_id, vehicle_id, geofence_id, geofence_version, event_timestamp_utc, transition_type, packet_id
FROM geofence_transitions
WHERE vehicle_id IN (${List.filled(vehicleCount, '?').join(', ')})
ORDER BY event_timestamp_utc ASC, CASE transition_type WHEN 'exit' THEN 0 ELSE 1 END ASC, packet_id ASC, transition_id ASC
''';
}

final class _OpenTrip {
  const _OpenTrip(
    this.transitionId,
    this.vehicleId,
    this.geofenceId,
    this.version,
    this.timestamp,
  );
  factory _OpenTrip.fromRow(List<Object?> row) => _OpenTrip(
    row[0]! as String,
    row[1]! as String,
    row[2]! as String,
    row[3]! as int,
    (row[4]! as DateTime).toIso8601String(),
  );
  final String transitionId;
  final String vehicleId;
  final String geofenceId;
  final int version;
  final String timestamp;
}
