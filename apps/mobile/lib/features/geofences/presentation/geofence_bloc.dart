import 'dart:async';

import 'package:bytebeams/features/geofences/domain/geofence_models.dart';
import 'package:bytebeams/features/geofences/domain/geofence_use_cases.dart';
import 'package:bytebeams/features/sync/domain/app_event_bus.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class GeofenceEvent {
  const GeofenceEvent();
}

final class GeofencesStarted extends GeofenceEvent {
  const GeofencesStarted();
}

final class GeofencesRefreshRequested extends GeofenceEvent {
  const GeofencesRefreshRequested();
}

final class GeofenceCreated extends GeofenceEvent {
  const GeofenceCreated(this.draft);
  final GeofenceDraft draft;
}

final class GeofenceEdited extends GeofenceEvent {
  const GeofenceEdited(this.id, this.draft);
  final String id;
  final GeofenceDraft draft;
}

final class GeofenceDeactivated extends GeofenceEvent {
  const GeofenceDeactivated(this.id);
  final String id;
}

final class GeofenceState {
  const GeofenceState({
    this.geofences = const [],
    this.isLoading = false,
    this.failure,
  });
  final List<Geofence> geofences;
  final bool isLoading;
  final GeofenceFailure? failure;
  GeofenceState copyWith({
    List<Geofence>? geofences,
    bool? isLoading,
    GeofenceFailure? failure,
    bool clearFailure = false,
  }) => GeofenceState(
    geofences: geofences ?? this.geofences,
    isLoading: isLoading ?? this.isLoading,
    failure: clearFailure ? null : failure ?? this.failure,
  );
}

final class GeofenceBloc extends Bloc<GeofenceEvent, GeofenceState> {
  GeofenceBloc(
    this._getGeofences,
    this._saveGeofence,
    this._deactivateGeofence, {
    required AppEventBus eventBus,
  }) : super(const GeofenceState()) {
    on<GeofencesStarted>(_refresh);
    on<GeofencesRefreshRequested>(_refresh);
    on<GeofenceCreated>(_create);
    on<GeofenceEdited>(_edit);
    on<GeofenceDeactivated>(_deactivate);
    _subscription = eventBus.events
        .where((event) => event is FleetDataCommitted)
        .listen((_) => add(const GeofencesRefreshRequested()));
  }
  final GetGeofences _getGeofences;
  final SaveGeofence _saveGeofence;
  final DeactivateGeofence _deactivateGeofence;
  late final StreamSubscription<AppEvent> _subscription;

  Future<void> _refresh(
    GeofenceEvent event,
    Emitter<GeofenceState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearFailure: true));
    final result = await _getGeofences();
    switch (result) {
      case Success<List<Geofence>, GeofenceFailure>(value: final geofences):
        emit(
          state.copyWith(
            geofences: geofences,
            isLoading: false,
            clearFailure: true,
          ),
        );
      case Failure<List<Geofence>, GeofenceFailure>(failure: final failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  Future<void> _create(
    GeofenceCreated event,
    Emitter<GeofenceState> emit,
  ) async {
    final result = await _saveGeofence.create(event.draft);
    await _handleAction(result, emit);
  }

  Future<void> _edit(GeofenceEdited event, Emitter<GeofenceState> emit) async {
    final result = await _saveGeofence.edit(event.id, event.draft);
    await _handleAction(result, emit);
  }

  Future<void> _deactivate(
    GeofenceDeactivated event,
    Emitter<GeofenceState> emit,
  ) async {
    final result = await _deactivateGeofence(event.id);
    await _handleAction(result, emit);
  }

  Future<void> _handleAction(
    GeofenceActionResult result,
    Emitter<GeofenceState> emit,
  ) async {
    switch (result) {
      case Success<void, GeofenceFailure>():
        await _refresh(const GeofencesRefreshRequested(), emit);
      case Failure<void, GeofenceFailure>(failure: final failure):
        emit(state.copyWith(failure: failure));
    }
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
