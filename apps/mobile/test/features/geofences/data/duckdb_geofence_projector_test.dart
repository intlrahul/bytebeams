import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/features/geofences/data/duckdb_geofence_projector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given_confirmed_direct_move_when_rebuilt_then_writes_exit_entry_and_membership', () async {
    final database = _Database();
    await const DuckDbGeofenceProjector().rebuild(database, ['vehicle-1']);
    expect(
      database.executed
          .where(
            (entry) => entry.$1.contains('INSERT INTO geofence_transitions'),
          )
          .length,
      2,
    );
    expect(
      database.executed
          .where(
            (entry) =>
                entry.$1.contains('INSERT INTO vehicle_geofence_memberships'),
          )
          .single
          .$2,
      ['vehicle-1', 'b', 1, '2026-08-22T12:05:00.000Z', 'packet-6'],
    );
  });

  test('given_no_vehicle_ids_when_rebuilt_then_does_not_query', () async {
    final database = _Database();
    await const DuckDbGeofenceProjector().rebuild(database, const []);
    expect(database.queries, isEmpty);
  });

  test('given_same_geofence_new_version_when_rebuilt_then_updates_membership_without_transition', () async {
    final database = _Database(versionChange: true);
    await const DuckDbGeofenceProjector().rebuild(database, ['vehicle-1']);
    expect(
      database.executed.where(
        (entry) => entry.$1.contains('INSERT INTO geofence_transitions'),
      ),
      isEmpty,
    );
    expect(
      database.executed
          .where(
            (entry) =>
                entry.$1.contains('INSERT INTO vehicle_geofence_memberships'),
          )
          .single
          .$2[2],
      2,
    );
  });
}

final class _Database implements AppDatabase {
  _Database({this.versionChange = false});
  final bool versionChange;
  final queries = <String>[];
  final executed = <(String, List<Object?>)>[];
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
    queries.add(sql);
    if (sql.contains('FROM geofence_versions')) {
      if (versionChange) {
        return [
          [
            'a',
            1,
            12.9,
            77.6,
            1000.0,
            true,
            DateTime.utc(2026),
            DateTime.utc(2026, 8, 22, 12, 2),
          ],
          [
            'a',
            2,
            12.9,
            77.6,
            1200.0,
            true,
            DateTime.utc(2026, 8, 22, 12, 2),
            null,
          ],
        ];
      }
      return [
        ['a', 1, 12.9, 77.6, 1000.0, true, DateTime.utc(2026), null],
        ['b', 1, 13.0, 77.7, 500.0, true, DateTime.utc(2026), null],
      ];
    }
    if (sql.contains('FROM telemetry_events')) {
      if (versionChange) {
        return [
          _location('packet-1', DateTime.utc(2026, 8, 22, 12), 12.9, 77.6),
          _location('packet-2', DateTime.utc(2026, 8, 22, 12, 1), 12.9, 77.6),
          _location('packet-3', DateTime.utc(2026, 8, 22, 12, 2), 12.9, 77.6),
        ];
      }
      return [
        _location('packet-1', DateTime.utc(2026, 8, 22, 12), 12.9, 77.6),
        _location('packet-2', DateTime.utc(2026, 8, 22, 12, 1), 12.9, 77.6),
        _location('packet-3', DateTime.utc(2026, 8, 22, 12, 2), 13.0, 77.7),
        _location('packet-4', DateTime.utc(2026, 8, 22, 12, 3), 13.0, 77.7),
        _location('packet-5', DateTime.utc(2026, 8, 22, 12, 4), 13.0, 77.7),
        _location('packet-6', DateTime.utc(2026, 8, 22, 12, 5), 13.0, 77.7),
      ];
    }
    return const [];
  }

  List<Object?> _location(
    String packetId,
    DateTime at,
    double latitude,
    double longitude,
  ) => ['vehicle-1', packetId, at, latitude, longitude, 10.0];
}
