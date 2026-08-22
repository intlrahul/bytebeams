import 'dart:async';

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
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given_commit_before_initial_read_when_bloc_started_then_reads_once_without_loading_race', () async {
    final events = AsyncAppEventBus();
    final repository = _Repository();
    final bloc = VehicleDetailBloc(
      vehicleId: 'vehicle-1',
      getVehicleDetail: GetVehicleDetail(
        repository: repository,
        clock: const _Clock(),
      ),
      eventBus: events,
    );

    events.publish(const FleetDataCommitted());
    await Future<void>.delayed(Duration.zero);

    expect(repository.calls, 0);
    bloc.add(const VehicleDetailStarted());
    final loaded = await bloc.stream.firstWhere(
      (state) => state.detail != null,
    );

    expect(loaded.isLoading, isFalse);
    expect(repository.calls, 1);
    await bloc.close();
    await events.close();
  });

  test('given_loaded_detail_when_data_commits_then_refreshes_without_loading_screen', () async {
    final events = AsyncAppEventBus();
    final repository = _Repository();
    final bloc = VehicleDetailBloc(
      vehicleId: 'vehicle-1',
      getVehicleDetail: GetVehicleDetail(
        repository: repository,
        clock: const _Clock(),
      ),
      eventBus: events,
    );

    bloc.add(const VehicleDetailStarted());
    await bloc.stream.firstWhere((state) => state.detail != null);
    events.publish(const FleetDataCommitted());
    final refreshed = await bloc.stream.firstWhere(
      (_) => repository.calls == 2,
    );

    expect(refreshed.detail, isNotNull);
    expect(refreshed.isLoading, isFalse);
    await bloc.close();
    await events.close();
  });

  test('given_detail_read_failure_when_started_then_exposes_failure', () async {
    final events = AsyncAppEventBus();
    final repository = _Repository(
      result: const Result.failure(VehicleDetailFailure.notFound()),
    );
    final bloc = VehicleDetailBloc(
      vehicleId: 'vehicle-1',
      getVehicleDetail: GetVehicleDetail(
        repository: repository,
        clock: const _Clock(),
      ),
      eventBus: events,
    );

    bloc.add(const VehicleDetailStarted());
    final failed = await bloc.stream.firstWhere(
      (state) => state.failure != null,
    );

    expect(failed.isLoading, isFalse);
    expect(failed.failure, isA<VehicleDetailNotFound>());
    await bloc.close();
    await events.close();
  });

  test('given_alert_read_failure_when_detail_loaded_then_preserves_existing_alerts', () async {
    final events = AsyncAppEventBus();
    final alerts = _AlertRepository()
      ..getResult = const Result.failure(AlertFailure.persistenceUnavailable());
    final bloc = _bloc(events: events, alerts: alerts);

    bloc.add(const VehicleDetailStarted());
    final loaded = await bloc.stream.firstWhere(
      (state) => state.detail != null,
    );

    expect(loaded.alerts, isEmpty);
    expect(alerts.getCalls, 1);
    await bloc.close();
    await events.close();
  });

  test('given_alert_dismissal_succeeds_when_requested_then_publishes_and_refreshes', () async {
    final events = AsyncAppEventBus();
    final published = <AppEvent>[];
    final subscription = events.events.listen(published.add);
    final alerts = _AlertRepository();
    final detailRepository = _Repository();
    final bloc = _bloc(
      events: events,
      alerts: alerts,
      detailRepository: detailRepository,
    );
    bloc.add(const VehicleDetailStarted());
    await bloc.stream.firstWhere((state) => state.detail != null);

    final refreshed = bloc.stream.firstWhere(
      (_) => detailRepository.calls >= 2,
    );
    bloc.add(
      const VehicleDetailAlertDismissRequested(
        'alert-1',
        AlertDismissalReason.wrongAlert,
      ),
    );
    await refreshed;

    expect(alerts.dismissCalls, 1);
    expect(alerts.lastReason, AlertDismissalReason.wrongAlert);
    expect(published.whereType<AlertStateChanged>(), hasLength(1));
    await bloc.close();
    await subscription.cancel();
    await events.close();
  });

  test(
    'given_alert_actions_fail_when_requested_then_does_not_publish_or_refresh',
    () async {
      final events = AsyncAppEventBus();
      final published = <AppEvent>[];
      final subscription = events.events.listen(published.add);
      final alerts = _AlertRepository()
        ..dismissResult = const Result.failure(AlertFailure.notFound())
        ..undoResult = const Result.failure(AlertFailure.undoExpired());
      final detailRepository = _Repository();
      final bloc = _bloc(
        events: events,
        alerts: alerts,
        detailRepository: detailRepository,
      );
      bloc.add(const VehicleDetailStarted());
      await bloc.stream.firstWhere((state) => state.detail != null);

      bloc
        ..add(
          const VehicleDetailAlertDismissRequested(
            'alert-1',
            AlertDismissalReason.iAmOnIt,
          ),
        )
        ..add(const VehicleDetailAlertUndoRequested('alert-1'));
      await alerts.dismissCalled.future;
      await alerts.undoCalled.future;

      expect(alerts.dismissCalls, 1);
      expect(alerts.undoCalls, 1);
      expect(detailRepository.calls, 1);
      expect(published.whereType<AlertStateChanged>(), isEmpty);
      await bloc.close();
      await subscription.cancel();
      await events.close();
    },
  );
}

