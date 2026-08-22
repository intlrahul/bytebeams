import 'package:bytebeams/core/design/sparkee/sparkee_components.dart';
import 'package:bytebeams/core/design/sparkee/sparkee_semantics.dart';
import 'package:bytebeams/core/design/sparkee/sparkee_spacing.dart';
import 'package:bytebeams/features/fleet_home/domain/fleet_home_models.dart';
import 'package:bytebeams/features/fleet_home/presentation/fleet_home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final class FleetHomePage extends StatelessWidget {
  const FleetHomePage({required this.createBloc, super.key});

  final FleetHomeBloc Function() createBloc;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => createBloc()..add(const FleetHomeStarted()),
    child: const _FleetHomeView(),
  );
}

final class _FleetHomeView extends StatelessWidget {
  const _FleetHomeView();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<FleetHomeBloc, FleetHomeState>(
        builder: (context, state) {
          if (state.snapshot == null && state.isLoading) {
            return const SparkeeAppScaffold(
              title: 'Fleet',
              body: SparkeeLoadingState(label: 'Loading saved fleet data'),
            );
          }
          if (state.snapshot == null && state.failure != null) {
            return const SparkeeAppScaffold(
              title: 'Fleet',
              body: SparkeeErrorState(
                message: 'Saved fleet data could not be read.',
              ),
            );
          }
          final snapshot = state.snapshot;
          if (snapshot == null) {
            return const SparkeeAppScaffold(
              title: 'Fleet',
              body: SparkeeLoadingState(label: 'Preparing fleet data'),
            );
          }
          return SparkeeAppScaffold(
            title: 'Fleet',
            body: Column(
              children: [
                if (state.isSyncing)
                  const SparkeeInlineNotice(label: 'Syncing fleet updates')
                else if (state.degradedFailure != null)
                  const SparkeeInlineNotice(
                    label: 'Showing saved fleet data; sync needs attention',
                  ),
                _FleetFilters(counts: snapshot.counts, selected: state.filter),
                Expanded(
                  child: state.isEmptyFilter
                      ? SparkeeEmptyState(
                          title:
                              'No ${state.filter.label.toLowerCase()} vehicles',
                          message: 'Try another fleet status.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(SparkeeSpacing.md),
                          itemCount: snapshot.rows.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: SparkeeSpacing.sm),
                          itemBuilder: (_, index) =>
                              _FleetRow(row: snapshot.rows[index]),
                        ),
                ),
              ],
            ),
          );
        },
      );
}

final class _FleetFilters extends StatelessWidget {
  const _FleetFilters({required this.counts, required this.selected});

  final FleetFilterCounts counts;
  final FleetFilter selected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.all(SparkeeSpacing.md),
    child: Row(
      children: FleetFilter.values
          .map(
            (filter) => Padding(
              padding: const EdgeInsets.only(right: SparkeeSpacing.xs),
              child: SparkeeFilterChip(
                label: filter.label,
                count: counts.forFilter(filter),
                selected: filter == selected,
                onSelected: (_) => context.read<FleetHomeBloc>().add(
                  FleetHomeFilterSelected(filter),
                ),
              ),
            ),
          )
          .toList(growable: false),
    ),
  );
}

final class _FleetRow extends StatelessWidget {
  const _FleetRow({required this.row});

  final FleetVehicleRow row;

  @override
  Widget build(BuildContext context) => SparkeeFleetRowCard(
    registrationNumber: row.registrationNumber,
    model: row.model,
    status: switch (row.status) {
      FleetStatus.moving => SparkeeFleetStatus.moving,
      FleetStatus.idle => SparkeeFleetStatus.idle,
      FleetStatus.stopped => SparkeeFleetStatus.stopped,
      FleetStatus.offline => SparkeeFleetStatus.offline,
    },
    soc: _displayNumber(row.soc),
    rangeKm: _displayNumber(row.rangeKm),
    attentionCount: row.attentionCount,
  );

  String _displayNumber(double? value) => value == null
      ? '—'
      : value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
}
