import 'package:bytebeams/core/design/sparkee/sparkee_theme.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:bytebeams/features/trips/domain/trip_models.dart';
import 'package:bytebeams/features/trips/domain/trip_repository.dart';
import 'package:bytebeams/features/trips/presentation/trip_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'given_completed_trip_when_rendered_then_shows_route_and_completion',
    (tester) async {
      await tester.pumpWidget(_app(_Repository([_completedTrip])));
      await tester.pumpAndSettle();

      expect(find.text('BB-1'), findsOneWidget);
      expect(find.text('Hub → Depot'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    },
  );

  testWidgets(
    'given_in_progress_trip_when_rendered_then_shows_awaiting_destination',
    (tester) async {
      await tester.pumpWidget(_app(_Repository([_inProgressTrip])));
      await tester.pumpAndSettle();

      expect(find.text('Hub → Awaiting destination'), findsOneWidget);
      expect(find.text('Completed'), findsNothing);
    },
  );

  testWidgets(
    'given_unavailable_or_failed_trip_when_rendered_then_shows_safe_state',
    (tester) async {
      await tester.pumpWidget(_app(_Repository(const [])));
      await tester.pumpAndSettle();
      expect(find.text('Trip unavailable'), findsOneWidget);

      await tester.pumpWidget(_app(_Repository.failure()));
      await tester.pumpAndSettle();
      expect(find.text('Trip could not be read.'), findsOneWidget);
    },
  );
}

Widget _app(TripRepository repository) => MaterialApp(
  theme: SparkeeTheme.light(),
  home: TripDetailPage(repository: repository, tripId: 'trip-1'),
);

final _completedTrip = Trip(
  id: 'trip-1',
  vehicleId: 'vehicle-1',
  registrationNumber: 'BB-1',
  origin: 'Hub',
  destination: 'Depot',
  startedAtUtc: DateTime.utc(2026),
  completedAtUtc: DateTime.utc(2026, 1, 1, 1),
  status: TripStatus.completed,
);
final _inProgressTrip = Trip(
  id: 'trip-1',
  vehicleId: 'vehicle-1',
  registrationNumber: 'BB-1',
  origin: 'Hub',
  startedAtUtc: DateTime.utc(2026),
  status: TripStatus.inProgress,
);

final class _Repository implements TripRepository {
  const _Repository(this.trips) : failed = false;
  const _Repository.failure() : trips = const [], failed = true;
  final List<Trip> trips;
  final bool failed;

  @override
  Future<TripResult> getTrips({String? vehicleId, TripStatus? status}) async =>
      failed
      ? const Result.failure(TripPersistenceUnavailable())
      : Result.success(trips);
}
