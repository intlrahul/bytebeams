import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/features/geofences/data/duckdb_geofence_projector.dart';
import 'package:bytebeams/features/geofences/data/geofence_seed.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given_three_existing_demo_sites_when_seeded_then_adds_only_two_missing_sites', () async {
    final database = _Database(
      existingIds: const {
        'demo-sarjapur-hub',
        'demo-electronic-city-depot',
        'demo-whitefield-service-yard',
      },
    );
    final projector = _Projector();

    await GeofenceSeed(projector: projector).ensure(database);

    final insertedIds = database.executed
        .where((entry) => entry.$1.startsWith('INSERT INTO geofences'))
        .map((entry) => entry.$2.first)
        .toList();
    expect(insertedIds, [
      'demo-peenya-logistics-hub',
      'demo-yelahanka-charging-yard',
    ]);
    expect(projector.vehicleIds, ['vehicle-001']);
  });

  test('given_all_demo_sites_when_seeded_then_does_not_rebuild', () async {
    final database = _Database(
      existingIds: const {
        'demo-sarjapur-hub',
        'demo-electronic-city-depot',
        'demo-whitefield-service-yard',
        'demo-peenya-logistics-hub',
        'demo-yelahanka-charging-yard',
      },
    );
    final projector = _Projector();

    await GeofenceSeed(projector: projector).ensure(database);

    expect(database.executed, isEmpty);
    expect(projector.vehicleIds, isEmpty);
  });
}

final class _Projector implements GeofenceProjector {
  final vehicleIds = <String>[];

  @override
  Future<void> rebuild(
    DatabaseTransaction database,
    Iterable<String> vehicleIds,
  ) async => this.vehicleIds.addAll(vehicleIds);
}

final class _Database implements AppDatabase {
  _Database({required this.existingIds});
  final Set<String> existingIds;
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
  Future<List<List<Object?>>> query(
    String sql, {
    List<Object?> parameters = const [],
  }) async {
    if (sql.startsWith('SELECT geofence_id')) {
      return existingIds.map((id) => <Object?>[id]).toList();
    }
    if (sql.startsWith('SELECT vehicle_id')) {
      return const [
        <Object?>['vehicle-001'],
      ];
    }
    return const [];
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(DatabaseTransaction transaction) action,
  ) => action(this);
}
