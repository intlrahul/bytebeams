import 'dart:async';

import 'package:bytebeams/features/sync/domain/app_event_bus.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:bytebeams/features/trips/domain/trip_models.dart';
import 'package:bytebeams/features/trips/domain/trip_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class TripsEvent {
  const TripsEvent();
}

final class TripsStarted extends TripsEvent {
  const TripsStarted();
}

final class TripsFilterChanged extends TripsEvent {
  const TripsFilterChanged(this.status);
  final TripStatus? status;
}

final class TripsCommitted extends TripsEvent {
  const TripsCommitted();
}

final class TripsState {
  const TripsState({
    this.trips = const [],
    this.status,
    this.loading = false,
    this.failure,
  });
  final List<Trip> trips;
  final TripStatus? status;
  final bool loading;
  final TripFailure? failure;
  TripsState copyWith({
    List<Trip>? trips,
    TripStatus? status,
    bool clearStatus = false,
    bool? loading,
    TripFailure? failure,
    bool clearFailure = false,
  }) => TripsState(
    trips: trips ?? this.trips,
    status: clearStatus ? null : status ?? this.status,
    loading: loading ?? this.loading,
    failure: clearFailure ? null : failure ?? this.failure,
  );
}

final class TripsBloc extends Bloc<TripsEvent, TripsState> {
  TripsBloc({
    required this._repository,
    required AppEventBus eventBus,
    this.vehicleId,
  }) : super(const TripsState()) {
    on<TripsStarted>(_load);
    on<TripsFilterChanged>((event, emit) {
      emit(
        state.copyWith(status: event.status, clearStatus: event.status == null),
      );
      add(const TripsStarted());
    });
    on<TripsCommitted>(_load);
    _subscription = eventBus.events
        .where((event) => event is FleetDataCommitted)
        .listen((_) => add(const TripsCommitted()));
  }
  final TripRepository _repository;
  final String? vehicleId;
  late final StreamSubscription<AppEvent> _subscription;
  Future<void> _load(TripsEvent event, Emitter<TripsState> emit) async {
    emit(state.copyWith(loading: true, clearFailure: true));
    final result = await _repository.getTrips(
      vehicleId: vehicleId,
      status: state.status,
    );
    switch (result) {
      case Success<List<Trip>, TripFailure>(value: final trips):
        emit(state.copyWith(trips: trips, loading: false, clearFailure: true));
      case Failure<List<Trip>, TripFailure>(failure: final failure):
        emit(state.copyWith(loading: false, failure: failure));
    }
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
