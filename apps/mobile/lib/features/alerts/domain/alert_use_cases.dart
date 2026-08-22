import 'package:bytebeams/core/time/clock.dart';
import 'package:bytebeams/features/alerts/domain/alert_models.dart';
import 'package:bytebeams/features/alerts/domain/alert_repository.dart';

final class GetVehicleAlerts {
  const GetVehicleAlerts({required this.repository, required this.clock});
  final AlertRepository repository;
  final Clock clock;
  Future<AlertsResult> call(String vehicleId) =>
      repository.getActiveForVehicle(vehicleId, nowUtc: clock.nowUtc());
}

final class DismissAlert {
  const DismissAlert({required this.repository, required this.clock});
  final AlertRepository repository;
  final Clock clock;
  Future<AlertActionResult> call(String alertId, AlertDismissalReason reason) =>
      repository.dismiss(alertId, reason, nowUtc: clock.nowUtc());
}

final class UndoAlertDismissal {
  const UndoAlertDismissal({required this.repository, required this.clock});
  final AlertRepository repository;
  final Clock clock;
  Future<AlertActionResult> call(String alertId) =>
      repository.undoDismissal(alertId, nowUtc: clock.nowUtc());
}
