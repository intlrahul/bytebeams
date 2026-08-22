import 'dart:async';

import 'package:bytebeams/features/sync/data/demo_data_importer.dart';
import 'package:bytebeams/features/sync/data/duckdb_sync_store.dart';
import 'package:bytebeams/features/sync/data/fleet_remote_data_source.dart';
import 'package:bytebeams/features/sync/data/fleet_sync_coordinator.dart';
import 'package:bytebeams/features/sync/data/sync_dto_mapper.dart';
import 'package:bytebeams/features/sync/domain/app_event_bus.dart';
import 'package:bytebeams/features/sync/domain/sync_models.dart';
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
      final coordinator = FleetSyncCoordinator(
        remote: _DeliveryRemote(),
        store: store,
        demoDataImporter: _DemoImporter(),
        eventBus: bus,
        retryScheduler: _NeverCompletingRetryScheduler(),
      );

      await coordinator.synchronize();
      await Future<void>.delayed(Duration.zero);

      expect(store.ingestedDeliveryIds, ['6']);
      expect(events, hasLength(2));

      await coordinator.close();
      await eventSubscription.cancel();
      await bus.close();
    },
  );

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

    expect(states.last, const SyncState.degraded(SyncPersistenceUnavailable()));

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

final class _Store implements SyncStore {
  _Store({this.hasFleetData = false, this.failImport = false});

  final importedOrigins = <String>[];
  final ingestedDeliveryIds = <String>[];
  final bool hasFleetData;
  final bool failImport;
  int replacements = 0;

  @override
  Future<String?> deliveryCursor() async => '5';

  @override
  Future<bool> hasUsableFleetData() async => hasFleetData;

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
  Future<void> ingestDelivery(SyncDeliveryDto delivery) async {
    ingestedDeliveryIds.add(delivery.deliveryId);
  }

  @override
  Future<void> replaceBackendData(SyncBootstrapDto bootstrap) async {
    replacements += 1;
  }
}

final class _DemoImporter implements DemoDataImporter {
  @override
  Future<SyncBootstrapDto> load() => Future.value(
    const SyncBootstrapDto(
      vehicles: [],
      telemetry: [],
      deliveryCursor: 'demo-1',
    ),
  );
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
