import 'dart:async';

import 'package:bytebeams/core/diagnostics/startup_performance_monitor.dart';
import 'package:bytebeams/features/fleet_home/domain/fleet_home_models.dart';
import 'package:bytebeams/features/fleet_home/domain/get_fleet_home.dart';
import 'package:bytebeams/features/sync/domain/app_event_bus.dart';
import 'package:bytebeams/features/sync/domain/sync_models.dart';
import 'package:bytebeams/features/sync/domain/sync_repository.dart';
import 'package:bytebeams/features/sync/domain/use_demo_data.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class FleetHomeEvent {
  const FleetHomeEvent();
}

final class FleetHomeStarted extends FleetHomeEvent {
  const FleetHomeStarted();
}

final class FleetHomeFilterSelected extends FleetHomeEvent {
  const FleetHomeFilterSelected(this.filter);

  final FleetFilter filter;
}

final class FleetHomeDataCommitted extends FleetHomeEvent {
  const FleetHomeDataCommitted();
}

final class FleetHomeSyncStateChanged extends FleetHomeEvent {
  const FleetHomeSyncStateChanged(this.syncState);

  final SyncState syncState;
}

final class FleetHomeDemoDataRequested extends FleetHomeEvent {
  const FleetHomeDemoDataRequested();
}

final class FleetHomeState {
  const FleetHomeState({
    this.snapshot,
    this.filter = FleetFilter.all,
    this.isLoading = false,
    this.isSyncing = false,
    this.isImportingDemoData = false,
    this.dataRevision = 0,
    this.lastQuerySource = 'saved_data',
    this.degradedFailure,
    this.demoDataFailure,
    this.failure,
  });

  final FleetHomeSnapshot? snapshot;
  final FleetFilter filter;
  final bool isLoading;
  final bool isSyncing;
  final bool isImportingDemoData;
  final int dataRevision;
  final String lastQuerySource;
  final SyncFailure? degradedFailure;
  final SyncFailure? demoDataFailure;
  final FleetHomeFailure? failure;

  bool get hasRows => snapshot?.rows.isNotEmpty ?? false;
  bool get isEmptyFilter => snapshot != null && !hasRows;

  FleetHomeState copyWith({
    FleetHomeSnapshot? snapshot,
    FleetFilter? filter,
    bool? isLoading,
    bool? isSyncing,
    bool? isImportingDemoData,
    int? dataRevision,
    String? lastQuerySource,
    SyncFailure? degradedFailure,
    SyncFailure? demoDataFailure,
    FleetHomeFailure? failure,
    bool clearDegradedFailure = false,
    bool clearDemoDataFailure = false,
    bool clearFailure = false,
  }) => FleetHomeState(
    snapshot: snapshot ?? this.snapshot,
    filter: filter ?? this.filter,
    isLoading: isLoading ?? this.isLoading,
    isSyncing: isSyncing ?? this.isSyncing,
    isImportingDemoData: isImportingDemoData ?? this.isImportingDemoData,
    dataRevision: dataRevision ?? this.dataRevision,
    lastQuerySource: lastQuerySource ?? this.lastQuerySource,
    degradedFailure: clearDegradedFailure
        ? null
        : (degradedFailure ?? this.degradedFailure),
    demoDataFailure: clearDemoDataFailure
        ? null
        : (demoDataFailure ?? this.demoDataFailure),
    failure: clearFailure ? null : (failure ?? this.failure),
  );
}

final class FleetHomeBloc extends Bloc<FleetHomeEvent, FleetHomeState> {
  FleetHomeBloc({
    required this.getFleetHome,
    UseDemoData? useDemoData,
    required AppEventBus eventBus,
    required SyncRepository syncRepository,
    StartupPerformanceMonitor? performanceMonitor,
  }) : useDemoData = useDemoData ?? UseDemoData(repository: syncRepository),
       _performanceMonitor =
           performanceMonitor ?? const NoOpStartupPerformanceMonitor(),
       super(const FleetHomeState()) {
    on<FleetHomeStarted>(_onRefresh);
    on<FleetHomeFilterSelected>(_onFilterSelected);
    on<FleetHomeDataCommitted>(_onRefresh);
    on<FleetHomeSyncStateChanged>(_onSyncStateChanged);
    on<FleetHomeDemoDataRequested>(_onDemoDataRequested);
    _eventSubscription = eventBus.events
        .where(
          (event) => event is FleetDataCommitted || event is AlertStateChanged,
        )
        .listen((_) => add(const FleetHomeDataCommitted()));
    _syncSubscription = syncRepository.states.listen(
      (syncState) => add(FleetHomeSyncStateChanged(syncState)),
    );
    add(FleetHomeSyncStateChanged(syncRepository.currentState));
  }

