import 'package:bytebeams/core/design/sparkee/sparkee_theme.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:bytebeams/features/trips/domain/trip_models.dart';
import 'package:bytebeams/features/trips/domain/trip_repository.dart';
import 'package:bytebeams/features/trips/presentation/trips_page.dart';
import 'package:bytebeams/features/trips/presentation/trips_bloc.dart';
import 'package:bytebeams/features/sync/domain/app_event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('given_trip_when_rendered_then_shows_route', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SparkeeTheme.light(),
        home: TripsPage(
          createBloc: () => TripsBloc(
            repository: _Repository(),
            eventBus: AsyncAppEventBus(),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Hub → Depot'), findsOneWidget);
  });

  testWidgets('given_trip_when_tapped_then_opens_its_detail_route', (
    tester,
  ) async {
    final events = AsyncAppEventBus();
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => TripsPage(
            createBloc: () =>
                TripsBloc(repository: _Repository(), eventBus: events),
          ),
        ),
        GoRoute(
          path: '/trips/:id',
          builder: (_, state) => Text('Trip ${state.pathParameters['id']}'),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(theme: SparkeeTheme.light(), routerConfig: router),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('BB-1'));
    await tester.pumpAndSettle();

    expect(find.text('Trip trip-1'), findsOneWidget);
    await events.close();
  });
}

final class _Repository implements TripRepository {
  @override
  Future<TripResult> getTrips({String? vehicleId, TripStatus? status}) async =>
      Result.success([
        Trip(
          id: 'trip-1',
          vehicleId: 'vehicle-1',
          registrationNumber: 'BB-1',
          origin: 'Hub',
          destination: 'Depot',
          startedAtUtc: DateTime.utc(2026),
          completedAtUtc: DateTime.utc(2026, 1, 1, 1),
          status: TripStatus.completed,
        ),
      ]);
}
