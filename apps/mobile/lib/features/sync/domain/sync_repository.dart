import 'package:bytebeams/features/sync/domain/sync_models.dart';

abstract interface class SyncRepository {
  /// The most recently emitted state, retained for late UI subscribers.
  SyncState get currentState;

  Stream<SyncState> get states;

  Future<void> synchronize();

  /// Replaces only data supplied by the backend after a replay gap.
  Future<void> refreshFromServer();

  /// Imports the packaged deterministic fixture after a fresh-install failure.
  Future<void> useDemoData();

  Future<void> close();
}
