import 'dart:async';

import 'package:bytebeams/core/diagnostics/app_logger.dart';
import 'package:bytebeams/core/diagnostics/startup_performance_monitor.dart';
import 'package:bytebeams/features/sync/data/demo_data_importer.dart';
import 'package:bytebeams/features/sync/data/duckdb_sync_store.dart';
import 'package:bytebeams/features/sync/data/fleet_remote_data_source.dart';
import 'package:bytebeams/features/sync/data/sync_dto_mapper.dart';
import 'package:bytebeams/features/sync/domain/app_event_bus.dart';
import 'package:bytebeams/features/sync/domain/sync_models.dart';
import 'package:bytebeams/features/sync/domain/sync_batch_scheduler.dart';
import 'package:bytebeams/features/sync/domain/sync_repository.dart';
import 'package:bytebeams/features/sync/domain/sync_retry_scheduler.dart';

/// Coordinates local-first bootstrapping. All UI consumers react to the
/// committed local database through [FleetDataCommitted], never to API data.
final class FleetSyncCoordinator implements SyncRepository {
  factory FleetSyncCoordinator({
    required FleetRemoteDataSource remote,
    required SyncStore store,
    required DemoDataImporter demoDataImporter,
    required AppEventBus eventBus,
    AppLogger logger = const NoOpAppLogger(),
    SyncBatchScheduler batchScheduler = const SystemSyncBatchScheduler(),
    Duration batchWindow = const Duration(seconds: 5),
    int maximumBatchSize = 100,
    SyncRetryScheduler retryScheduler = const SystemSyncRetryScheduler(),
    SyncRetryPolicy retryPolicy = const SyncRetryPolicy(),
    StartupPerformanceMonitor performanceMonitor =
        const NoOpStartupPerformanceMonitor(),
  }) => FleetSyncCoordinator._(
    remote: remote,
    store: store,
    demoDataImporter: demoDataImporter,
    eventBus: eventBus,
    logger: logger,
    batchScheduler: batchScheduler,
    batchWindow: batchWindow,
    maximumBatchSize: maximumBatchSize,
    retryScheduler: retryScheduler,
    retryPolicy: retryPolicy,
    performanceMonitor: performanceMonitor,
  );

  FleetSyncCoordinator._({
    required this._remote,
    required this._store,
    required this._demoDataImporter,
    required this._eventBus,
    required this._logger,
    required this._batchScheduler,
    required this._batchWindow,
    required this._maximumBatchSize,
    required this._retryScheduler,
    required this._retryPolicy,
    required this._performanceMonitor,
  });

  final FleetRemoteDataSource _remote;
  final SyncStore _store;
  final DemoDataImporter _demoDataImporter;
  final AppEventBus _eventBus;
  final AppLogger _logger;
  final SyncBatchScheduler _batchScheduler;
  final Duration _batchWindow;
  final int _maximumBatchSize;
  final SyncRetryScheduler _retryScheduler;
  final SyncRetryPolicy _retryPolicy;
  final StartupPerformanceMonitor _performanceMonitor;
  final StreamController<SyncState> _states =
      StreamController<SyncState>.broadcast();
  SyncState _currentState = const SyncState.idle();
  final List<SyncDeliveryDto> _pendingDeliveries = [];
  Future<void> _flushChain = Future<void>.value();
  SyncBatchTimer? _batchTimer;
  bool _closed = false;

  @override
  SyncState get currentState => _currentState;

  @override
  Stream<SyncState> get states => _states.stream;

  @override
  Future<void> synchronize() async {
    _emit(const SyncState.syncing());
    try {
      _performanceMonitor.mark('bootstrap_request_started');
      final requestTimer = Stopwatch()..start();
      final bootstrap = await _remote.bootstrap();
      _performanceMonitor.mark(
        'bootstrap_response_received',
        fields: {
          'vehicleCount': bootstrap.vehicles.length,
          'packetCount': bootstrap.telemetry.length,
          'durationMs': requestTimer.elapsedMilliseconds,
        },
      );
      _performanceMonitor.mark('bootstrap_persistence_started');
      final persistenceTimer = Stopwatch()..start();
      await _store.importBootstrap(bootstrap, origin: 'backend');
      _performanceMonitor.mark(
        'bootstrap_persistence_completed',
        fields: {'durationMs': persistenceTimer.elapsedMilliseconds},
      );
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
      _performanceMonitor.mark('bootstrap_request_started');
      final requestTimer = Stopwatch()..start();
      final bootstrap = await _remote.bootstrap();
      _performanceMonitor.mark(
        'bootstrap_response_received',
        fields: {
          'vehicleCount': bootstrap.vehicles.length,
          'packetCount': bootstrap.telemetry.length,
          'durationMs': requestTimer.elapsedMilliseconds,
        },
      );
      _performanceMonitor.mark('bootstrap_persistence_started');
      final persistenceTimer = Stopwatch()..start();
      await _store.replaceBackendData(bootstrap);
      _performanceMonitor.mark(
        'bootstrap_persistence_completed',
        fields: {'durationMs': persistenceTimer.elapsedMilliseconds},
      );
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
          if (_closed) {
            return;
          }
          await _enqueue(delivery);
        }
        await _requestFlush();
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

  Future<void> _enqueue(SyncDeliveryDto delivery) {
    _pendingDeliveries.add(delivery);
    if (_pendingDeliveries.length >= _maximumBatchSize) {
      return _requestFlush();
    }
    _batchTimer ??= _batchScheduler.schedule(_batchWindow, () {
      _batchTimer = null;
      unawaited(_requestFlush());
    });
    return Future<void>.value();
  }

  Future<void> _requestFlush() {
    _batchTimer?.cancel();
    _batchTimer = null;
    _flushChain = _flushChain.then((_) => _flushPending());
    return _flushChain;
  }

  Future<void> _flushPending() async {
    if (_pendingDeliveries.isEmpty) {
      return;
    }
    final batch = List<SyncDeliveryDto>.of(_pendingDeliveries);
    _pendingDeliveries.clear();
    try {
      await _store.ingestDeliveries(batch);
      for (final delivery in batch) {
        _logger.info(
          'telemetry.packet.received',
          fields: {'signalName': delivery.packet.signalName},
        );
      }
      _committed(packetCount: batch.length);
    } on Object {
      _pendingDeliveries.insertAll(0, batch);
      _emit(const SyncState.degraded(SyncPersistenceUnavailable()));
      if (!_closed) {
        _batchTimer ??= _batchScheduler.schedule(_batchWindow, () {
          _batchTimer = null;
          unawaited(_requestFlush());
        });
      }
    }
  }

  void _committed({int? packetCount}) {
    _logger.info(
      'fleet.data.committed',
      fields: packetCount == null ? const {} : {'packetCount': packetCount},
    );
    _eventBus.publish(const FleetDataCommitted());
  }

  void _emit(SyncState state) {
    if (!_closed) {
      _currentState = state;
      _states.add(state);
    }
  }

  @override
  Future<void> close() async {
    _closed = true;
    _batchTimer?.cancel();
    _batchTimer = null;
    await _requestFlush();
    await _states.close();
  }
}
