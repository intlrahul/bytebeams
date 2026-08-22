import 'package:bytebeams/app_runtime.dart';
import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/main.dart';
import 'package:bytebeams/features/sync/domain/app_event_bus.dart';
import 'package:bytebeams/features/sync/domain/sync_models.dart';
import 'package:bytebeams/features/sync/domain/sync_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given_runtime_opener_when_app_started_then_opens_before_rendering_and_starts_background_sync', () async {
    final log = <String>[];
    final runtime = AppRuntime.forTesting(
      database: _Database(),
      syncRepository: _Repository(log),
      eventBus: _EventBus(),
    );

    await runByteBeamsApp(
      isAndroidEmulator: true,
      openRuntime: ({required isAndroidEmulator}) async {
        expect(isAndroidEmulator, isTrue);
        log.add('open');
        return runtime;
      },
      appRunner: (_) => log.add('render'),
    );

    expect(log, ['open', 'render', 'sync']);
  });
}

final class _Database implements AppDatabase {
  @override
  Future<void> close() async {}
  @override
  Future<int> currentSchemaVersion() async => 4;
  @override
  Future<void> execute(
    String sql, {
    List<Object?> parameters = const [],
  }) async {}
  @override
  Future<List<List<Object?>>> query(
    String sql, {
    List<Object?> parameters = const [],
  }) async => const [];
  @override
  Future<T> transaction<T>(
    Future<T> Function(DatabaseTransaction transaction) action,
  ) => action(this);
}

final class _Repository implements SyncRepository {
  _Repository(this.log);
  final List<String> log;
  @override
  SyncState get currentState => const SyncState.idle();
  @override
  Stream<SyncState> get states => const Stream.empty();
  @override
  Future<void> close() async {}
  @override
  Future<void> refreshFromServer() async {}
  @override
  Future<void> synchronize() async => log.add('sync');
  @override
  Future<void> useDemoData() async {}
}

final class _EventBus implements AppEventBus {
  @override
  Stream<AppEvent> get events => const Stream.empty();
  @override
  Future<void> close() async {}
  @override
  void publish(AppEvent event) {}
}
