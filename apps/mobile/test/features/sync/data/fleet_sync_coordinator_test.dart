import 'dart:async';

import 'package:bytebeams/core/diagnostics/app_logger.dart';
import 'package:bytebeams/features/sync/data/demo_data_importer.dart';
import 'package:bytebeams/features/sync/data/duckdb_sync_store.dart';
import 'package:bytebeams/features/sync/data/fleet_remote_data_source.dart';
import 'package:bytebeams/features/sync/data/fleet_sync_coordinator.dart';
import 'package:bytebeams/features/sync/data/sync_dto_mapper.dart';
import 'package:bytebeams/features/sync/domain/app_event_bus.dart';
import 'package:bytebeams/features/sync/domain/sync_models.dart';
import 'package:bytebeams/features/sync/domain/sync_batch_scheduler.dart';
import 'package:bytebeams/features/sync/domain/sync_retry_scheduler.dart';
import 'package:bytebeams_api/bytebeams_api.dart' as api;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'given_bootstrap_when_synchronized_then_commits_before_notifying_listeners',
    () async {
      final store = _Store();
      final bus = AsyncAppEventBus();
      final events = <AppEvent>[];
      final eventSubscription = bus.events.listen(events.add);
      final coordinator = FleetSyncCoordinator(
        remote: _Remote(),
        store: store,
        demoDataImporter: _DemoImporter(),
        eventBus: bus,
        retryScheduler: _NeverCompletingRetryScheduler(),
      );

      await coordinator.synchronize();
      await Future<void>.delayed(Duration.zero);

      expect(store.importedOrigins, ['backend']);
      expect(events, [const FleetDataCommitted()]);

      await coordinator.close();
      await eventSubscription.cancel();
      await bus.close();
    },
  );

  test('given_replay_gap_when_consuming_deliveries_then_preserves_data_and_reports_degraded_state', () async {
    final states = <SyncState>[];
    final bus = AsyncAppEventBus();
    final coordinator = FleetSyncCoordinator(
      remote: _ReplayGapRemote(),
      store: _Store(),
      demoDataImporter: _DemoImporter(),
      eventBus: bus,
      retryScheduler: _NeverCompletingRetryScheduler(),
    );
    final subscription = coordinator.states.listen(states.add);

    await coordinator.synchronize();
    await Future<void>.delayed(Duration.zero);

    expect(states.whereType<SyncDegraded>(), isNotEmpty);
    expect(
      states.whereType<SyncDegraded>().last.failure,
      const SyncReplayGap(requestedCursor: '5', oldestAvailableCursor: '9'),
    );

    await subscription.cancel();
    await coordinator.close();
    await bus.close();
  });

  test('given_fresh_install_bootstrap_failure_when_synchronized_then_exposes_demo_data_action', () async {
    final states = <SyncState>[];
    final bus = AsyncAppEventBus();
    final coordinator = FleetSyncCoordinator(
      remote: _BootstrapFailureRemote(),
      store: _Store(),
      demoDataImporter: _DemoImporter(),
      eventBus: bus,
    );
    final subscription = coordinator.states.listen(states.add);

    await coordinator.synchronize();
    await Future<void>.delayed(Duration.zero);

    expect(
      states.last,
      const SyncState.demoDataAvailable(SyncBootstrapUnavailable()),
    );
    expect(
      coordinator.currentState,
      const SyncState.demoDataAvailable(SyncBootstrapUnavailable()),
    );

    await subscription.cancel();
    await coordinator.close();
    await bus.close();
  });

  test('given_existing_local_fleet_and_bootstrap_failure_when_synchronized_then_preserves_data_in_degraded_state', () async {
    final states = <SyncState>[];
    final bus = AsyncAppEventBus();
    final coordinator = FleetSyncCoordinator(
      remote: _BootstrapFailureRemote(),
      store: _Store(hasFleetData: true),
      demoDataImporter: _DemoImporter(),
      eventBus: bus,
    );
    final subscription = coordinator.states.listen(states.add);

    await coordinator.synchronize();
    await Future<void>.delayed(Duration.zero);

    expect(states.last, const SyncState.degraded(SyncBootstrapUnavailable()));

    await subscription.cancel();
    await coordinator.close();
    await bus.close();
  });

  test('given_explicit_demo_action_when_imported_then_commits_demo_data_and_notifies', () async {
    final store = _Store();
    final bus = AsyncAppEventBus();
    final events = <AppEvent>[];
    final eventSubscription = bus.events.listen(events.add);
    final coordinator = FleetSyncCoordinator(
      remote: _Remote(),
      store: store,
      demoDataImporter: _DemoImporter(),
      eventBus: bus,
    );

    await coordinator.useDemoData();
    await Future<void>.delayed(Duration.zero);

    expect(store.importedOrigins, ['demo']);
    expect(events, [const FleetDataCommitted()]);

    await coordinator.close();
    await eventSubscription.cancel();
    await bus.close();
  });

  test('given_explicit_server_refresh_when_completed_then_replaces_data_and_notifies', () async {
    final store = _Store();
    final bus = AsyncAppEventBus();
    final events = <AppEvent>[];
    final eventSubscription = bus.events.listen(events.add);
    final coordinator = FleetSyncCoordinator(
      remote: _Remote(),
      store: store,
      demoDataImporter: _DemoImporter(),
      eventBus: bus,
      retryScheduler: _NeverCompletingRetryScheduler(),
    );

    await coordinator.refreshFromServer();
    await Future<void>.delayed(Duration.zero);

    expect(store.replacements, 1);
    expect(events, [const FleetDataCommitted()]);

    await coordinator.close();
    await eventSubscription.cancel();
    await bus.close();
  });

  test(
    'given_delivery_when_streamed_then_ingests_before_publishing_commit_event',
    () async {
      final store = _Store();
      final bus = AsyncAppEventBus();
      final events = <AppEvent>[];
      final eventSubscription = bus.events.listen(events.add);
      final logger = _RecordingLogger();
      final coordinator = FleetSyncCoordinator(
        remote: _DeliveryRemote(),
        store: store,
        demoDataImporter: _DemoImporter(),
        eventBus: bus,
        logger: logger,
        batchScheduler: _ManualBatchScheduler(),
        retryScheduler: _NeverCompletingRetryScheduler(),
      );

      await coordinator.synchronize();
      await Future<void>.delayed(Duration.zero);

      expect(store.ingestedDeliveryIds, ['6']);
      expect(events, hasLength(2));
      expect(logger.entries.map((entry) => entry.message), [
        'fleet.data.committed',
        'telemetry.packet.received',
        'fleet.data.committed',
      ]);
      expect(logger.entries[1].fields, {'signalName': 'soc'});
      expect(logger.entries.last.fields, {'packetCount': 1});

      await coordinator.close();
      await eventSubscription.cancel();
      await bus.close();
    },
  );

  test(
    'given_pending_delivery_when_batch_window_elapses_then_commits_once',
    () async {
      final deliveries = StreamController<SyncDeliveryDto>();
      final scheduler = _ManualBatchScheduler();
      final store = _Store();
      final coordinator = FleetSyncCoordinator(
        remote: _LiveRemote(deliveries.stream),
        store: store,
        demoDataImporter: _DemoImporter(),
        eventBus: AsyncAppEventBus(),
        batchScheduler: scheduler,
      );

      await coordinator.synchronize();
      deliveries.add(_delivery);
      await Future<void>.delayed(Duration.zero);
      expect(store.ingestedDeliveryIds, isEmpty);

      scheduler.fireAll();
      await Future<void>.delayed(Duration.zero);
      expect(store.ingestedDeliveryIds, ['6']);

      await deliveries.close();
      await coordinator.close();
    },
  );

  test('given_maximum_pending_deliveries_when_received_then_commits_without_waiting_for_window', () async {
    final deliveries = StreamController<SyncDeliveryDto>();
    final store = _Store();
    final coordinator = FleetSyncCoordinator(
      remote: _LiveRemote(deliveries.stream),
      store: store,
      demoDataImporter: _DemoImporter(),
      eventBus: AsyncAppEventBus(),
      batchScheduler: _ManualBatchScheduler(),
      maximumBatchSize: 2,
    );

    await coordinator.synchronize();
    deliveries
      ..add(_delivery)
      ..add(_secondDelivery);
    await Future<void>.delayed(Duration.zero);

    expect(store.ingestedDeliveryIds, ['6', '7']);
    await deliveries.close();
    await coordinator.close();
  });

  test('given_transport_failure_when_stream_consumed_then_waits_with_first_approved_retry_delay', () async {
    final retryScheduler = _RecordingRetryScheduler();
    final bus = AsyncAppEventBus();
    final coordinator = FleetSyncCoordinator(
      remote: _TransportFailureRemote(),
      store: _Store(),
      demoDataImporter: _DemoImporter(),
      eventBus: bus,
      retryScheduler: retryScheduler,
    );

    await coordinator.synchronize();
    await Future<void>.delayed(Duration.zero);

    expect(retryScheduler.delays, [const Duration(seconds: 1)]);

    await coordinator.close();
    await bus.close();
  });

  test('given_store_failure_when_bootstrap_imported_then_reports_typed_persistence_failure', () async {
    final states = <SyncState>[];
    final bus = AsyncAppEventBus();
    final coordinator = FleetSyncCoordinator(
      remote: _Remote(),
      store: _Store(failImport: true),
      demoDataImporter: _DemoImporter(),
      eventBus: bus,
    );
    final subscription = coordinator.states.listen(states.add);

    await coordinator.synchronize();
    await Future<void>.delayed(Duration.zero);

    expect(
      coordinator.currentState,
      const SyncState.degraded(SyncPersistenceUnavailable()),
    );

    await subscription.cancel();
    await coordinator.close();
    await bus.close();
  });

  test('given_local_fleet_check_fails_after_bootstrap_failure_then_reports_persistence_failure', () async {
    final states = <SyncState>[];
    final bus = AsyncAppEventBus();
    final coordinator = FleetSyncCoordinator(
      remote: _BootstrapFailureRemote(),
      store: _Store(failFleetCheck: true),
      demoDataImporter: _DemoImporter(),
      eventBus: bus,
    );
    final subscription = coordinator.states.listen(states.add);

    await coordinator.synchronize();

    expect(
      coordinator.currentState,
      const SyncState.degraded(SyncPersistenceUnavailable()),
    );
    await subscription.cancel();
    await coordinator.close();
    await bus.close();
  });

  test('given_refresh_or_demo_import_failure_when_requested_then_reports_typed_failure', () async {
    final states = <SyncState>[];
    final bus = AsyncAppEventBus();
    final coordinator = FleetSyncCoordinator(
      remote: _BootstrapFailureRemote(),
      store: _Store(),
      demoDataImporter: _DemoImporter(
        failure: const SyncBootstrapUnavailable(),
      ),
      eventBus: bus,
    );
    final subscription = coordinator.states.listen(states.add);

    await coordinator.refreshFromServer();
    expect(
      coordinator.currentState,
      const SyncState.degraded(SyncBootstrapUnavailable()),
    );
    await coordinator.useDemoData();
    expect(
      coordinator.currentState,
      const SyncState.degraded(SyncBootstrapUnavailable()),
    );

    await subscription.cancel();
    await coordinator.close();
    await bus.close();
  });

  test('given_delivery_persistence_failure_when_batch_retried_then_requeues_without_cursor_loss', () async {
    final states = <SyncState>[];
    final deliveries = StreamController<SyncDeliveryDto>();
    final scheduler = _ManualBatchScheduler();
    final store = _Store()..remainingIngestFailures = 1;
    final bus = AsyncAppEventBus();
    final coordinator = FleetSyncCoordinator(
      remote: _LiveRemote(deliveries.stream),
      store: store,
      demoDataImporter: _DemoImporter(),
      eventBus: bus,
      batchScheduler: scheduler,
    );
    final subscription = coordinator.states.listen(states.add);

    await coordinator.synchronize();
    deliveries.add(_delivery);
    await Future<void>.delayed(Duration.zero);
    scheduler.fireAll();
    await Future<void>.delayed(Duration.zero);

    expect(states.last, const SyncState.degraded(SyncPersistenceUnavailable()));
    expect(store.ingestedDeliveryIds, isEmpty);
    scheduler.fireAll();
    await Future<void>.delayed(Duration.zero);
    expect(store.ingestedDeliveryIds, ['6']);

    await deliveries.close();
    await subscription.cancel();
    await coordinator.close();
    await bus.close();
  });
}

