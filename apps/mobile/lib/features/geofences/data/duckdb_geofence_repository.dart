import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/features/geofences/data/duckdb_geofence_projector.dart';
import 'package:bytebeams/features/geofences/domain/geofence_models.dart';
import 'package:bytebeams/features/geofences/domain/geofence_repository.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:bytebeams/features/trips/data/duckdb_trip_projector.dart';

final class DuckDbGeofenceRepository implements GeofenceRepository {
  const DuckDbGeofenceRepository(
    this._database,
    this._projector, {
    this.tripProjector,
  });

  final AppDatabase _database;
  final GeofenceProjector _projector;
  final TripProjector? tripProjector;

  @override
  Future<GeofencesResult> getAll({required DateTime nowUtc}) async {
    try {
      final rows = await _database.query(
        _selectCurrent,
        parameters: [nowUtc.toIso8601String(), nowUtc.toIso8601String()],
      );
      return Result.success(rows.map(_geofence).toList(growable: false));
    } catch (_) {
      return const Result.failure(GeofenceFailure.persistenceUnavailable());
    }
  }

  @override
  Future<GeofenceActionResult> create(
    GeofenceDraft draft, {
    required DateTime nowUtc,
  }) async {
    final validation = draft.validate();
    if (validation != null) return Result.failure(validation);
    try {
      final id =
          'geofence:${nowUtc.microsecondsSinceEpoch}:${draft.displayName.trim()}';
      await _database.transaction((transaction) async {
        await transaction.execute(
          'INSERT INTO geofences (geofence_id, created_at_utc) VALUES (?, ?)',
          parameters: [id, nowUtc.toIso8601String()],
        );
        await _insertVersion(
          transaction,
          id,
          1,
          draft,
          isActive: true,
          nowUtc: nowUtc,
        );
        await _rebuildAllMemberships(transaction);
      });
      return const Result.success(null);
    } catch (_) {
      return const Result.failure(GeofenceFailure.persistenceUnavailable());
    }
  }

  @override
  Future<GeofenceActionResult> edit(
    String id,
    GeofenceDraft draft, {
    required DateTime nowUtc,
  }) => _replaceCurrent(id, draft, isActive: true, nowUtc: nowUtc);

  @override
  Future<GeofenceActionResult> deactivate(
    String id, {
    required DateTime nowUtc,
  }) async {
    try {
      final current = await _currentVersion(id);
      if (current == null) {
        return const Result.failure(GeofenceFailure.notFound());
      }
      await _database.transaction((transaction) async {
        await transaction.execute(
          'UPDATE geofence_versions SET effective_until_utc = ? WHERE geofence_id = ? AND version = ?',
          parameters: [nowUtc.toIso8601String(), id, current.version],
        );
        await _insertVersion(
          transaction,
          id,
          current.version + 1,
          current.draft,
          isActive: false,
          nowUtc: nowUtc,
        );
        await _rebuildAllMemberships(transaction);
      });
      return const Result.success(null);
    } catch (_) {
      return const Result.failure(GeofenceFailure.persistenceUnavailable());
    }
  }

  @override
  Future<VehicleGeofenceMembership?> membershipForVehicle(
    String vehicleId,
  ) async {
    final rows = await _database.query(
      _selectMembership,
      parameters: [vehicleId],
    );
    if (rows.isEmpty) {
      return null;
    }
    final row = rows.single;
    return VehicleGeofenceMembership(
      vehicleId: vehicleId,
      geofenceName: row[0] as String?,
      observedAtUtc: row[1] as DateTime?,
    );
  }

