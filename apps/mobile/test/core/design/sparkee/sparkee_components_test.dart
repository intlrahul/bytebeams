import 'package:bytebeams/core/design/sparkee/sparkee_catalogue_page.dart';
import 'package:bytebeams/core/design/sparkee/sparkee_color_tokens.dart';
import 'package:bytebeams/core/design/sparkee/sparkee_components.dart';
import 'package:bytebeams/core/design/sparkee/sparkee_semantics.dart';
import 'package:bytebeams/core/design/sparkee/sparkee_theme.dart';
import 'package:bytebeams/core/design/sparkee/sparkee_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Sparkee theme and tokens', () {
    test(
      'given_light_theme_when_created_then_uses_approved_visual_defaults',
      () {
        final theme = SparkeeTheme.light();

        expect(theme.brightness, Brightness.light);
        expect(theme.useMaterial3, isTrue);
        expect(theme.colorScheme.primary, SparkeeColors.primary);
        expect(theme.colorScheme.surface, SparkeeColors.surface);
        expect(theme.colorScheme.error, SparkeeColors.critical);
        expect(theme.scaffoldBackgroundColor, SparkeeColors.background);
        expect(theme.appBarTheme.backgroundColor, SparkeeColors.surface);
        expect(theme.appBarTheme.foregroundColor, SparkeeColors.textPrimary);
        expect(theme.dividerColor, SparkeeColors.border);
        expect(theme.cardTheme.color, SparkeeColors.surface);
        expect(theme.chipTheme.side?.color, SparkeeColors.border);
      },
    );

    test('given_typography_when_used_then_defines_readable_roles', () {
      final textTheme = SparkeeTypography.textTheme;

      expect(textTheme.headlineSmall?.fontFamily, 'Roboto');
      expect(textTheme.headlineSmall?.fontWeight, FontWeight.w700);
      expect(textTheme.titleMedium?.fontWeight, FontWeight.w600);
      expect(textTheme.bodyMedium?.height, 1.4);
      expect(textTheme.labelMedium?.fontSize, 12);
    });
  });

  group('Sparkee primitives', () {
    for (final status in SparkeeStatus.values) {
      testWidgets(
        'given_${status.name}_status_when_rendered_then_exposes_its_presentation',
        (tester) async {
          final semantics = tester.ensureSemantics();
          try {
            await tester.pumpWidget(_app(SparkeeStatusChip(status: status)));

            expect(find.text(status.label), findsOneWidget);
            expect(find.byIcon(status.icon), findsOneWidget);
            expect(
              _hasSemanticsLabel(tester, 'Vehicle status: ${status.label}'),
              isTrue,
            );
            expect(
              tester.widget<Icon>(find.byIcon(status.icon)).color,
              _statusColor(status),
            );
          } finally {
            semantics.dispose();
          }
        },
      );
    }

    for (final count in [0, 2, 120]) {
      testWidgets(
        'given_alert_badge_with_${count}_alerts_when_rendered_then_exposes_count',
        (tester) async {
          final semantics = tester.ensureSemantics();
          try {
            await tester.pumpWidget(_app(SparkeeAlertBadge(count: count)));

            expect(find.text(count.toString()), findsOneWidget);
            expect(_hasSemanticsLabel(tester, '$count active alerts'), isTrue);
          } finally {
            semantics.dispose();
          }
        },
      );
    }

    testWidgets(
      'given_metric_when_rendered_then_exposes_label_value_unit_and_tabular_text',
      (tester) async {
        final semantics = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            _app(const SparkeeMetric(label: 'Battery', value: '78', unit: '%')),
          );

          expect(find.text('Battery'), findsOneWidget);
          expect(find.text('78 %'), findsOneWidget);
          expect(_hasSemanticsLabel(tester, 'Battery: 78 %'), isTrue);
          final value = tester.widget<Text>(find.text('78 %'));
          expect(value.style?.fontFeatures, const [
            FontFeature.tabularFigures(),
          ]);
        } finally {
          semantics.dispose();
        }
      },
    );

    testWidgets(
      'given_loading_state_when_rendered_then_exposes_progress_and_label',
      (tester) async {
        final semantics = tester.ensureSemantics();
        try {
          await tester.pumpWidget(_app(const SparkeeLoadingState()));

          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          expect(_hasSemanticsLabel(tester, 'Loading fleet data'), isTrue);
        } finally {
          semantics.dispose();
        }
      },
    );

    testWidgets('given_empty_state_when_rendered_then_shows_guidance', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const SparkeeEmptyState(
            title: 'No vehicles',
            message: 'Change the selected filter.',
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      expect(find.text('No vehicles'), findsOneWidget);
      expect(find.text('Change the selected filter.'), findsOneWidget);
    });

    testWidgets('given_error_state_when_rendered_then_shows_recovery_context', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const SparkeeErrorState(message: 'Refresh the fleet data.')),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Something needs attention'), findsOneWidget);
      expect(find.text('Refresh the fleet data.'), findsOneWidget);
    });

    testWidgets(
      'given_sparkee_scaffold_when_rendered_then_shows_title_and_body',
      (tester) async {
        await tester.pumpWidget(
          _app(
            const SparkeeAppScaffold(
              title: 'Fleet home',
              body: Text('Fleet body'),
            ),
          ),
        );

        expect(find.text('Fleet home'), findsOneWidget);
        expect(find.text('Fleet body'), findsOneWidget);
      },
    );

    testWidgets(
      'given_fleet_components_when_rendered_then_expose_operational_content',
      (tester) async {
        await tester.pumpWidget(
          _app(
            Column(
              children: [
                SparkeeFilterChip(
                  label: 'Moving',
                  count: 3,
                  selected: true,
                  onSelected: (_) {},
                ),
                const SparkeeFleetRowCard(
                  registrationNumber: 'BB-001',
                  model: 'E-Truck',
                  status: SparkeeFleetStatus.moving,
                  soc: '78',
                  rangeKm: '242',
                  attentionCount: 1,
                ),
              ],
            ),
          ),
        );

        expect(find.text('Moving (3)'), findsOneWidget);
        expect(find.text('BB-001'), findsOneWidget);
        expect(find.text('E-Truck'), findsOneWidget);
        expect(find.text('78 %'), findsOneWidget);
        expect(find.text('242 km'), findsOneWidget);
      },
    );

    for (final status in SparkeeFleetStatus.values) {
      testWidgets(
        'given_${status.name}_fleet_state_when_rendered_then_exposes_text_and_icon',
        (tester) async {
          await tester.pumpWidget(_app(SparkeeFleetStatusChip(status: status)));

          expect(find.text(status.label), findsOneWidget);
          expect(find.byIcon(status.icon), findsOneWidget);
        },
      );
    }

    testWidgets(
      'given_unselected_filter_when_rendered_then_exposes_filter_semantics',
      (tester) async {
        final semantics = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            _app(
              SparkeeFilterChip(
                label: 'Offline',
                count: 4,
                selected: false,
                onSelected: (_) {},
              ),
            ),
          );

          expect(find.text('Offline (4)'), findsOneWidget);
          expect(
            _hasSemanticsLabel(tester, 'Offline filter, 4 vehicles'),
            isTrue,
          );
        } finally {
          semantics.dispose();
        }
      },
    );

    testWidgets(
      'given_zero_attention_when_fleet_row_rendered_then_hides_badge',
      (tester) async {
        await tester.pumpWidget(
          _app(
            const SparkeeFleetRowCard(
              registrationNumber: 'BB-002',
              model: 'E-Truck',
              status: SparkeeFleetStatus.stopped,
              soc: '—',
              rangeKm: '12.5',
              attentionCount: 0,
            ),
          ),
        );

        expect(find.text('— %'), findsOneWidget);
        expect(find.text('12.5 km'), findsOneWidget);
        expect(find.byType(SparkeeAlertBadge), findsNothing);
      },
    );

    testWidgets(
      'given_inline_notice_when_rendered_then_announces_live_update',
      (tester) async {
        final semantics = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            _app(const SparkeeInlineNotice(label: 'Syncing fleet updates')),
          );

          expect(_hasSemanticsLabel(tester, 'Syncing fleet updates'), isTrue);
        } finally {
          semantics.dispose();
        }
      },
    );
  });

  testWidgets('given_catalogue_when_rendered_then_shows_every_core_primitive', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const SparkeeCataloguePage()));

    expect(find.text('Sparkee catalogue'), findsOneWidget);
    for (final status in SparkeeStatus.values) {
      expect(find.text(status.label), findsOneWidget);
    }
    expect(find.text('78 %'), findsOneWidget);
    expect(find.text('242 km'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('No vehicles match this filter'), findsOneWidget);
    expect(find.text('Something needs attention'), findsOneWidget);
  });
}

bool _hasSemanticsLabel(WidgetTester tester, String label) => tester
    .widgetList<Semantics>(find.byType(Semantics))
    .any((widget) => widget.properties.label == label);

Color _statusColor(SparkeeStatus status) => switch (status) {
  SparkeeStatus.normal => SparkeeColors.normal,
  SparkeeStatus.warning => SparkeeColors.warning,
  SparkeeStatus.critical => SparkeeColors.critical,
  SparkeeStatus.offline => SparkeeColors.offline,
  SparkeeStatus.stale => SparkeeColors.stale,
};

Widget _app(Widget child) => MaterialApp(
  theme: SparkeeTheme.light(),
  home: Scaffold(body: child),
);
