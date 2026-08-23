import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/features/geofences/data/duckdb_geofence_projector.dart';

final class GeofenceSeed {
  const GeofenceSeed({required this.projector});
  final GeofenceProjector projector;

  Future<void> ensure(DatabaseTransaction database) async {
    final existing = await database.query(
      'SELECT geofence_id FROM geofences ORDER BY geofence_id ASC',
    );
    final existingIds = existing.map((row) => row.single! as String).toSet();
    const seeds = [
      ('demo-sarjapur-hub', 'Sarjapur Hub', 12.9016, 77.6877, 1000.0),
      (
        'demo-electronic-city-depot',
        'Electronic City Depot',
        12.8456,
        77.6603,
        1000.0,
      ),
      (
        'demo-whitefield-service-yard',
        'Whitefield Service Yard',
        12.9698,
        77.7499,
        1000.0,
      ),
      (
        'demo-peenya-logistics-hub',
        'Peenya Logistics Hub',
        13.0285,
        77.5197,
        1000.0,
      ),
      (
        'demo-yelahanka-charging-yard',
        'Yelahanka Charging Yard',
        13.1007,
        77.5963,
        1000.0,
      ),
    ];
    const effectiveFromUtc = '2026-01-01T00:00:00.000Z';
    var inserted = false;
    for (final seed in seeds) {
      if (existingIds.contains(seed.$1)) continue;
      inserted = true;
      await database.execute(
        'INSERT INTO geofences (geofence_id, created_at_utc) VALUES (?, ?)',
        parameters: [seed.$1, effectiveFromUtc],
      );
      await database.execute(
        'INSERT INTO geofence_versions (geofence_id, version, display_name, latitude, longitude, radius_meters, is_active, effective_from_utc, effective_until_utc) VALUES (?, ?, ?, ?, ?, ?, ?, ?, NULL)',
        parameters: [
          seed.$1,
          1,
          seed.$2,
          seed.$3,
          seed.$4,
          seed.$5,
          true,
          effectiveFromUtc,
        ],
      );
    }
    if (!inserted) return;
    final vehicles = await database.query(
      'SELECT vehicle_id FROM vehicles ORDER BY vehicle_id ASC',
    );
    await projector.rebuild(
      database,
      vehicles.map((row) => row.single! as String),
    );
  }
}
