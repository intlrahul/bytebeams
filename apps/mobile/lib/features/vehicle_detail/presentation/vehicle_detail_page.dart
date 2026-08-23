import 'package:bytebeams/core/design/sparkee/sparkee_components.dart';
import 'package:bytebeams/core/design/sparkee/sparkee_color_tokens.dart';
import 'package:bytebeams/core/design/sparkee/sparkee_spacing.dart';
import 'package:bytebeams/features/alerts/domain/alert_models.dart';
import 'package:bytebeams/features/vehicle_detail/domain/vehicle_detail_models.dart';
import 'package:bytebeams/features/vehicle_detail/presentation/vehicle_detail_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final class VehicleDetailPage extends StatelessWidget {
  const VehicleDetailPage({required this.createBloc, super.key});

  final VehicleDetailBloc Function() createBloc;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => createBloc()..add(const VehicleDetailStarted()),
    child: const _VehicleDetailView(),
  );
}

final class _VehicleDetailView extends StatelessWidget {
  const _VehicleDetailView();

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<VehicleDetailBloc, VehicleDetailState>(
    builder: (context, state) {
      if (state.detail == null && state.isLoading) {
        return const SparkeeAppScaffold(
          title: 'Vehicle',
          body: SparkeeLoadingState(label: 'Loading vehicle readings'),
        );
      }
      if (state.detail == null) {
        return const SparkeeAppScaffold(
          title: 'Vehicle',
          body: SparkeeErrorState(
            message: 'Vehicle details could not be read.',
          ),
        );
      }
      final detail = state.detail!;
      return SparkeeAppScaffold(
        title: detail.registrationNumber,
        body: ListView(
          padding: const EdgeInsets.all(SparkeeSpacing.md),
          children: [
            Text(detail.model, style: Theme.of(context).textTheme.titleMedium),
            if (detail.geofenceName != null) ...[
              const SizedBox(height: SparkeeSpacing.xs),
              Text('Current geofence: ${detail.geofenceName}'),
            ],
            const SizedBox(height: SparkeeSpacing.lg),
            if (state.alerts.isNotEmpty) ...[
              Text('Attention', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: SparkeeSpacing.sm),
              ...state.alerts.map(
                (alert) => Builder(
                  builder: (feedbackContext) => _AlertCard(
                    alert: alert,
                    onDismiss: (reason) =>
                        _dismiss(feedbackContext, alert, reason),
                    onUndo: () => context.read<VehicleDetailBloc>().add(
                      VehicleDetailAlertUndoRequested(alert.alertId),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: SparkeeSpacing.lg),
            ],
            Text('Readings', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: SparkeeSpacing.sm),
            ...detail.readings.map(
              (reading) =>
                  _ReadingRow(reading: reading, asOfUtc: detail.asOfUtc),
            ),
            if (detail.recentTrips.isNotEmpty) ...[
              const SizedBox(height: SparkeeSpacing.lg),
              Text(
                'Recent trips',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ...detail.recentTrips.map(
                (trip) => SparkeeListCard(
                  title: Text(
                    '${trip.origin} → ${trip.destination ?? 'Awaiting destination'}',
                  ),
                  subtitle: Text(_timestamp(trip.startedAtUtc)),
                ),
              ),
              if (detail.hasMoreTrips)
                SparkeeTextButton(
                  onPressed: () =>
                      context.push('/trips?vehicleId=${detail.vehicleId}'),
                  label: 'View all trips',
                ),
            ],
            const SizedBox(height: SparkeeSpacing.lg),
            Text(
              'SOC history — last 24 hours',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: SparkeeSpacing.sm),
            if (detail.socHistory.isEmpty)
              const SparkeeEmptyState(
                title: 'No SOC history',
                message:
                    'No valid SOC readings were retained in the last 24 hours.',
              )
            else
              ...detail.socHistory.map(
                (point) => SparkeeListCard(
                  title: Text('${_number(point.soc)}%'),
                  trailing: Text(_timestamp(point.eventTimestampUtc)),
                ),
              ),
          ],
        ),
      );
    },
  );

  Future<void> _dismiss(
    BuildContext context,
    VehicleAlert alert,
    AlertDismissalReason reason,
  ) async {
    context.read<VehicleDetailBloc>().add(
      VehicleDetailAlertDismissRequested(alert.alertId, reason),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SparkeeFeedback.undo(
        onUndo: () => context.read<VehicleDetailBloc>().add(
          VehicleDetailAlertUndoRequested(alert.alertId),
        ),
      ),
    );
  }
}

final class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.alert,
    required this.onDismiss,
    required this.onUndo,
  });
  final VehicleAlert alert;
  final ValueChanged<AlertDismissalReason> onDismiss;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) => SparkeeListCard(
    leading: Icon(
      alert.severity == AlertSeverity.critical
          ? Icons.error_outline
          : Icons.warning_amber_outlined,
      color: alert.severity == AlertSeverity.critical
          ? SparkeeColors.critical
          : SparkeeColors.warning,
    ),
    title: Text(_alertTitle(alert)),
    subtitle: Text(alert.severity.name.toUpperCase()),
    trailing: alert.isDismissed
        ? SparkeeTextButton(label: 'Undo', onPressed: onUndo)
        : SparkeeTextButton(
            label: 'Dismiss',
            onPressed: () async {
              final reason = await showModalBottomSheet<AlertDismissalReason>(
                context: context,
                builder: (context) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: AlertDismissalReason.values
                        .map(
                          (reason) => SparkeeListCard(
                            title: Text(reason.label),
                            onTap: () => Navigator.pop(context, reason),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              );
              if (reason != null) onDismiss(reason);
            },
          ),
  );
}

String _alertTitle(VehicleAlert alert) => switch (alert.type) {
  AlertType.lowBattery => 'Low battery',
  AlertType.batteryOverheating => 'Battery overheating',
};

final class _ReadingRow extends StatelessWidget {
  const _ReadingRow({required this.reading, required this.asOfUtc});

  final VehicleReading reading;
  final DateTime asOfUtc;

  @override
  Widget build(BuildContext context) => SparkeeListCard(
    title: Text(_label(reading.signal)),
    subtitle: reading.reportedAtUtc == null
        ? null
        : Text('${_age(reading.reportedAtUtc!, asOfUtc)} ago'),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_value(reading), style: Theme.of(context).textTheme.titleMedium),
        if (reading.verdict != null) ...[
          const SizedBox(width: SparkeeSpacing.sm),
          _VerdictPill(verdict: reading.verdict!),
        ],
      ],
    ),
  );
}

