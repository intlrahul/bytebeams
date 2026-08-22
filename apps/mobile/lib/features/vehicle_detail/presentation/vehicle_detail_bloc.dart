import 'dart:async';

import 'package:bytebeams/features/alerts/domain/alert_models.dart';
import 'package:bytebeams/features/alerts/domain/alert_use_cases.dart';
import 'package:bytebeams/features/sync/domain/app_event_bus.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:bytebeams/features/vehicle_detail/domain/get_vehicle_detail.dart';
import 'package:bytebeams/features/vehicle_detail/domain/vehicle_detail_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class VehicleDetailEvent {
  const VehicleDetailEvent();
}

final class VehicleDetailStarted extends VehicleDetailEvent {
  const VehicleDetailStarted();
}

final class VehicleDetailDataCommitted extends VehicleDetailEvent {
  const VehicleDetailDataCommitted();
}

final class VehicleDetailAlertDismissRequested extends VehicleDetailEvent {
  const VehicleDetailAlertDismissRequested(this.alertId, this.reason);
  final String alertId;
  final AlertDismissalReason reason;
}

final class VehicleDetailAlertUndoRequested extends VehicleDetailEvent {
  const VehicleDetailAlertUndoRequested(this.alertId);
  final String alertId;
}

final class VehicleDetailState {
  const VehicleDetailState({
    this.detail,
    this.alerts = const [],
    this.isLoading = false,
    this.failure,
  });

  final VehicleDetail? detail;
  final List<VehicleAlert> alerts;
  final bool isLoading;
  final VehicleDetailFailure? failure;

  VehicleDetailState copyWith({
    VehicleDetail? detail,
    List<VehicleAlert>? alerts,
    bool? isLoading,
    VehicleDetailFailure? failure,
    bool clearFailure = false,
  }) => VehicleDetailState(
    detail: detail ?? this.detail,
    alerts: alerts ?? this.alerts,
    isLoading: isLoading ?? this.isLoading,
    failure: clearFailure ? null : (failure ?? this.failure),
  );
}

final class VehicleDetailBloc
    extends Bloc<VehicleDetailEvent, VehicleDetailState> {
  VehicleDetailBloc({
    required this.vehicleId,
    required this.getVehicleDetail,
    this.getVehicleAlerts,
    this.dismissAlert,
    this.undoAlertDismissal,
    required AppEventBus eventBus,
  }) : _eventBus = eventBus,
       super(const VehicleDetailState()) {
    on<VehicleDetailStarted>(_onRefresh);
    on<VehicleDetailDataCommitted>(_onDataCommitted);
    on<VehicleDetailAlertDismissRequested>(_onDismissAlert);
    on<VehicleDetailAlertUndoRequested>(_onUndoAlert);
    _eventSubscription = eventBus.events
        .where(
          (event) => event is FleetDataCommitted || event is AlertStateChanged,
        )
        .listen((_) => add(const VehicleDetailDataCommitted()));
  }

  final String vehicleId;
  final GetVehicleDetail getVehicleDetail;
  final GetVehicleAlerts? getVehicleAlerts;
  final DismissAlert? dismissAlert;
  final UndoAlertDismissal? undoAlertDismissal;
  final AppEventBus _eventBus;
  late final StreamSubscription<AppEvent> _eventSubscription;

  Future<void> _onDataCommitted(
    VehicleDetailDataCommitted event,
    Emitter<VehicleDetailState> emit,
  ) async {
    // The first detail read must be from local DuckDB. A commit that races
    // route creation must not replace that initial read with a loading state.
    if (state.detail == null) return;
    await _onRefresh(event, emit);
  }

  Future<void> _onRefresh(
    VehicleDetailEvent event,
    Emitter<VehicleDetailState> emit,
  ) async {
    if (state.detail == null) {
      emit(state.copyWith(isLoading: true, clearFailure: true));
    }
    final result = await getVehicleDetail(vehicleId);
    switch (result) {
      case Success<VehicleDetail, VehicleDetailFailure>(value: final detail):
        final alerts = getVehicleAlerts == null
            ? state.alerts
            : await _loadAlerts();
        emit(
          state.copyWith(
            detail: detail,
            alerts: alerts,
            isLoading: false,
            clearFailure: true,
          ),
        );
      case Failure<VehicleDetail, VehicleDetailFailure>(failure: final failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  Future<List<VehicleAlert>> _loadAlerts() async {
    final result = await getVehicleAlerts!(vehicleId);
    return switch (result) {
      Success<List<VehicleAlert>, AlertFailure>(value: final alerts) => alerts,
      Failure<List<VehicleAlert>, AlertFailure>() => state.alerts,
    };
  }

  Future<void> _onDismissAlert(
    VehicleDetailAlertDismissRequested event,
    Emitter<VehicleDetailState> emit,
  ) async {
    if (dismissAlert == null) return;
    final result = await dismissAlert!(event.alertId, event.reason);
    if (result case Success<void, AlertFailure>()) {
      _eventBus.publish(const AlertStateChanged());
      await _onRefresh(event, emit);
    }
  }

  Future<void> _onUndoAlert(
    VehicleDetailAlertUndoRequested event,
    Emitter<VehicleDetailState> emit,
  ) async {
    if (undoAlertDismissal == null) return;
    final result = await undoAlertDismissal!(event.alertId);
    if (result case Success<void, AlertFailure>()) {
      _eventBus.publish(const AlertStateChanged());
      await _onRefresh(event, emit);
    }
  }

  @override
  Future<void> close() async {
    await _eventSubscription.cancel();
    return super.close();
  }
}