class _Remote implements FleetRemoteDataSource {
  @override
  Future<SyncBootstrapDto> bootstrap() async =>
      const SyncBootstrapDto(vehicles: [], telemetry: [], deliveryCursor: '5');

  @override
  Stream<SyncDeliveryDto> deliveries({String? after}) => const Stream.empty();
}

final class _ReplayGapRemote extends _Remote {
  @override
  Stream<SyncDeliveryDto> deliveries({String? after}) => Stream.error(
    const SyncReplayGap(requestedCursor: '5', oldestAvailableCursor: '9'),
  );
}

final class _BootstrapFailureRemote extends _Remote {
  @override
  Future<SyncBootstrapDto> bootstrap() =>
      Future.error(const SyncBootstrapUnavailable());
}

final class _DeliveryRemote extends _Remote {
  @override
  Stream<SyncDeliveryDto> deliveries({String? after}) =>
      Stream.value(_delivery);
}

final class _TransportFailureRemote extends _Remote {
  @override
  Stream<SyncDeliveryDto> deliveries({String? after}) =>
      Stream.error(const SyncTransportUnavailable());
}

final class _LiveRemote extends _Remote {
  _LiveRemote(this._deliveries);

  final Stream<SyncDeliveryDto> _deliveries;

  @override
  Stream<SyncDeliveryDto> deliveries({String? after}) => _deliveries;
}

