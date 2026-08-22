import 'dart:async';

import 'package:bytebeams/core/time/clock.dart';
import 'package:bytebeams/features/fleet_home/domain/fleet_home_models.dart';
import 'package:bytebeams/features/fleet_home/domain/fleet_home_repository.dart';
import 'package:bytebeams/features/fleet_home/domain/get_fleet_home.dart';
import 'package:bytebeams/features/fleet_home/presentation/fleet_home_bloc.dart';
import 'package:bytebeams/features/sync/domain/app_event_bus.dart';
import 'package:bytebeams/features/sync/domain/sync_models.dart';
import 'package:bytebeams/features/sync/domain/sync_repository.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'given_started_bloc_when_data_commits_then_requeries_duckdb_snapshot',
    () async {
      final repository = _Repository();
      final events = AsyncAppEventBus();
      final bloc = _bloc(repository: repository, events: events);

      bloc.add(const FleetHomeStarted());
      await bloc.stream.firstWhere((state) => state.snapshot != null);
      events.publish(const FleetDataCommitted());
      await bloc.stream.firstWhere((state) => repository.calls == 2);

      expect(repository.calls, 2);
      await bloc.close();
      await events.close();
    },
  );

  test(
    'given_filter_selected_when_loaded_then_requeries_with_selected_filter',
    () async {
      final repository = _Repository();
      final events = AsyncAppEventBus();
      final bloc = _bloc(repository: repository, events: events);

      bloc.add(const FleetHomeFilterSelected(FleetFilter.offline));
      final state = await bloc.stream.firstWhere(
        (state) => state.snapshot != null,
      );

      expect(repository.filters, [FleetFilter.offline]);
      expect(state.filter, FleetFilter.offline);
      await bloc.close();
      await events.close();
    },
  );

  test(
    'given_sync_degradation_when_received_then_keeps_saved_fleet_visible',
    () async {
      final repository = _Repository();
      final events = AsyncAppEventBus();
      final sync = _SyncRepository();
      final bloc = FleetHomeBloc(
        getFleetHome: GetFleetHome(
          repository: repository,
          clock: const _Clock(),
        ),
        eventBus: events,
        syncRepository: sync,
      );

      bloc.add(const FleetHomeStarted());
      await bloc.stream.firstWhere((state) => state.snapshot != null);
      sync.emit(const SyncState.degraded(SyncFailure.transportUnavailable()));
      final state = await bloc.stream.firstWhere(
        (state) => state.degradedFailure != null,
      );

      expect(state.snapshot, isNotNull);
      await bloc.close();
      await events.close();
      await sync.close();
    },
  );

  test(
    'given_initial_read_failure_when_started_then_exposes_failure_state',
    () async {
      final events = AsyncAppEventBus();
      final bloc = _bloc(repository: _Repository(fails: true), events: events);

      bloc.add(const FleetHomeStarted());
      final state = await bloc.stream.firstWhere(
        (state) => state.failure != null,
      );

      expect(state.snapshot, isNull);
      await bloc.close();
      await events.close();
    },
  );

  test(
    'given_filter_read_failure_when_saved_data_exists_then_preserves_snapshot',
    () async {
      final repository = _Repository();
      final events = AsyncAppEventBus();
      final bloc = _bloc(repository: repository, events: events);

      bloc.add(const FleetHomeStarted());
      await bloc.stream.firstWhere((state) => state.snapshot != null);
      repository.fails = true;
      bloc.add(const FleetHomeFilterSelected(FleetFilter.offline));
      final state = await bloc.stream.firstWhere(
        (state) => state.failure != null,
      );

      expect(state.snapshot, isNotNull);
      expect(state.filter, FleetFilter.offline);
      await bloc.close();
      await events.close();
    },
  );

  test(
    'given_sync_states_when_received_then_updates_sync_and_degraded_flags',
    () async {
      final events = AsyncAppEventBus();
      final sync = _SyncRepository();
      final bloc = FleetHomeBloc(
        getFleetHome: GetFleetHome(
          repository: _Repository(),
          clock: const _Clock(),
        ),
        eventBus: events,
        syncRepository: sync,
      );

      sync.emit(const SyncState.syncing());
      final syncing = await bloc.stream.firstWhere((state) => state.isSyncing);
      expect(syncing.isSyncing, isTrue);
      sync.emit(
        const SyncState.demoDataAvailable(SyncFailure.bootstrapUnavailable()),
      );
      final demoDataAvailable = await bloc.stream.firstWhere(
        (state) => state.demoDataFailure != null,
      );
      expect(demoDataAvailable.demoDataFailure, isNotNull);
      sync.emit(const SyncState.idle());
      final idle = await bloc.stream.firstWhere(
        (state) =>
            !state.isSyncing &&
            state.degradedFailure == null &&
            state.demoDataFailure == null,
      );

      expect(idle.isSyncing, isFalse);
      expect(idle.degradedFailure, isNull);
      await bloc.close();
      await events.close();
      await sync.close();
    },
  );

  test(
    'given_demo_data_available_when_requested_then_invokes_explicit_import',
    () async {
      final events = AsyncAppEventBus();
      final sync = _SyncRepository();
      final bloc = FleetHomeBloc(
        getFleetHome: GetFleetHome(
          repository: _Repository(),
          clock: const _Clock(),
        ),
        eventBus: events,
        syncRepository: sync,
      );

      sync.emit(
        const SyncState.demoDataAvailable(SyncFailure.bootstrapUnavailable()),
      );
      await bloc.stream.firstWhere((state) => state.demoDataFailure != null);
      bloc.add(const FleetHomeDemoDataRequested());
      await bloc.stream.firstWhere((state) => state.isImportingDemoData);

      expect(sync.useDemoDataCalls, 1);
      await bloc.close();
      await events.close();
      await sync.close();
    },
  );
}

FleetHomeBloc _bloc({
  required _Repository repository,
  required AppEventBus events,
}) => FleetHomeBloc(
  getFleetHome: GetFleetHome(repository: repository, clock: const _Clock()),
  eventBus: events,
  syncRepository: _SyncRepository(),
);

final class _Clock implements Clock {
  const _Clock();

  @override
  DateTime nowUtc() => DateTime.utc(2026, 8, 22, 12);
}

final class _Repository implements FleetHomeRepository {
  _Repository({this.fails = false});

  var calls = 0;
  bool fails;
  final filters = <FleetFilter>[];

  @override
  Future<FleetHomeResult> getFleet({
    required FleetFilter filter,
    required DateTime asOfUtc,
  }) async {
    calls += 1;
    filters.add(filter);
    if (fails) {
      return const Result.failure(FleetHomeFailure.persistenceUnavailable());
    }
    return const Result.success(
      FleetHomeSnapshot(
        rows: [],
        counts: FleetFilterCounts(
          all: 1,
          moving: 0,
          idle: 0,
          stopped: 1,
          offline: 0,
        ),
      ),
    );
  }
}

final class _SyncRepository implements SyncRepository {
  final _states = StreamController<SyncState>.broadcast();
  SyncState _currentState = const SyncState.idle();
  var useDemoDataCalls = 0;

  @override
  SyncState get currentState => _currentState;

  @override
  Stream<SyncState> get states => _states.stream;

  void emit(SyncState state) {
    _currentState = state;
    _states.add(state);
  }

  @override
  Future<void> close() => _states.close();

  @override
  Future<void> refreshFromServer() async {}

  @override
  Future<void> synchronize() async {}

  @override
  Future<void> useDemoData() async {
    useDemoDataCalls += 1;
  }
}
