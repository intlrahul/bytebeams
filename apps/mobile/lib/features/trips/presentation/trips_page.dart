import 'package:bytebeams/core/design/sparkee/sparkee_components.dart';
import 'package:bytebeams/features/trips/domain/trip_models.dart';
import 'package:bytebeams/features/trips/presentation/trips_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bytebeams/core/design/sparkee/sparkee_spacing.dart';

final class TripsPage extends StatelessWidget {
  const TripsPage({required this.createBloc, this.vehicleId, super.key});
  final TripsBloc Function() createBloc;
  final String? vehicleId;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => createBloc()..add(const TripsStarted()),
    child: const _TripsView(),
  );
}

final class _TripsView extends StatelessWidget {
  const _TripsView();

  @override
  Widget build(BuildContext context) => BlocBuilder<TripsBloc, TripsState>(
    builder: (context, state) => SparkeeAppScaffold(
      title: 'Trips',
      body: state.loading && state.trips.isEmpty
          ? const SparkeeLoadingState(label: 'Loading trips')
          : state.failure != null
          ? const SparkeeErrorState(message: 'Trips could not be read.')
          : Column(
              children: [
                Wrap(
                  spacing: SparkeeSpacing.sm,
                  runSpacing: SparkeeSpacing.xs,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final status in TripStatus.values)
                      SparkeeOptionChip(
                        label: status.label,
                        selected: state.status == status,
                        onSelected: (_) => context.read<TripsBloc>().add(
                          TripsFilterChanged(
                            state.status == status ? null : status,
                          ),
                        ),
                      ),
                  ],
                ),
                Expanded(
                  child: state.trips.isEmpty
                      ? const SparkeeEmptyState(
                          title: 'No trips',
                          message:
                              'Trips appear after a confirmed geofence exit.',
                        )
                      : ListView.builder(
                          itemCount: state.trips.length,
                          itemBuilder: (_, index) {
                            final trip = state.trips[index];
                            return SparkeeListCard(
                              title: Text(trip.registrationNumber),
                              subtitle: Text(
                                '${trip.origin} → ${trip.destination ?? 'Awaiting destination'}',
                              ),
                              trailing: Text(trip.status.label),
                              onTap: () => context.push('/trips/${trip.id}'),
                            );
                          },
                        ),
                ),
              ],
            ),
    ),
  );
}