VehicleDetailBloc _bloc({
  required AsyncAppEventBus events,
  required _AlertRepository alerts,
  _Repository? detailRepository,
}) => VehicleDetailBloc(
  vehicleId: 'vehicle-1',
  getVehicleDetail: GetVehicleDetail(
    repository: detailRepository ?? _Repository(),
    clock: const _Clock(),
  ),
  getVehicleAlerts: GetVehicleAlerts(repository: alerts, clock: const _Clock()),
  dismissAlert: DismissAlert(repository: alerts, clock: const _Clock()),
  undoAlertDismissal: UndoAlertDismissal(
    repository: alerts,
    clock: const _Clock(),
  ),
  eventBus: events,
);

final class _Clock implements Clock {
  const _Clock();

  @override
  DateTime nowUtc() => DateTime.utc(2026, 8, 22, 12);
}

final class _Repository implements VehicleDetailRepository {
  _Repository({this.result});

  final VehicleDetailResult? result;
  var calls = 0;

  @override
  Future<VehicleDetailResult> getVehicleDetail({
    required String vehicleId,
    required DateTime asOfUtc,
  }) async {
    calls += 1;
    if (result case final configured?) return configured;
    return Result.success(
      VehicleDetail(
        vehicleId: vehicleId,
        registrationNumber: 'BB-001',
        model: 'E-Truck',
        asOfUtc: asOfUtc,
        readings: const [],
        socHistory: const [],
      ),
    );
  }
}

final class _AlertRepository implements AlertRepository {
  AlertsResult getResult = const Result.success([]);
  AlertActionResult dismissResult = const Result.success(null);
  AlertActionResult undoResult = const Result.success(null);
  int getCalls = 0;
  int dismissCalls = 0;
  int undoCalls = 0;
  AlertDismissalReason? lastReason;
  final dismissCalled = Completer<void>();
  final undoCalled = Completer<void>();

  @override
  Future<AlertsResult> getActiveForVehicle(
    String vehicleId, {
    required DateTime nowUtc,
  }) async {
    getCalls += 1;
    return getResult;
  }

  @override
  Future<AlertActionResult> dismiss(
    String alertId,
    AlertDismissalReason reason, {
    required DateTime nowUtc,
  }) async {
    dismissCalls += 1;
    lastReason = reason;
    if (!dismissCalled.isCompleted) dismissCalled.complete();
    return dismissResult;
  }

  @override
  Future<AlertActionResult> undoDismissal(
    String alertId, {
    required DateTime nowUtc,
  }) async {
    undoCalls += 1;
    if (!undoCalled.isCompleted) undoCalled.complete();
    return undoResult;
  }
}
