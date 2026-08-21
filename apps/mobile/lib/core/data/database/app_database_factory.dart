import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/core/data/database/database_migration_loader.dart';
import 'package:bytebeams/core/data/database/database_path_provider.dart';
import 'package:bytebeams/core/data/database/duckdb_app_database.dart';
import 'package:bytebeams/core/time/clock.dart';

final class AppDatabaseFactory {
  const AppDatabaseFactory({
    required DatabasePathProvider pathProvider,
    required DatabaseMigrationLoader migrationLoader,
    required Clock clock,
  }) : this._(
         pathProvider: pathProvider,
         migrationLoader: migrationLoader,
         clock: clock,
       );

  const AppDatabaseFactory._({
    required this._pathProvider,
    required this._migrationLoader,
    required this._clock,
  });

  final DatabasePathProvider _pathProvider;
  final DatabaseMigrationLoader _migrationLoader;
  final Clock _clock;

  Future<AppDatabase> open() async {
    final path = await _pathProvider.databasePath();
    final migrations = await _migrationLoader.load();
    return DuckDbAppDatabase.open(
      path: path,
      migrations: migrations,
      clock: _clock,
    );
  }
}
