import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/core/data/database/database_migration_loader.dart';
import 'package:bytebeams/core/data/database/database_path_provider.dart';
import 'package:bytebeams/core/data/database/duckdb_app_database.dart';
import 'package:bytebeams/core/time/clock.dart';

abstract interface class AppDatabaseOpener {
  Future<AppDatabase> open();
}

final class AppDatabaseFactory implements AppDatabaseOpener {
  const AppDatabaseFactory({
    required DatabasePathProvider pathProvider,
    required DatabaseMigrationLoader migrationLoader,
    required Clock clock,
    DuckDbDriver driver = const NativeDuckDbDriver(),
  }) : this._(
         pathProvider: pathProvider,
         migrationLoader: migrationLoader,
         clock: clock,
         driver: driver,
       );

  const AppDatabaseFactory._({
    required this._pathProvider,
    required this._migrationLoader,
    required this._clock,
    required this._driver,
  });

  final DatabasePathProvider _pathProvider;
  final DatabaseMigrationLoader _migrationLoader;
  final Clock _clock;
  final DuckDbDriver _driver;

  @override
  Future<AppDatabase> open() async {
    final path = await _pathProvider.databasePath();
    final migrations = await _migrationLoader.load();
    return DuckDbAppDatabase.open(
      path: path,
      migrations: migrations,
      clock: _clock,
      driver: _driver,
    );
  }
}
