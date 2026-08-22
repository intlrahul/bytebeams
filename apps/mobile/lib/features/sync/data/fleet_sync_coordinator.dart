import 'dart:async';

import 'package:bytebeams/features/sync/data/demo_data_importer.dart';
import 'package:bytebeams/features/sync/data/duckdb_sync_store.dart';
import 'package:bytebeams/features/sync/data/fleet_remote_data_source.dart';
import 'package:bytebeams/features/sync/domain/app_event_bus.dart';
import 'package:bytebeams/features/sync/domain/sync_models.dart';
import 'package:bytebeams/features/sync/domain/sync_repository.dart';
import 'package:bytebeams/features/sync/domain/sync_retry_scheduler.dart';

/// Coordinates local-first bootstrapping. All UI consumers react to the
/// committed local database through [FleetDataCommitted], never to API data.
final class FleetSyncCoordinator implements SyncRepository {
  FleetSyncCoordinator({
    required this._remote,
    required this._store,
    required this._demoDataImporter,
    required this._eventBus,
    this._retryScheduler = const SystemSyncRetryScheduler(),
    this._retryPolicy = const SyncRetryPolicy(),
  });

  final FleetRemoteDataSource _remote;
  final SyncStore _store;
  final DemoDataImporter _demoDataImporter;
  final AppEventBus _eventBus;
  final SyncRetryScheduler _retryScheduler;
  final SyncRetryPolicy _retryPolicy;
  final StreamController<SyncState> _states =
      StreamController<SyncState>.broadcast();
  bool _closed = false;

  @override
  Stream<SyncState> get states => _states.stream;

  @override
  Future<void> synchronize() async {
    _emit(const SyncState.syncing());
    try {
      final bootstrap = await _remote.bootstrap();
      await _store.importBootstrap(bootstrap, origin: 'backend');
      _committed();
      unawaited(_consumeDeliveries());
      _emit(const SyncState.idle());
    } on SyncBootstrapUnavailable catch (failure) {
      try {
        if (await _store.hasUsableFleetData()) {
          _emit(SyncState.degraded(failure));
        } else {
          _emit(SyncState.demoDataAvailable(failure));
        }
      } on Object {
        _emit(const SyncState.degraded(SyncPersistenceUnavailable()));
      }
    } on SyncFailure catch (failure) {
      _emit(SyncState.degraded(failure));
    } on Object {
      _emit(const SyncState.degraded(SyncPersistenceUnavailable()));
    }
  }

  @override
  Future<void> refreshFromServer() async {
    _emit(const SyncState.syncing());
    try {
      final bootstrap = await _remote.bootstrap();
      await _store.replaceBackendData(bootstrap);
      _committed();
      unawaited(_consumeDeliveries());
      _emit(const SyncState.idle());
    } on SyncFailure catch (failure) {
      _emit(SyncState.degraded(failure));
    } on Object {
      _emit(const SyncState.degraded(SyncPersistenceUnavailable()));
    }
  }

  @override
  Future<void> useDemoData() async {
    try {
      final bootstrap = await _demoDataImporter.load();
      await _store.importBootstrap(bootstrap, origin: 'demo');
      _committed();
      _emit(const SyncState.idle());
    } on SyncFailure catch (failure) {
      _emit(SyncState.degraded(failure));
    } on Object {
      _emit(const SyncState.degraded(SyncPersistenceUnavailable()));
    }
  }

  Future<void> _consumeDeliveries() async {
    var attempt = 0;
    while (!_closed) {
      try {
        final cursor = await _store.deliveryCursor();
        await for (final delivery in _remote.deliveries(after: cursor)) {
          await _store.ingestDelivery(delivery);
          _committed();
        }
        throw const SyncTransportUnavailable();
      } on SyncReplayGap catch (failure) {
        _emit(SyncState.degraded(failure));
        return;
      } on SyncFailure catch (failure) {
        _emit(SyncState.degraded(failure));
        await _retryScheduler.wait(_retryPolicy.delayForAttempt(attempt));
        attempt += 1;
      } on Object {
        _emit(const SyncState.degraded(SyncPersistenceUnavailable()));
        return;
      }
    }
  }

  void _committed() => _eventBus.publish(const FleetDataCommitted());

  void _emit(SyncState state) {
    if (!_closed) {
      _states.add(state);
    }
  }

  @override
  Future<void> close() async {
    _closed = true;
    await _states.close();
  }
}
