import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_models.freezed.dart';

@freezed
sealed class SyncFailure with _$SyncFailure {
  const factory SyncFailure.bootstrapUnavailable() = SyncBootstrapUnavailable;
  const factory SyncFailure.replayGap({
    required String requestedCursor,
    required String oldestAvailableCursor,
  }) = SyncReplayGap;
  const factory SyncFailure.persistenceUnavailable() =
      SyncPersistenceUnavailable;
  const factory SyncFailure.transportUnavailable() = SyncTransportUnavailable;
}

@freezed
sealed class SyncState with _$SyncState {
  const factory SyncState.idle() = SyncIdle;
  const factory SyncState.syncing() = SyncSyncing;
  const factory SyncState.degraded(SyncFailure failure) = SyncDegraded;
  const factory SyncState.demoDataAvailable(SyncFailure failure) =
      SyncDemoDataAvailable;
}
