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
    this.actions,
    super.key,
  });
  final String title;
  final Widget body;
  final List<Widget>? actions;
  @override
  Widget build(BuildContext context) => ScaffoldMessenger(
    child: Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: body,
    ),
  );
}

abstract final class SparkeeFeedback {
  static SnackBar undo({required VoidCallback onUndo}) => SnackBar(
    content: const Text('Alert dismissed'),
    duration: const Duration(seconds: 5),
    action: SnackBarAction(label: 'UNDO', onPressed: onUndo),
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

final class SparkeeFleetStatusChip extends StatelessWidget {
  const SparkeeFleetStatusChip({required this.status, super.key});

  final SparkeeFleetStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      SparkeeFleetStatus.moving => SparkeeColors.primary,
      SparkeeFleetStatus.idle => SparkeeColors.warning,
      SparkeeFleetStatus.stopped => SparkeeColors.textSecondary,
      SparkeeFleetStatus.offline => SparkeeColors.offline,
    };
    return Semantics(
      label: 'Vehicle state: ${status.label}',
      child: Chip(
        avatar: Icon(status.icon, color: color, size: 18),
        label: Text(status.label),
        labelStyle: TextStyle(color: color),
        backgroundColor: SparkeeColors.surfaceSubtle,
      ),
    );
  }
}

final class SparkeeFilterChip extends StatelessWidget {
  const SparkeeFilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String label;
  final int count;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label filter, $count vehicles',
    button: true,
    selected: selected,
    child: FilterChip(
      label: Text('$label ($count)'),
      selected: selected,
      onSelected: onSelected,
    ),
  );
}

final class SparkeeOptionChip extends StatelessWidget {
  const SparkeeOptionChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label filter',
    button: true,
    selected: selected,
    child: FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
    ),
  );
}

final class SparkeeListCard extends StatelessWidget {
  const SparkeeListCard({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    super.key,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
    ),
  );
}

final class SparkeeTextButton extends StatelessWidget {
  const SparkeeTextButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    button: true,
    child: TextButton(onPressed: onPressed, child: Text(label)),
  );
}

final class SparkeeTextField extends StatelessWidget {
  const SparkeeTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    decoration: InputDecoration(labelText: label),
  );
}

final class SparkeeIconButton extends StatelessWidget {
  const SparkeeIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) =>
      IconButton(icon: Icon(icon), tooltip: tooltip, onPressed: onPressed);
}

final class SparkeeMenuButton<T> extends StatelessWidget {
  const SparkeeMenuButton({
    required this.onSelected,
    required this.itemBuilder,
    super.key,
  });

  final ValueChanged<T> onSelected;
  final PopupMenuItemBuilder<T> itemBuilder;

  @override
  Widget build(BuildContext context) => PopupMenuButton<T>(
    tooltip: 'More actions',
    onSelected: onSelected,
    itemBuilder: itemBuilder,
  );
}

final class SparkeeStatusPill extends StatelessWidget {
  const SparkeeStatusPill({
    required this.label,
    required this.color,
    super.key,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    child: Chip(
      label: Text(label),
      labelStyle: TextStyle(color: color),
      backgroundColor: SparkeeColors.surfaceSubtle,
    ),
  );
}

final class SparkeeFleetRowCard extends StatelessWidget {
  const SparkeeFleetRowCard({
    required this.registrationNumber,
    required this.model,
    required this.status,
    required this.soc,
    required this.rangeKm,
    required this.attentionCount,
    this.onTap,
    super.key,
  });

  final String registrationNumber;
  final String model;
  final SparkeeFleetStatus status;
  final String soc;
  final String rangeKm;
  final int attentionCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    label:
        '$registrationNumber, $model, ${status.label}, battery $soc, range $rangeKm',
    child: Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(SparkeeSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          registrationNumber,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          model,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  SparkeeFleetStatusChip(status: status),
                ],
              ),
              const SizedBox(height: SparkeeSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: SparkeeMetric(label: 'SOC', value: soc, unit: '%'),
                  ),
                  Expanded(
                    child: SparkeeMetric(
                      label: 'Range',
                      value: rangeKm,
                      unit: 'km',
                    ),
                  ),
                  if (attentionCount > 0)
                    SparkeeAlertBadge(count: attentionCount),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
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

final class SparkeeInlineNotice extends StatelessWidget {
  const SparkeeInlineNotice({
    required this.label,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    liveRegion: true,
    child: Padding(
      padding: const EdgeInsets.all(SparkeeSpacing.sm),
      child: Row(
        children: [
          if (isLoading) ...[
            const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: SparkeeSpacing.sm),
          ],
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
        ],
      ),
    ),
  );
}

final class SparkeePrimaryButton extends StatelessWidget {
  const SparkeePrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    button: true,
    child: ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    ),
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