final class _VerdictPill extends StatelessWidget {
  const _VerdictPill({required this.verdict});

  final VehicleReadingVerdict verdict;

  @override
  Widget build(BuildContext context) {
    final color = switch (verdict) {
      VehicleReadingVerdict.normal => SparkeeColors.normal,
      VehicleReadingVerdict.alert => SparkeeColors.warning,
      VehicleReadingVerdict.stale => SparkeeColors.stale,
    };
    return SparkeeStatusPill(
      label: verdict.name[0].toUpperCase() + verdict.name.substring(1),
      color: color,
    );
  }
}

String _label(VehicleReadingSignal signal) => switch (signal) {
  VehicleReadingSignal.soc => 'SOC',
  VehicleReadingSignal.range => 'Range',
  VehicleReadingSignal.speed => 'Speed',
  VehicleReadingSignal.batteryTemp => 'Battery temperature',
  VehicleReadingSignal.odometer => 'Odometer',
  VehicleReadingSignal.lastPing => 'Last ping',
};

String _value(VehicleReading reading) {
  if (!reading.hasReported) return '—';
  if (reading.signal == VehicleReadingSignal.lastPing) {
    return _timestamp(reading.reportedAtUtc!);
  }
  final unit = switch (reading.signal) {
    VehicleReadingSignal.soc => '%',
    VehicleReadingSignal.range || VehicleReadingSignal.odometer => 'km',
    VehicleReadingSignal.speed => 'km/h',
    VehicleReadingSignal.batteryTemp => '°C',
    VehicleReadingSignal.lastPing => '',
  };
  return '${_number(reading.value!)} $unit';
}

String _number(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(1);

String _age(DateTime timestamp, DateTime asOfUtc) {
  final age = asOfUtc.difference(timestamp);
  if (age.inMinutes < 1) return 'just now';
  if (age.inHours < 1) return '${age.inMinutes} min';
  return '${age.inHours} h';
}

String _timestamp(DateTime value) =>
    '${value.toUtc().hour.toString().padLeft(2, '0')}:${value.toUtc().minute.toString().padLeft(2, '0')} UTC';