  final GetFleetHome getFleetHome;
  final UseDemoData useDemoData;
  final StartupPerformanceMonitor _performanceMonitor;
  var _lastRenderedRevision = 0;
  late final StreamSubscription<AppEvent> _eventSubscription;
  late final StreamSubscription<SyncState> _syncSubscription;

  Future<void> _onRefresh(
    FleetHomeEvent event,
    Emitter<FleetHomeState> emit,
  ) async {
    if (state.snapshot == null) {
      emit(state.copyWith(isLoading: true, clearFailure: true));
    }
    final source = event is FleetHomeDataCommitted
        ? 'committed_data'
        : 'saved_data';
    _performanceMonitor.mark(
      'fleet_list_query_started',
      fields: {'source': source},
    );
    final queryTimer = Stopwatch()..start();
    final result = await getFleetHome(state.filter);
    switch (result) {
      case Success<FleetHomeSnapshot, FleetHomeFailure>(value: final snapshot):
        emit(
          state.copyWith(
            snapshot: snapshot,
            isLoading: false,
            dataRevision: state.dataRevision + 1,
            lastQuerySource: source,
            clearFailure: true,
          ),
        );
        _performanceMonitor.mark(
          'fleet_list_query_completed',
          fields: {
            'source': source,
            'rowCount': snapshot.rows.length,
            'durationMs': queryTimer.elapsedMilliseconds,
          },
        );
      case Failure<FleetHomeSnapshot, FleetHomeFailure>(failure: final failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  Future<void> _onFilterSelected(
    FleetHomeFilterSelected event,
    Emitter<FleetHomeState> emit,
  ) async {
    emit(
      state.copyWith(filter: event.filter, isLoading: state.snapshot == null),
    );
    const source = 'interactive';
    _performanceMonitor.mark(
      'fleet_list_query_started',
      fields: {'source': source},
    );
    final queryTimer = Stopwatch()..start();
    final result = await getFleetHome(event.filter);
    switch (result) {
      case Success<FleetHomeSnapshot, FleetHomeFailure>(value: final snapshot):
        emit(
          state.copyWith(
            snapshot: snapshot,
            isLoading: false,
            dataRevision: state.dataRevision + 1,
            lastQuerySource: source,
            clearFailure: true,
          ),
        );
        _performanceMonitor.mark(
          'fleet_list_query_completed',
          fields: {
            'source': source,
            'rowCount': snapshot.rows.length,
            'durationMs': queryTimer.elapsedMilliseconds,
          },
        );
      case Failure<FleetHomeSnapshot, FleetHomeFailure>(failure: final failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  void reportFleetListRendered(FleetHomeState renderedState) {
    if (renderedState.dataRevision <= _lastRenderedRevision ||
        renderedState.snapshot == null) {
      return;
    }
    _lastRenderedRevision = renderedState.dataRevision;
    _performanceMonitor.mark(
      'fleet_list_rendered',
      fields: {
        'source': renderedState.lastQuerySource,
        'rowCount': renderedState.snapshot!.rows.length,
      },
    );
  }

  void _onSyncStateChanged(
    FleetHomeSyncStateChanged event,
    Emitter<FleetHomeState> emit,
  ) {
    switch (event.syncState) {
      case SyncSyncing():
        emit(
          state.copyWith(
            isSyncing: true,
            clearDegradedFailure: true,
            clearDemoDataFailure: true,
          ),
        );
      case SyncDegraded(failure: final failure):
        emit(
          state.copyWith(
            isSyncing: false,
            isImportingDemoData: false,
            degradedFailure: failure,
            clearDemoDataFailure: true,
          ),
        );
      case SyncDemoDataAvailable(failure: final failure):
        emit(
          state.copyWith(
            isSyncing: false,
            isImportingDemoData: false,
            demoDataFailure: failure,
            clearDegradedFailure: true,
          ),
        );
      case SyncIdle():
        emit(
          state.copyWith(
            isSyncing: false,
            isImportingDemoData: false,
            clearDegradedFailure: true,
            clearDemoDataFailure: true,
          ),
        );
    }
  }

  Future<void> _onDemoDataRequested(
    FleetHomeDemoDataRequested event,
    Emitter<FleetHomeState> emit,
  ) async {
    if (state.demoDataFailure == null || state.isImportingDemoData) {
      return;
    }
    emit(state.copyWith(isImportingDemoData: true));
    await useDemoData();
  }

  @override
  Future<void> close() async {
    await _eventSubscription.cancel();
    await _syncSubscription.cancel();
    return super.close();
  }
}
