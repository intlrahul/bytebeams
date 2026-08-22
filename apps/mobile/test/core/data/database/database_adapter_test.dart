import 'dart:convert';
import 'dart:io';

import 'package:bytebeams/core/data/database/database_migration_loader.dart';
import 'package:bytebeams/core/data/database/database_path_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  test('given_migration_assets_when_loaded_then_returns_all_numbered_migrations_in_order', () async {
    final loader = AssetDatabaseMigrationLoader(
      assetBundle: _Bundle({
        'assets/migrations/0001_schema_migrations.sql': 'one',
        'assets/migrations/0002_telemetry_foundation.sql': 'two',
        'assets/migrations/0003_sync_state.sql': 'three',
        'assets/migrations/0004_alerts.sql': 'four',
      }),
    );

    final migrations = await loader.load();

    expect(migrations.map((migration) => migration.version), [1, 2, 3, 4]);
    expect(migrations.map((migration) => migration.sql), [
      'one',
      'two',
      'three',
      'four',
    ]);
  });

  test(
    'given_missing_migration_asset_when_loaded_then_propagates_failure',
    () async {
      final loader = AssetDatabaseMigrationLoader(
        assetBundle: _Bundle(const {}),
      );

      await expectLater(loader.load(), throwsStateError);
    },
  );

  test('given_application_support_directory_when_path_resolved_then_creates_directory_and_uses_configured_file_name', () async {
    final root = await Directory.systemTemp.createTemp('bytebeams-path-');
    final support = Directory(path.join(root.path, 'support'));
    final provider = ApplicationSupportDatabasePathProvider(
      fileName: 'fleet.duckdb',
      directoryResolver: () async => support,
    );

    final databasePath = await provider.databasePath();

    expect(databasePath, path.join(support.path, 'fleet.duckdb'));
    expect(await support.exists(), isTrue);
    await root.delete(recursive: true);
  });
}

final class _Bundle extends CachingAssetBundle {
  _Bundle(this.assets);

  final Map<String, String> assets;

  @override
  Future<ByteData> load(String key) async {
    final contents = assets[key];
    if (contents == null) {
      throw StateError('Missing asset: $key');
    }
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(contents)));
  }
}
