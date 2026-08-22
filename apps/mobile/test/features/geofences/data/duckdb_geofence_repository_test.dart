import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/features/geofences/data/duckdb_geofence_projector.dart';
import 'package:bytebeams/features/geofences/data/duckdb_geofence_repository.dart';
import 'package:bytebeams/features/geofences/domain/geofence_models.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:bytebeams/features/trips/data/duckdb_trip_projector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 8, 22, 12);
  test(
    'given_current_versions_when_read_then_maps_persisted_geofences',
    () async {
      final result = await _repository(_Database()).getAll(nowUtc: now);
      expect(
        (result as Success<List<Geofence>, GeofenceFailure>)
            .value
            .single
            .displayName,
        'Demo',
      );
    },
  );
  test('given_valid_draft_when_created_then_persists_version_and_rebuilds_membership', () async {
    final database = _Database();
    final projector = _Projector();
    final result = await DuckDbGeofenceRepository(database, projector).create(
      const GeofenceDraft(
        displayName: 'New',
        latitude: 12.9,
        longitude: 77.6,
        radiusMeters: 50,
      ),
      nowUtc: now,
    );
    expect(result, isA<Success<void, GeofenceFailure>>());
    expect(
      database.executed.where(
        (entry) => entry.$1.contains('INSERT INTO geofences'),
      ),
      hasLength(1),
    );
    expect(projector.calls, [
      ['vehicle-1'],
    ]);
  });
  test('given_invalid_draft_when_created_then_does_not_persist', () async {
    final database = _Database();
    final result = await _repository(database).create(
      const GeofenceDraft(
        displayName: '',
        latitude: 0,
        longitude: 0,
        radiusMeters: 50,
      ),
      nowUtc: now,
    );
    expect(result, isA<Failure<void, GeofenceFailure>>());
    expect(database.executed, isEmpty);
  });
  test(
    'given_existing_geofence_when_deactivated_then_appends_inactive_version',
    () async {
      final database = _Database();
      final result = await _repository(database)
          .deactivate('geo-1', nowUtc: now);
      expect(result, isA<Success<void, GeofenceFailure>>());
      expect(
        database.executed
            .where((entry) => entry.$1.contains('is_active'))
            .last
            .$2[6],
        isFalse,
      );
    },
  );

  test('given_membership_from_prior_version_when_current_geofence_read_then_counts_stable_identity', () async {
    final database = _Database();
    await _repository(database).getAll(nowUtc: now);
    expect(database.lastQuery, contains('m.geofence_id = v.geofence_id'));
    expect(
      database.lastQuery,
      isNot(contains('m.geofence_version = v.version')),
    );
  });
  test('given_membership_when_read_then_maps_optional_geofence_data', () async {
    final membership = await _repository(
      _Database(
        membership: [
          ["Demo", now],
        ],
      ),
    ).membershipForVehicle('vehicle-1');

    expect(membership?.geofenceName, 'Demo');
    expect(membership?.observedAtUtc, now);
  });
  test('given_no_membership_when_read_then_returns_null', () async {
    expect(
      await _repository(_Database(membership: const []))
          .membershipForVehicle('vehicle-1'),
      isNull,
    );
  });
  test(
    'given_trip_projector_when_geofence_created_then_rebuilds_trips',
    () async {
      final database = _Database();
      final trips = _TripProjector();
      await DuckDbGeofenceRepository(
        database,
        _Projector(),
        tripProjector: trips,
      ).create(
        const GeofenceDraft(
          displayName: 'New',
          latitude: 12.9,
          longitude: 77.6,
          radiusMeters: 50,
        ),
        nowUtc: now,
      );

      expect(trips.calls, [
        ['vehicle-1'],
      ]);
    },
  );
}

DuckDbGeofenceRepository _repository(_Database database) =>
    DuckDbGeofenceRepository(database, _Projector());

final class _Projector implements GeofenceProjector {
  final calls = <List<String>>[];
  @override
  Future<void> rebuild(
    DatabaseTransaction database,
    Iterable<String> vehicleIds,
  ) async => calls.add(vehicleIds.toList());
}

final class _TripProjector implements TripProjector {
  final calls = <List<String>>[];

  @override
  Future<void> rebuild(
    DatabaseTransaction database,
    Iterable<String> vehicleIds,
  ) async => calls.add(vehicleIds.toList());
}

final class _Database implements AppDatabase {
  _Database({this.membership});
  final executed = <(String, List<Object?>)>[];
  final List<List<Object?>>? membership;
  String? lastQuery;
  @override
  Future<void> close() async {}
  @override
  Future<int> currentSchemaVersion() async => 5;
  @override
  Future<void> execute(
    String sql, {
    List<Object?> parameters = const [],
  }) async => executed.add((sql, parameters));
  @override
  Future<T> transaction<T>(
    Future<T> Function(DatabaseTransaction transaction) action,
  ) => action(this);
  @override
  Future<List<List<Object?>>> query(
    String sql, {
    List<Object?> parameters = const [],
  }) async {
    lastQuery = sql;
    if (sql.contains('SELECT vehicle_id FROM vehicles')) {
      return const [
        ['vehicle-1'],
      ];
    }
    if (sql.contains('FROM vehicle_geofence_memberships')) {
      return membership ?? const [];
    }
    if (sql.contains('FROM geofence_versions WHERE geofence_id')) {
      return [
        [1, 'Demo', 12.9, 77.6, 100.0],
      ];
    }
    if (sql.contains('FROM geofence_versions v')) {
      return [
        ['geo-1', 1, 'Demo', 12.9, 77.6, 100.0, true, DateTime.utc(2026), 2],
      ];
    }
    return const [];
  }
}
