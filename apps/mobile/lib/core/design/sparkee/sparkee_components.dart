import 'package:bytebeams/core/design/sparkee/sparkee_color_tokens.dart';
import 'package:bytebeams/core/design/sparkee/sparkee_radius.dart';
import 'package:bytebeams/core/design/sparkee/sparkee_semantics.dart';
import 'package:bytebeams/core/design/sparkee/sparkee_spacing.dart';
import 'package:bytebeams/core/design/sparkee/sparkee_typography.dart';
import 'package:flutter/material.dart';

final class SparkeeAppScaffold extends StatelessWidget {
  const SparkeeAppScaffold({
    required this.title,
    required this.body,
    super.key,
  });
  final String title;
  final Widget body;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: body,
  );
}

final class SparkeeStatusChip extends StatelessWidget {
  const SparkeeStatusChip({required this.status, super.key});
  final SparkeeStatus status;
  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      SparkeeStatus.normal => SparkeeColors.normal,
      SparkeeStatus.warning => SparkeeColors.warning,
      SparkeeStatus.critical => SparkeeColors.critical,
      SparkeeStatus.offline => SparkeeColors.offline,
      SparkeeStatus.stale => SparkeeColors.stale,
    };
    return Semantics(
      label: 'Vehicle status: ${status.label}',
      child: Chip(
        avatar: Icon(status.icon, color: color, size: 18),
        label: Text(status.label),
        labelStyle: TextStyle(color: color),
        backgroundColor: SparkeeColors.surfaceSubtle,
      ),
    );
  }
}

final class SparkeeAlertBadge extends StatelessWidget {
  const SparkeeAlertBadge({required this.count, super.key});
  final int count;
  @override
  Widget build(BuildContext context) => Semantics(
    label: '$count active alerts',
    child: Container(
      constraints: const BoxConstraints(minHeight: 24, minWidth: 24),
      padding: const EdgeInsets.symmetric(horizontal: SparkeeSpacing.xs),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: SparkeeColors.critical,
        borderRadius: SparkeeRadius.large,
      ),
      child: Text(
        '$count',
        style: Theme.of(context).textTheme.labelMedium!
            .copyWith(color: SparkeeColors.onPrimary),
      ),
    ),
  );
}

final class SparkeeMetric extends StatelessWidget {
  const SparkeeMetric({
    required this.label,
    required this.value,
    required this.unit,
    super.key,
  });
  final String label;
  final String value;
  final String unit;
  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label: $value $unit',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium!
              .copyWith(color: SparkeeColors.textSecondary),
        ),
        const SizedBox(height: SparkeeSpacing.xxs),
        Text('$value $unit', style: SparkeeTypography.metric(context)),
      ],
    ),
  );
}

final class SparkeeLoadingState extends StatelessWidget {
  const SparkeeLoadingState({this.label = 'Loading fleet data', super.key});
  final String label;
  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    child: const Center(child: CircularProgressIndicator()),
  );
}

final class SparkeeEmptyState extends StatelessWidget {
  const SparkeeEmptyState({
    required this.title,
    required this.message,
    super.key,
  });
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) =>
      _StateBody(icon: Icons.inbox_outlined, title: title, message: message);
}

final class SparkeeErrorState extends StatelessWidget {
  const SparkeeErrorState({required this.message, super.key});
  final String message;
  @override
  Widget build(BuildContext context) => _StateBody(
    icon: Icons.error_outline,
    title: 'Something needs attention',
    message: message,
  );
}

final class _StateBody extends StatelessWidget {
  const _StateBody({
    required this.icon,
    required this.title,
    required this.message,
  });
  final IconData icon;
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(SparkeeSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: SparkeeColors.textSecondary),
          const SizedBox(height: SparkeeSpacing.sm),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: SparkeeSpacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    ),
  );
}
