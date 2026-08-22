import 'package:bytebeams/core/data/database/database_migration.dart';
import 'package:flutter/services.dart';

abstract interface class DatabaseMigrationLoader {
  Future<List<DatabaseMigration>> load();
}

final class AssetDatabaseMigrationLoader implements DatabaseMigrationLoader {
  const AssetDatabaseMigrationLoader({this.assetBundle});

  final AssetBundle? assetBundle;

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
    (
      version: 3,
      name: 'create sync state',
      path: 'assets/migrations/0003_sync_state.sql',
    ),
    (
      version: 4,
      name: 'create alert episodes',
      path: 'assets/migrations/0004_alerts.sql',
    ),
    (
      version: 5,
      name: 'create versioned geofences',
      path: 'assets/migrations/0005_geofences.sql',
    ),
    (
      version: 6,
      name: 'create automatic trips',
      path: 'assets/migrations/0006_trips.sql',
    ),
  ];

  @override
  Future<List<DatabaseMigration>> load() {
    return Future.wait(
      _migrationAssets.map(
        (asset) async => DatabaseMigration(
          version: asset.version,
          name: asset.name,
          sql: await (assetBundle ?? rootBundle).loadString(asset.path),
        ),
      ),
    );
  }
}
