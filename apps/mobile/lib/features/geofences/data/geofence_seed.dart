import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/features/geofences/data/duckdb_geofence_projector.dart';

final class GeofenceSeed {
  const GeofenceSeed({required this.projector});
  final GeofenceProjector projector;

  Future<void> ensure(DatabaseTransaction database) async {
    final existing = await database.query('SELECT COUNT(*) FROM geofences');
    if (existing.isNotEmpty && (existing.single.single as num) > 0) return;
    const seeds = [
      ('demo-sarjapur-hub', 'Sarjapur Hub (demo)', 12.9016, 77.6877, 1000.0),
      (
        'demo-electronic-city-depot',
        'Electronic City Depot (demo)',
        12.8456,
        77.6603,
        1000.0,
      ),
      (
        'demo-whitefield-service-yard',
        'Whitefield Service Yard (demo)',
        12.9698,
        77.7499,
        1000.0,
      ),
    ];
    const effectiveFromUtc = '2026-01-01T00:00:00.000Z';
    for (final seed in seeds) {
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
    final vehicles = await database.query(
      'SELECT vehicle_id FROM vehicles ORDER BY vehicle_id ASC',
    );
    await projector.rebuild(
      database,
      vehicles.map((row) => row.single! as String),
    );
  }
}
