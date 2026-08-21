import 'package:bytebeams/core/data/database/database_migration.dart';
import 'package:flutter/services.dart';

abstract interface class DatabaseMigrationLoader {
  Future<List<DatabaseMigration>> load();
}

final class AssetDatabaseMigrationLoader implements DatabaseMigrationLoader {
  const AssetDatabaseMigrationLoader();

  static const _migrationAssets = <({int version, String name, String path})>[
    (
      version: 1,
      name: 'create schema migrations',
      path: 'assets/migrations/0001_schema_migrations.sql',
    ),
    (
      version: 2,
      name: 'create telemetry foundation',
      path: 'assets/migrations/0002_telemetry_foundation.sql',
    ),
  ];

  @override
  Future<List<DatabaseMigration>> load() {
    return Future.wait(
      _migrationAssets.map(
        (asset) async => DatabaseMigration(
          version: asset.version,
          name: asset.name,
          sql: await rootBundle.loadString(asset.path),
        ),
      ),
    );
  }
}