final class _Store implements SyncStore {
  _Store({
    this.hasFleetData = false,
    this.failImport = false,
    this.failFleetCheck = false,
  });

  final importedOrigins = <String>[];
  final ingestedDeliveryIds = <String>[];
  final bool hasFleetData;
  final bool failImport;
  final bool failFleetCheck;
  int remainingIngestFailures = 0;
  int replacements = 0;

  @override
  Future<String?> deliveryCursor() async => '5';

  @override
  Future<bool> hasUsableFleetData() async {
    if (failFleetCheck) throw StateError('database unavailable');
    return hasFleetData;
  }

  @override
  Future<void> importBootstrap(
    SyncBootstrapDto bootstrap, {
    required String origin,
  }) async {
    if (failImport) {
      throw StateError('database unavailable');
    }
    importedOrigins.add(origin);
  }

  @override
  Future<void> ingestDeliveries(List<SyncDeliveryDto> deliveries) async {
    if (remainingIngestFailures > 0) {
      remainingIngestFailures -= 1;
      throw StateError('database unavailable');
    }
    ingestedDeliveryIds.addAll(
      deliveries.map((delivery) => delivery.deliveryId),
    );
  }

  @override
  Future<void> replaceBackendData(SyncBootstrapDto bootstrap) async {
    replacements += 1;
  }
}