  Future<GeofenceActionResult> _replaceCurrent(
    String id,
    GeofenceDraft draft, {
    required bool isActive,
    required DateTime nowUtc,
  }) async {
    final validation = draft.validate();
    if (validation != null) return Result.failure(validation);
    try {
      final current = await _currentVersion(id);
      if (current == null) {
        return const Result.failure(GeofenceFailure.notFound());
      }
      await _database.transaction((transaction) async {
        await transaction.execute(
          'UPDATE geofence_versions SET effective_until_utc = ? WHERE geofence_id = ? AND version = ?',
          parameters: [nowUtc.toIso8601String(), id, current.version],
        );
        await _insertVersion(
          transaction,
          id,
          current.version + 1,
          draft,
          isActive: isActive,
          nowUtc: nowUtc,
        );
        await _rebuildAllMemberships(transaction);
      });
      return const Result.success(null);
    } catch (_) {
      return const Result.failure(GeofenceFailure.persistenceUnavailable());
    }
  }

  Future<_CurrentVersion?> _currentVersion(String id) async {
    final rows = await _database.query(_selectLatestVersion, parameters: [id]);
    if (rows.isEmpty) return null;
    final row = rows.single;
    return _CurrentVersion(
      version: row[0]! as int,
      draft: GeofenceDraft(
        displayName: row[1]! as String,
        latitude: (row[2]! as num).toDouble(),
        longitude: (row[3]! as num).toDouble(),
        radiusMeters: (row[4]! as num).toDouble(),
      ),
    );
  }

  Future<void> _insertVersion(
    DatabaseTransaction transaction,
    String id,
    int version,
    GeofenceDraft draft, {
    required bool isActive,
    required DateTime nowUtc,
  }) => transaction.execute(
    'INSERT INTO geofence_versions (geofence_id, version, display_name, latitude, longitude, radius_meters, is_active, effective_from_utc, effective_until_utc) VALUES (?, ?, ?, ?, ?, ?, ?, ?, NULL)',
    parameters: [
      id,
      version,
      draft.displayName,
      draft.latitude,
      draft.longitude,
      draft.radiusMeters,
      isActive,
      nowUtc.toIso8601String(),
    ],
  );

  Future<void> _rebuildAllMemberships(DatabaseTransaction transaction) async {
    final rows = await transaction.query(
      'SELECT vehicle_id FROM vehicles ORDER BY vehicle_id ASC',
    );
    await _projector.rebuild(
      transaction,
      rows.map((row) => row.single! as String),
    );
    await tripProjector?.rebuild(
      transaction,
      rows.map((row) => row.single! as String),
    );
  }

  Geofence _geofence(List<Object?> row) => Geofence(
    id: row[0]! as String,
    version: row[1]! as int,
    displayName: row[2]! as String,
    latitude: (row[3]! as num).toDouble(),
    longitude: (row[4]! as num).toDouble(),
    radiusMeters: (row[5]! as num).toDouble(),
    isActive: row[6]! as bool,
    effectiveFromUtc: row[7]! as DateTime,
    vehicleCount: row[8]! as int,
  );

  static const _selectCurrent = '''
SELECT v.geofence_id, v.version, v.display_name, v.latitude, v.longitude, v.radius_meters,
       v.is_active, v.effective_from_utc, COUNT(m.vehicle_id) AS vehicle_count
FROM geofence_versions v
LEFT JOIN vehicle_geofence_memberships m
  ON m.geofence_id = v.geofence_id AND v.is_active
WHERE v.effective_from_utc <= ?
  AND (v.effective_until_utc IS NULL OR v.effective_until_utc > ?)
GROUP BY v.geofence_id, v.version, v.display_name, v.latitude, v.longitude,
         v.radius_meters, v.is_active, v.effective_from_utc
ORDER BY v.is_active DESC, v.display_name ASC, v.geofence_id ASC
''';
  static const _selectLatestVersion = '''
SELECT version, display_name, latitude, longitude, radius_meters
FROM geofence_versions WHERE geofence_id = ? ORDER BY version DESC LIMIT 1
''';
  static const _selectMembership = '''
SELECT v.display_name, m.observed_at_utc
FROM vehicle_geofence_memberships m
LEFT JOIN geofence_versions v ON v.geofence_id = m.geofence_id
  AND v.effective_until_utc IS NULL AND v.is_active
WHERE m.vehicle_id = ?
''';
}

final class _CurrentVersion {
  const _CurrentVersion({required this.version, required this.draft});
  final int version;
  final GeofenceDraft draft;
}
