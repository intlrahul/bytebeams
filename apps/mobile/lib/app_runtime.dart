import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/core/data/database/app_database_factory.dart';
import 'package:bytebeams/core/data/database/database_migration_loader.dart';
import 'package:bytebeams/core/data/database/database_path_provider.dart';
import 'package:bytebeams/core/time/clock.dart';
import 'package:bytebeams/features/sync/data/api_endpoint_provider.dart';
import 'package:bytebeams/features/sync/data/demo_data_importer.dart';
import 'package:bytebeams/features/sync/data/duckdb_sync_store.dart';
import 'package:bytebeams/features/sync/data/fleet_remote_data_source.dart';
import 'package:bytebeams/features/sync/data/fleet_sync_coordinator.dart';
import 'package:bytebeams/features/sync/data/local_first_sync_bootstrapper.dart';
import 'package:bytebeams/features/sync/domain/app_event_bus.dart';
import 'package:bytebeams/features/sync/domain/sync_repository.dart';
import 'package:bytebeams/features/telemetry/data/telemetry_packet_classifier.dart';
import 'package:dio/dio.dart';

/// Application composition root. Feature and presentation code receives only
/// the abstractions it needs; it does not construct platform/data adapters.
final class AppRuntime {
  AppRuntime._({
    required this.database,
    required this.syncRepository,
    required this.eventBus,
  });

  /// Constructor for deterministic lifecycle tests and alternate composition
  /// roots. The production [open] factory owns concrete adapter construction.
  AppRuntime.forTesting({
    required this.database,
    required this.syncRepository,
    required this.eventBus,
  });

  final AppDatabase database;
  final SyncRepository syncRepository;
  final AppEventBus eventBus;

  static Future<AppRuntime> open({
    required bool isAndroidEmulator,
    AppDatabaseOpener? databaseOpener,
  }) async {
    const clock = SystemClock();
    final database =
        await (databaseOpener ??
                AppDatabaseFactory(
                  pathProvider: const ApplicationSupportDatabasePathProvider(),
                  migrationLoader: const AssetDatabaseMigrationLoader(),
                  clock: clock,
                ))
            .open();
    final eventBus = AsyncAppEventBus();
    final coordinator = FleetSyncCoordinator(
      remote: DioFleetRemoteDataSource(
        dio: Dio(),
        endpointProvider: DefaultApiEndpointProvider(
          isAndroidEmulator: isAndroidEmulator,
        ),
      ),
      store: DuckDbSyncStore(
        database: database,
        classifier: const TelemetryPacketClassifier(clock: clock),
      ),
      demoDataImporter: const AssetDemoDataImporter(),
      eventBus: eventBus,
    );
    return AppRuntime._(
      database: database,
      syncRepository: coordinator,
      eventBus: eventBus,
    );
  }

  Future<void> startBackgroundSync() =>
      LocalFirstSyncBootstrapper(syncRepository: syncRepository).start();

  Future<void> close() async {
    await syncRepository.close();
    await eventBus.close();
    await database.close();
  }
}
