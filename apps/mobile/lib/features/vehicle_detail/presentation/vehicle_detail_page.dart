import 'package:bytebeams/core/design/sparkee/sparkee_components.dart';
import 'package:bytebeams/core/design/sparkee/sparkee_color_tokens.dart';
import 'package:bytebeams/core/design/sparkee/sparkee_spacing.dart';
import 'package:bytebeams/features/vehicle_detail/domain/vehicle_detail_models.dart';
import 'package:bytebeams/features/vehicle_detail/presentation/vehicle_detail_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
            const SizedBox(height: SparkeeSpacing.lg),
            Text('Readings', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: SparkeeSpacing.sm),
            ...detail.readings.map(
              (reading) =>
                  _ReadingRow(reading: reading, asOfUtc: detail.asOfUtc),
            ),
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
                (point) => ListTile(
                  title: Text('${_number(point.soc)}%'),
                  trailing: Text(_timestamp(point.eventTimestampUtc)),
                ),
              ),
          ],
        ),
      );
    },
  );
}

final class _ReadingRow extends StatelessWidget {
  const _ReadingRow({required this.reading, required this.asOfUtc});

  final VehicleReading reading;
  final DateTime asOfUtc;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
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
    return Semantics(
      label: 'Reading verdict: ${verdict.name.toUpperCase()}',
      child: Chip(
        label: Text(verdict.name.toUpperCase()),
        labelStyle: TextStyle(color: color),
      ),
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
