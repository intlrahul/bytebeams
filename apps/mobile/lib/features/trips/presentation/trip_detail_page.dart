import 'package:bytebeams/core/design/sparkee/sparkee_components.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:bytebeams/features/trips/domain/trip_models.dart';
import 'package:bytebeams/features/trips/domain/trip_repository.dart';
import 'package:flutter/material.dart';

final class TripDetailPage extends StatelessWidget {
  const TripDetailPage({
    required this.repository,
    required this.tripId,
    super.key,
  });
  final TripRepository repository;
  final String tripId;
  @override
  Widget build(BuildContext context) => SparkeeAppScaffold(
    title: 'Trip',
    body: FutureBuilder<TripResult>(
      future: repository.getTrips(),
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return const SparkeeLoadingState(label: 'Loading trip');
        }
        if (snapshot.data is! Success<List<Trip>, TripFailure>) {
          return const SparkeeErrorState(message: 'Trip could not be read.');
        }
        final trips =
            (snapshot.data! as Success<List<Trip>, TripFailure>).value;
        final matches = trips.where((trip) => trip.id == tripId);
        if (matches.isEmpty) {
          return const SparkeeEmptyState(
            title: 'Trip unavailable',
            message: 'This trip is no longer retained.',
          );
        }
        final trip = matches.first;
        return ListView(
          children: [
            SparkeeListCard(
              title: Text(trip.registrationNumber),
              subtitle: Text(trip.status.label),
            ),
            SparkeeListCard(
              title: const Text('Route'),
              subtitle: Text(
                '${trip.origin} → ${trip.destination ?? 'Awaiting destination'}',
              ),
            ),
            SparkeeListCard(
              title: const Text('Started'),
              subtitle: Text(trip.startedAtUtc.toIso8601String()),
            ),
            if (trip.completedAtUtc != null)
              SparkeeListCard(
                title: const Text('Completed'),
                subtitle: Text(trip.completedAtUtc!.toIso8601String()),
              ),
          ],
        );
      },
    ),
  );
}
