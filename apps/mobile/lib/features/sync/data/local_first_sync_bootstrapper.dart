import 'dart:async';

import 'package:bytebeams/features/sync/domain/sync_repository.dart';

/// Starts background networking only after the persisted local store is ready
/// for presentation reads.
final class LocalFirstSyncBootstrapper {
  const LocalFirstSyncBootstrapper({required this._syncRepository});

  final SyncRepository _syncRepository;

  Future<void> start() async {
    unawaited(_syncRepository.synchronize());
  }
}
