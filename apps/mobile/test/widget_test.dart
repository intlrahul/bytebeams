import 'package:bytebeams/app_dependencies.dart';
import 'package:bytebeams/app_runtime.dart';
import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/main.dart' as app;
import 'package:bytebeams/core/design/sparkee/sparkee_color_tokens.dart';
import 'package:bytebeams/features/sync/domain/app_event_bus.dart';
import 'package:bytebeams/features/sync/domain/sync_models.dart';
import 'package:bytebeams/features/sync/domain/sync_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'given_app_started_when_first_frame_rendered_then_shows_fleet_home',
    (tester) async {
      // Given / When
      await tester.pumpWidget(
        app.ByteBeamsApp(
          dependencies: AppDependencies(
            AppRuntime.forTesting(
              database: _Database(),
              syncRepository: const _SyncRepository(),
              eventBus: const _EventBus(),
            ),
          ),
        ),
      );

      // Then
      expect(find.text('Fleet'), findsOneWidget);
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.brightness, Brightness.light);
      expect(materialApp.theme?.colorScheme.primary, SparkeeColors.primary);
    },
  );
}

final class _Database implements AppDatabase {
  @override
  Future<void> close() async {}

  @override
  Future<int> currentSchemaVersion() async => 2;

  @override
  Future<void> execute(
    String sql, {
    List<Object?> parameters = const [],
  }) async {}

  @override
  Future<List<List<Object?>>> query(
    String sql, {
    List<Object?> parameters = const [],
  }) async => sql.contains('all_count')
      ? [
          const [0, 0, 0, 0, 0],
        ]
      : const [];

  @override
  Future<T> transaction<T>(
    Future<T> Function(DatabaseTransaction transaction) action,
  ) => action(this);
}

final class _SyncRepository implements SyncRepository {
  const _SyncRepository();

  @override
  Stream<SyncState> get states => const Stream.empty();

  @override
  Future<void> close() async {}

  @override
  Future<void> refreshFromServer() async {}

  @override
  Future<void> synchronize() async {}

  @override
  Future<void> useDemoData() async {}
}

final class _EventBus implements AppEventBus {
  const _EventBus();

  @override
  Stream<AppEvent> get events => const Stream.empty();

  @override
  Future<void> close() async {}

  @override
  void publish(AppEvent event) {}
}
