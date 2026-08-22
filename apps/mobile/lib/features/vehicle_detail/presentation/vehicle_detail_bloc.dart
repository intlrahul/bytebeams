import 'dart:async';

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

final class VehicleDetailState {
  const VehicleDetailState({this.detail, this.isLoading = false, this.failure});

  final VehicleDetail? detail;
  final bool isLoading;
  final VehicleDetailFailure? failure;

  VehicleDetailState copyWith({
    VehicleDetail? detail,
    bool? isLoading,
    VehicleDetailFailure? failure,
    bool clearFailure = false,
  }) => VehicleDetailState(
    detail: detail ?? this.detail,
    isLoading: isLoading ?? this.isLoading,
    failure: clearFailure ? null : (failure ?? this.failure),
  );
}

final class VehicleDetailBloc
    extends Bloc<VehicleDetailEvent, VehicleDetailState> {
  VehicleDetailBloc({
    required this.vehicleId,
    required this.getVehicleDetail,
    required AppEventBus eventBus,
  }) : super(const VehicleDetailState()) {
    on<VehicleDetailStarted>(_onRefresh);
    on<VehicleDetailDataCommitted>(_onRefresh);
    _eventSubscription = eventBus.events
        .where((event) => event is FleetDataCommitted)
        .listen((_) => add(const VehicleDetailDataCommitted()));
  }

  final String vehicleId;
  final GetVehicleDetail getVehicleDetail;
  late final StreamSubscription<AppEvent> _eventSubscription;

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
        emit(
          state.copyWith(detail: detail, isLoading: false, clearFailure: true),
        );
      case Failure<VehicleDetail, VehicleDetailFailure>(failure: final failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  @override
  Future<void> close() async {
    await _eventSubscription.cancel();
    return super.close();
  }
}
