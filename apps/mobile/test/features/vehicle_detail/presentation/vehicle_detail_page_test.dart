import 'package:bytebeams/core/design/sparkee/sparkee_theme.dart';
import 'package:bytebeams/core/time/clock.dart';
import 'package:bytebeams/features/alerts/domain/alert_models.dart';
import 'package:bytebeams/features/alerts/domain/alert_repository.dart';
import 'package:bytebeams/features/alerts/domain/alert_use_cases.dart';
import 'package:bytebeams/features/sync/domain/app_event_bus.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:bytebeams/features/vehicle_detail/domain/get_vehicle_detail.dart';
import 'package:bytebeams/features/vehicle_detail/domain/vehicle_detail_models.dart';
import 'package:bytebeams/features/vehicle_detail/domain/vehicle_detail_repository.dart';
import 'package:bytebeams/features/vehicle_detail/presentation/vehicle_detail_bloc.dart';
import 'package:bytebeams/features/vehicle_detail/presentation/vehicle_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'given_detail_when_rendered_then_shows_readings_verdicts_and_history',
    (tester) async {
      final events = AsyncAppEventBus();
      await tester.pumpWidget(
        MaterialApp(
          theme: SparkeeTheme.light(),
          home: VehicleDetailPage(
            createBloc: () => VehicleDetailBloc(
              vehicleId: 'vehicle-1',
              getVehicleDetail: GetVehicleDetail(
                repository: const _Repository(),
                clock: const _Clock(),
              ),
              eventBus: events,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('BB-001'), findsOneWidget);
      expect(find.text('SOC'), findsOneWidget);
      expect(find.text('ALERT'), findsOneWidget);
      expect(find.text('Range'), findsOneWidget);
      expect(find.text('—'), findsOneWidget);
      expect(find.text('SOC history — last 24 hours'), findsOneWidget);
      await events.close();
    },
  );

  testWidgets(
    'given_active_alert_when_rendered_then_dismissal_reasons_are_ordered',
    (tester) async {
      final events = AsyncAppEventBus();
      final alerts = _Alerts();
      await tester.pumpWidget(
        MaterialApp(
          theme: SparkeeTheme.light(),
          home: VehicleDetailPage(
            createBloc: () => VehicleDetailBloc(
              vehicleId: 'vehicle-1',
              getVehicleDetail: GetVehicleDetail(
                repository: const _Repository(),
                clock: const _Clock(),
              ),
              getVehicleAlerts: GetVehicleAlerts(
                repository: alerts,
                clock: const _Clock(),
              ),
              dismissAlert: DismissAlert(
                repository: alerts,
                clock: const _Clock(),
              ),
              undoAlertDismissal: UndoAlertDismissal(
                repository: alerts,
                clock: const _Clock(),
              ),
              eventBus: events,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Attention'), findsOneWidget);
      expect(find.text('Low battery'), findsOneWidget);
      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();
      expect(find.text('I am on it'), findsOneWidget);
      expect(find.text('Wrong alert'), findsOneWidget);
      expect(find.text('Something else...'), findsOneWidget);
      await tester.tap(find.text('I am on it'));
      await tester.pump();
      expect(find.text('Alert dismissed'), findsOneWidget);
      await events.close();
    },
  );
}

final class _Clock implements Clock {
  const _Clock();
  @override
  DateTime nowUtc() => DateTime.utc(2026, 8, 22, 12);
}

final class _Repository implements VehicleDetailRepository {
  const _Repository();
  @override
  Future<VehicleDetailResult> getVehicleDetail({
    required String vehicleId,
    required DateTime asOfUtc,
  }) async => Result.success(
    VehicleDetail(
      vehicleId: vehicleId,
      registrationNumber: 'BB-001',
      model: 'E-Truck',
      asOfUtc: asOfUtc,
      readings: [
        VehicleReading(
          signal: VehicleReadingSignal.soc,
          value: 10,
          reportedAtUtc: DateTime.utc(2026, 8, 22, 11, 59),
          verdict: VehicleReadingVerdict.alert,
        ),
        const VehicleReading(
          signal: VehicleReadingSignal.range,
          value: null,
          reportedAtUtc: null,
          verdict: null,
        ),
      ],
      socHistory: [
        SocHistoryPoint(
          eventTimestampUtc: DateTime.utc(2026, 8, 22, 11),
          soc: 10,
        ),
      ],
    ),
  );
}

final class _Alerts implements AlertRepository {
  var dismissed = false;
  VehicleAlert get alert => VehicleAlert(
    alertId: 'a1',
    vehicleId: 'vehicle-1',
    type: AlertType.lowBattery,
    severity: AlertSeverity.warning,
    openedAtUtc: DateTime.utc(2026, 8, 22, 11),
  );
  @override
  Future<AlertsResult> getActiveForVehicle(
    String vehicleId, {
    required DateTime nowUtc,
  }) async => Result.success(dismissed ? const <VehicleAlert>[] : [alert]);
  @override
  Future<AlertActionResult> dismiss(
    String alertId,
    AlertDismissalReason reason, {
    required DateTime nowUtc,
  }) async {
    dismissed = true;
    return const Result.success(null);
  }

  @override
  Future<AlertActionResult> undoDismissal(
    String alertId, {
    required DateTime nowUtc,
  }) async {
    dismissed = false;
    return const Result.success(null);
  }
}
