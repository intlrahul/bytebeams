import 'package:bytebeams/features/alerts/domain/alert_models.dart';

abstract interface class AlertRepository {
  Future<AlertsResult> getActiveForVehicle(
    String vehicleId, {
    required DateTime nowUtc,
  });
  Future<AlertActionResult> dismiss(
    String alertId,
    AlertDismissalReason reason, {
    required DateTime nowUtc,
  });
  Future<AlertActionResult> undoDismissal(
    String alertId, {
    required DateTime nowUtc,
  });
}
