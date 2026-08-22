import 'package:bytebeams/features/alerts/domain/alert_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given_dismissal_reasons_when_presented_then_keeps_required_order', () {
    expect(AlertDismissalReason.values.map((reason) => reason.label), [
      'I am on it',
      'Wrong alert',
      'Something else...',
    ]);
  });

  test('given_dismissed_alert_when_undo_window_checked_then_uses_wall_clock_expiry', () {
    final alert = VehicleAlert(
      alertId: 'alert-1',
      vehicleId: 'vehicle-1',
      type: AlertType.lowBattery,
      severity: AlertSeverity.warning,
      openedAtUtc: DateTime.utc(2026, 8, 22, 12),
      dismissedAtUtc: DateTime.utc(2026, 8, 22, 12),
      undoExpiresAtUtc: DateTime.utc(2026, 8, 22, 12, 0, 5),
    );

    expect(alert.canUndoAt(DateTime.utc(2026, 8, 22, 12, 0, 4)), isTrue);
    expect(alert.canUndoAt(DateTime.utc(2026, 8, 22, 12, 0, 5)), isFalse);
  });

  test(
    'given_undismissed_or_missing_expiry_when_undo_checked_then_returns_false',
    () {
      final openedAt = DateTime.utc(2026, 8, 22, 12);
      final undismissed = VehicleAlert(
        alertId: 'alert-1',
        vehicleId: 'vehicle-1',
        type: AlertType.lowBattery,
        severity: AlertSeverity.warning,
        openedAtUtc: openedAt,
        undoExpiresAtUtc: openedAt.add(const Duration(seconds: 5)),
      );
      final missingExpiry = VehicleAlert(
        alertId: 'alert-2',
        vehicleId: 'vehicle-1',
        type: AlertType.batteryOverheating,
        severity: AlertSeverity.critical,
        openedAtUtc: openedAt,
        dismissedAtUtc: openedAt,
      );

      expect(undismissed.canUndoAt(openedAt), isFalse);
      expect(missingExpiry.canUndoAt(openedAt), isFalse);
    },
  );

  test(
    'given_alert_failures_when_created_then_exposes_documented_variants',
    () {
      expect(
        const AlertFailure.persistenceUnavailable(),
        isA<AlertPersistenceUnavailable>(),
      );
      expect(const AlertFailure.notFound(), isA<AlertNotFound>());
      expect(const AlertFailure.undoExpired(), isA<AlertUndoExpired>());
    },
  );
}
