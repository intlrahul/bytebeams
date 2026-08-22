import 'package:bytebeams/app_runtime.dart';
import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/core/data/database/app_database_factory.dart';
import 'package:bytebeams/features/sync/domain/app_event_bus.dart';
import 'package:bytebeams/features/sync/domain/sync_models.dart';
import 'package:bytebeams/features/sync/domain/sync_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'given_composed_runtime_when_started_then_background_sync_is_not_blocking',
    () async {
      final log = <String>[];
      final runtime = AppRuntime.forTesting(
        database: _Database(log),
        syncRepository: _Repository(log),
        eventBus: _EventBus(log),
      );

      await runtime.startBackgroundSync();

      expect(log, ['synchronize']);
    },
  );

  test('given_composed_runtime_when_closed_then_disposes_sync_event_bus_and_database_in_order', () async {
    final log = <String>[];
    final runtime = AppRuntime.forTesting(
      database: _Database(log),
      syncRepository: _Repository(log),
      eventBus: _EventBus(log),
    );

    await runtime.close();

    expect(log, ['sync.close', 'eventBus.close', 'database.close']);
  });

  test('given_database_opener_when_production_runtime_opened_then_uses_opened_local_database', () async {
    final log = <String>[];
    final database = _Database(log);

    final runtime = await AppRuntime.open(
      isAndroidEmulator: true,
      databaseOpener: _Opener(database, log),
    );

    expect(runtime.database, same(database));
    expect(log, ['database.open']);

    await runtime.close();
  });
}

final class _Database implements AppDatabase {
  _Database(this.log);

  final List<String> log;

  @override
  Future<void> close() async => log.add('database.close');

  @override
  Future<int> currentSchemaVersion() async => 3;

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
  Future<void> close() async => log.add('sync.close');

  @override
  Future<void> refreshFromServer() async {}

  @override
  Future<void> synchronize() async => log.add('synchronize');

  @override
  Future<void> useDemoData() async {}
}

final class _EventBus implements AppEventBus {
  _EventBus(this.log);

  final List<String> log;

  @override
  Stream<AppEvent> get events => const Stream.empty();

  @override
  Future<void> close() async => log.add('eventBus.close');

  @override
  void publish(AppEvent event) {}
}

final class _Opener implements AppDatabaseOpener {
  _Opener(this.database, this.log);

  final AppDatabase database;
  final List<String> log;

  @override
  Future<AppDatabase> open() async {
    log.add('database.open');
    return database;
  }
}
