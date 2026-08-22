import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/core/data/database/database_failure.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:bytebeams/features/trips/data/duckdb_trip_repository.dart';
import 'package:bytebeams/features/trips/domain/trip_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given_persisted_trip_when_read_then_maps_completed_trip', () async {
    final result = await DuckDbTripRepository(_Database()).getTrips();
    final trip = (result as Success<List<Trip>, TripFailure>).value.single;
    expect(trip.destination, 'Depot');
    expect(trip.status, TripStatus.completed);
  });

  test('given_database_failure_when_read_then_returns_typed_failure', () async {
    final result = await DuckDbTripRepository(_Database(fails: true))
        .getTrips();

    expect(result, isA<Failure<List<Trip>, TripFailure>>());
    expect(
      (result as Failure<List<Trip>, TripFailure>).failure,
      isA<TripPersistenceUnavailable>(),
    );
  });
}

final class _Database implements AppDatabase {
  _Database({this.fails = false});
  final bool fails;
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
  Future<T> transaction<T>(
    Future<T> Function(DatabaseTransaction transaction) action,
  ) => action(this);
  @override
  Future<List<List<Object?>>> query(
    String sql, {
    List<Object?> parameters = const [],
  }) async {
    if (fails) {
      throw const DatabaseOperationFailure(safeMessage: 'Unavailable');
    }
    return [
      [
        'trip-1',
        'vehicle-1',
        'BB-1',
        'Hub',
        'Depot',
        DateTime.utc(2026),
        DateTime.utc(2026, 1, 1, 1),
        'completed',
      ],
    ];
  }
}
