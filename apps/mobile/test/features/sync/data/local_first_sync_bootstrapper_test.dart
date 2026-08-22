import 'dart:async';

import 'package:bytebeams/features/sync/data/local_first_sync_bootstrapper.dart';
import 'package:bytebeams/features/sync/domain/sync_models.dart';
import 'package:bytebeams/features/sync/domain/sync_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given_background_sync_when_started_then_returns_without_waiting_for_network_completion', () async {
    final repository = _Repository();
    final bootstrapper = LocalFirstSyncBootstrapper(syncRepository: repository);

    await bootstrapper.start();

    expect(repository.synchronizeCalls, 1);
    expect(repository.completer.isCompleted, isFalse);
    repository.completer.complete();
  });
}

final class _Repository implements SyncRepository {
  final completer = Completer<void>();
  int synchronizeCalls = 0;

  @override
  SyncState get currentState => const SyncState.idle();

  @override
  Stream<SyncState> get states => const Stream.empty();

  @override
  Future<void> close() async {}

  @override
  Future<void> refreshFromServer() async {}

  @override
  Future<void> synchronize() {
    synchronizeCalls += 1;
    return completer.future;
  }

  @override
  Future<void> useDemoData() async {}
}
