import 'dart:async';

import 'package:bytebeams/core/time/clock.dart';
import 'package:bytebeams/core/diagnostics/startup_performance_monitor.dart';
import 'package:bytebeams/core/design/sparkee/sparkee_theme.dart';
import 'package:bytebeams/features/fleet_home/domain/fleet_home_models.dart';
import 'package:bytebeams/features/fleet_home/domain/fleet_home_repository.dart';
import 'package:bytebeams/features/fleet_home/domain/get_fleet_home.dart';
import 'package:bytebeams/features/fleet_home/presentation/fleet_home_bloc.dart';
import 'package:bytebeams/features/fleet_home/presentation/fleet_home_page.dart';
import 'package:bytebeams/features/sync/domain/app_event_bus.dart';
import 'package:bytebeams/features/sync/domain/sync_models.dart';
import 'package:bytebeams/features/sync/domain/sync_repository.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'given_saved_fleet_when_home_rendered_then_shows_sql_counts_and_row',
    (tester) async {
      final events = AsyncAppEventBus();
      final sync = _SyncRepository();
      final repository = _Repository();
      final monitor = _PerformanceMonitor();
      await tester.pumpWidget(
        MaterialApp(
          theme: SparkeeTheme.light(),
          home: FleetHomePage(
            createBloc: () => FleetHomeBloc(
              getFleetHome: GetFleetHome(
                repository: repository,
                clock: const _Clock(),
              ),
              eventBus: events,
              syncRepository: sync,
              performanceMonitor: monitor,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fleet'), findsOneWidget);
      expect(find.text('All (4)'), findsOneWidget);
      expect(find.text('BB-001'), findsOneWidget);
      expect(find.text('Moving'), findsOneWidget);
      expect(find.text('78 %'), findsOneWidget);
      expect(find.text('242 km'), findsOneWidget);
      expect(find.text('Idle'), findsOneWidget);
      expect(find.text('Stopped'), findsOneWidget);
      expect(find.text('— %'), findsOneWidget);
      expect(find.text('12.5 km'), findsOneWidget);
      expect(monitor.stages, contains('fleet_list_rendered'));

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.text('Offline'), findsOneWidget);

      final offlineFilter = find.text('Offline (1)');
      await tester.ensureVisible(offlineFilter);
      await tester.tap(offlineFilter);
      await tester.pumpAndSettle();
      expect(repository.filters.last, FleetFilter.offline);

      await events.close();
      await sync.close();
    },
  );

  testWidgets('given_empty_filter_when_home_rendered_then_shows_empty_state', (
    tester,
  ) async {
    final events = AsyncAppEventBus();
    final sync = _SyncRepository();
    await tester.pumpWidget(
      _app(events: events, sync: sync, repository: const _EmptyRepository()),
    );
    await tester.pumpAndSettle();

    expect(find.text('No all vehicles'), findsOneWidget);
    expect(find.text('Try another fleet status.'), findsOneWidget);
    await events.close();
    await sync.close();
  });

  testWidgets(
    'given_fresh_install_sync_failure_when_home_rendered_then_offers_demo_data',
    (tester) async {
      final events = AsyncAppEventBus();
      final sync = _SyncRepository();
      await tester.pumpWidget(
        _app(events: events, sync: sync, repository: const _EmptyRepository()),
      );
      sync.emit(
        const SyncState.demoDataAvailable(SyncFailure.bootstrapUnavailable()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Use demo data'), findsOneWidget);
      await tester.tap(find.text('Use demo data'));
      await tester.pump();
      expect(sync.useDemoDataCalls, 1);

      await events.close();
      await sync.close();
    },
  );

  testWidgets(
    'given_read_failure_when_home_rendered_then_shows_failure_state',
    (tester) async {
      final events = AsyncAppEventBus();
      final sync = _SyncRepository();
      await tester.pumpWidget(
        _app(
          events: events,
          sync: sync,
          repository: const _FailingRepository(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Saved fleet data could not be read.'), findsOneWidget);
      await events.close();
      await sync.close();
    },
  );
}

final class _PerformanceMonitor implements StartupPerformanceMonitor {
  final stages = <String>[];

  @override
  void mark(String stage, {Map<String, Object?> fields = const {}}) {
    stages.add(stage);
  }
}

Widget _app({
  required AppEventBus events,
  required SyncRepository sync,
  required FleetHomeRepository repository,
}) => MaterialApp(
  theme: SparkeeTheme.light(),
  home: FleetHomePage(
    createBloc: () => FleetHomeBloc(
      getFleetHome: GetFleetHome(repository: repository, clock: const _Clock()),
      eventBus: events,
      syncRepository: sync,
    ),
  ),
);

final class _Clock implements Clock {
  const _Clock();

  @override
  DateTime nowUtc() => DateTime.utc(2026, 8, 22);
}

final class _Repository implements FleetHomeRepository {
  final filters = <FleetFilter>[];

  @override
  Future<FleetHomeResult> getFleet({
    required FleetFilter filter,
    required DateTime asOfUtc,
  }) async {
    filters.add(filter);
    return const Result.success(
      FleetHomeSnapshot(
        rows: [
          FleetVehicleRow(
            vehicleId: 'vehicle-1',
            registrationNumber: 'BB-001',
            model: 'E-Truck',
            status: FleetStatus.moving,
            soc: 78,
            rangeKm: 242,
            attentionCount: 1,
          ),
          FleetVehicleRow(
            vehicleId: 'vehicle-2',
            registrationNumber: 'BB-002',
            model: 'E-Truck',
            status: FleetStatus.idle,
            soc: 50,
            rangeKm: 100,
            attentionCount: 0,
          ),
          FleetVehicleRow(
            vehicleId: 'vehicle-3',
            registrationNumber: 'BB-003',
            model: 'E-Truck',
            status: FleetStatus.stopped,
            soc: null,
            rangeKm: 12.5,
            attentionCount: 0,
          ),
          FleetVehicleRow(
            vehicleId: 'vehicle-4',
            registrationNumber: 'BB-004',
            model: 'E-Truck',
            status: FleetStatus.offline,
            soc: 90,
            rangeKm: 300,
            attentionCount: 0,
          ),
        ],
        counts: FleetFilterCounts(
          all: 4,
          moving: 1,
          idle: 1,
          stopped: 1,
          offline: 1,
        ),
      ),
    );
  }
}

final class _EmptyRepository implements FleetHomeRepository {
  const _EmptyRepository();

  @override
  Future<FleetHomeResult> getFleet({
    required FleetFilter filter,
    required DateTime asOfUtc,
  }) async => const Result.success(
    FleetHomeSnapshot(
      rows: [],
      counts: FleetFilterCounts(
        all: 0,
        moving: 0,
        idle: 0,
        stopped: 0,
        offline: 0,
      ),
    ),
  );
}

final class _FailingRepository implements FleetHomeRepository {
  const _FailingRepository();

  @override
  Future<FleetHomeResult> getFleet({
    required FleetFilter filter,
    required DateTime asOfUtc,
  }) async => const Result.failure(FleetHomeFailure.persistenceUnavailable());
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
