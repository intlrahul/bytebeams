import 'package:bytebeams/core/design/sparkee/sparkee_components.dart';
import 'package:bytebeams/core/design/sparkee/sparkee_semantics.dart';
import 'package:bytebeams/core/design/sparkee/sparkee_spacing.dart';
import 'package:flutter/material.dart';

/// Temporary internal visual-verification surface for Sparkee primitives.
final class SparkeeCataloguePage extends StatelessWidget {
  const SparkeeCataloguePage({super.key});
  @override
  Widget build(BuildContext context) => SparkeeAppScaffold(
    title: 'Sparkee catalogue',
    body: ListView(
      padding: const EdgeInsets.all(SparkeeSpacing.md),
      children: [
        const Text('Vehicle status'),
        Wrap(
          spacing: SparkeeSpacing.xs,
          children: SparkeeStatus.values
              .map((status) => SparkeeStatusChip(status: status))
              .toList(),
        ),
        const SizedBox(height: SparkeeSpacing.lg),
        const Row(
          children: [
            SparkeeMetric(label: 'Battery', value: '78', unit: '%'),
            SizedBox(width: SparkeeSpacing.lg),
            SparkeeMetric(label: 'Range', value: '242', unit: 'km'),
            SizedBox(width: SparkeeSpacing.lg),
            SparkeeAlertBadge(count: 2),
          ],
        ),
        const SizedBox(height: SparkeeSpacing.lg),
        const SizedBox(height: 96, child: SparkeeLoadingState()),
        const SparkeeEmptyState(
          title: 'No vehicles match this filter',
          message: 'Try another fleet status.',
        ),
        const SparkeeErrorState(message: 'Fleet data could not be refreshed.'),
      ],
    ),
  );
}