final class _ManualBatchScheduler implements SyncBatchScheduler {
  final _timers = <_ManualBatchTimer>[];

  @override
  SyncBatchTimer schedule(Duration delay, void Function() callback) {
    final timer = _ManualBatchTimer(callback);
    _timers.add(timer);
    return timer;
  }

  void fireAll() {
    for (final timer in List<_ManualBatchTimer>.of(_timers)) {
      timer.fire();
    }
  }
}

final class _ManualBatchTimer implements SyncBatchTimer {
  _ManualBatchTimer(this._callback);

  final void Function() _callback;
  var _cancelled = false;

  @override
  void cancel() => _cancelled = true;

  void fire() {
    if (!_cancelled) {
      _callback();
    }
  }
}

final class _DemoImporter implements DemoDataImporter {
  _DemoImporter({this.failure});

  final SyncFailure? failure;

  @override
  Future<SyncBootstrapDto> load() {
    if (failure case final configured?) return Future.error(configured);
    return Future.value(
      const SyncBootstrapDto(
        vehicles: [],
        telemetry: [],
        deliveryCursor: 'demo-1',
      ),
    );
  }
}

final class _NeverCompletingRetryScheduler implements SyncRetryScheduler {
  @override
  Future<void> wait(Duration delay) => Completer<void>().future;
}

final class _RecordingRetryScheduler implements SyncRetryScheduler {
  final delays = <Duration>[];

  @override
  Future<void> wait(Duration delay) {
    delays.add(delay);
    return Completer<void>().future;
  }
}

final class _RecordingLogger implements AppLogger {
  final entries = <_LogEntry>[];

  @override
  void debug(String message, {Map<String, Object?> fields = const {}}) {}

  @override
  void error(String message, {Map<String, Object?> fields = const {}}) {}

  @override
  void info(String message, {Map<String, Object?> fields = const {}}) {
    entries.add(_LogEntry(message, fields));
  }

  @override
  void warning(String message, {Map<String, Object?> fields = const {}}) {}
}

final class _LogEntry {
  const _LogEntry(this.message, this.fields);

  final String message;
  final Map<String, Object?> fields;
}

final _delivery = SyncDeliveryDto(
  deliveryId: '6',
  packet: api.TelemetryPacket(
    packetId: 'packet-6',
    vehicleId: 'vehicle-1',
    eventTimestamp: DateTime.utc(2026, 8, 21),
    signalName: 'soc',
    value: api.SignalValue(
      kind: api.SignalValueKindEnum.number,
      numberValue: 80,
    ),
  ),
);

final _secondDelivery = SyncDeliveryDto(
  deliveryId: '7',
  packet: api.TelemetryPacket(
    packetId: 'packet-7',
    vehicleId: 'vehicle-2',
    eventTimestamp: DateTime.utc(2026, 8, 21),
    signalName: 'last_ping',
    value: api.SignalValue(
      kind: api.SignalValueKindEnum.boolean,
      booleanValue: true,
    ),
  ),
);
