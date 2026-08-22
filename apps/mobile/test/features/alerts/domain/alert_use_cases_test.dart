import 'package:bytebeams/core/time/clock.dart';
import 'package:bytebeams/features/alerts/domain/alert_models.dart';
import 'package:bytebeams/features/alerts/domain/alert_repository.dart';
import 'package:bytebeams/features/alerts/domain/alert_use_cases.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given_alert_commands_when_invoked_then_passes_injected_clock_to_repository', () async {
    final repository = _Repository();
    const clock = _Clock();

    await GetVehicleAlerts(repository: repository, clock: clock)('vehicle-1');
    await DismissAlert(repository: repository, clock: clock)(
      'alert-1',
      AlertDismissalReason.iAmOnIt,
    );
    await UndoAlertDismissal(repository: repository, clock: clock)('alert-1');

    expect(repository.times, everyElement(DateTime.utc(2026, 8, 22, 12)));
    expect(repository.reason, AlertDismissalReason.iAmOnIt);
  });
}

final class _Clock implements Clock {
  const _Clock();
  @override
  DateTime nowUtc() => DateTime.utc(2026, 8, 22, 12);
}

final class _Repository implements AlertRepository {
  final times = <DateTime>[];
  AlertDismissalReason? reason;
  @override
  Future<AlertsResult> getActiveForVehicle(
    String vehicleId, {
    required DateTime nowUtc,
  }) async {
    times.add(nowUtc);
    return const Result.success([]);
  }

  @override
  Future<AlertActionResult> dismiss(
    String alertId,
    AlertDismissalReason reason, {
    required DateTime nowUtc,
  }) async {
    times.add(nowUtc);
    this.reason = reason;
    return const Result.success(null);
  }

  @override
  Future<AlertActionResult> undoDismissal(
    String alertId, {
    required DateTime nowUtc,
  }) async {
    times.add(nowUtc);
    return const Result.success(null);
  }
}
