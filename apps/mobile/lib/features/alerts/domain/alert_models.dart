import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';

enum AlertType { lowBattery, batteryOverheating }

enum AlertSeverity { warning, critical }

enum AlertDismissalReason { iAmOnIt, wrongAlert, somethingElse }

extension AlertDismissalReasonPresentation on AlertDismissalReason {
  String get label => switch (this) {
    AlertDismissalReason.iAmOnIt => 'I am on it',
    AlertDismissalReason.wrongAlert => 'Wrong alert',
    AlertDismissalReason.somethingElse => 'Something else...',
  };
}

final class VehicleAlert {
  const VehicleAlert({
    required this.alertId,
    required this.vehicleId,
    required this.type,
    required this.severity,
    required this.openedAtUtc,
    this.dismissedAtUtc,
    this.dismissalReason,
    this.undoExpiresAtUtc,
  });
  final String alertId;
  final String vehicleId;
  final AlertType type;
  final AlertSeverity severity;
  final DateTime openedAtUtc;
  final DateTime? dismissedAtUtc;
  final AlertDismissalReason? dismissalReason;
  final DateTime? undoExpiresAtUtc;
  bool get isDismissed => dismissedAtUtc != null;
  bool canUndoAt(DateTime nowUtc) =>
      isDismissed &&
      undoExpiresAtUtc != null &&
      nowUtc.isBefore(undoExpiresAtUtc!);
}

sealed class AlertFailure {
  const AlertFailure();
  const factory AlertFailure.persistenceUnavailable() =
      AlertPersistenceUnavailable;
  const factory AlertFailure.notFound() = AlertNotFound;
  const factory AlertFailure.undoExpired() = AlertUndoExpired;
}

final class AlertPersistenceUnavailable extends AlertFailure {
  const AlertPersistenceUnavailable();
}

final class AlertNotFound extends AlertFailure {
  const AlertNotFound();
}

final class AlertUndoExpired extends AlertFailure {
  const AlertUndoExpired();
}

typedef AlertsResult = Result<List<VehicleAlert>, AlertFailure>;
typedef AlertActionResult = Result<void, AlertFailure>;
