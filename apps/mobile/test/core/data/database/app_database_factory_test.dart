import 'dart:io';

import 'package:bytebeams/core/data/database/app_database_factory.dart';
import 'package:bytebeams/core/data/database/database_migration.dart';
import 'package:bytebeams/core/data/database/database_migration_loader.dart';
import 'package:bytebeams/core/data/database/database_path_provider.dart';
import 'package:bytebeams/core/data/database/duckdb_app_database.dart';
import 'package:bytebeams/core/time/clock.dart';
import 'package:dart_duckdb/dart_duckdb.dart' as duckdb;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given_path_and_migrations_when_factory_opened_then_creates_migrated_database', () async {
    final directory = await Directory.systemTemp.createTemp(
      'bytebeams-factory-',
    );
    final databasePath = '${directory.path}/fleet.duckdb';
    final driver = _Driver();
    final database = await AppDatabaseFactory(
      pathProvider: _PathProvider(databasePath),
      migrationLoader: const _MigrationLoader(),
      clock: const _Clock(),
      driver: driver,
    ).open();

    expect(driver.openedPaths, [databasePath]);
    expect(
      driver.connection.executedSql,
      contains(
        predicate<String>(
          (sql) => sql.startsWith('CREATE TABLE IF NOT EXISTS schema_migrations'),
        ),
      ),
    );

    await database.close();
    await directory.delete(recursive: true);
  });

  test('given_path_resolution_failure_when_factory_opened_then_propagates_the_failure', () async {
    await expectLater(
      AppDatabaseFactory(
        pathProvider: _FailingPathProvider(),
        migrationLoader: const _MigrationLoader(),
        clock: const _Clock(),
      ).open(),
      throwsStateError,
    );
  });
}

final class _PathProvider implements DatabasePathProvider {
  const _PathProvider(this.value);
  final String value;
  @override
  Future<String> databasePath() async => value;
}

final class _FailingPathProvider implements DatabasePathProvider {
  @override
  Future<String> databasePath() => Future.error(StateError('path unavailable'));
}

final class _MigrationLoader implements DatabaseMigrationLoader {
  const _MigrationLoader();
  @override
  Future<List<DatabaseMigration>> load() async => const [
    DatabaseMigration(
      version: 1,
      name: 'schema migrations',
      sql: '''
CREATE TABLE IF NOT EXISTS schema_migrations (
  version INTEGER PRIMARY KEY,
  name VARCHAR NOT NULL,
  applied_at_utc TIMESTAMPTZ NOT NULL
)
''',
    ),
  ];
}

final class _Clock implements Clock {
  const _Clock();
  @override
  DateTime nowUtc() => DateTime.utc(2026, 8, 21);
}

final class _Driver implements DuckDbDriver {
  final database = _Database();
  final connection = _Connection();
  final openedPaths = <String>[];

  @override
  Future<duckdb.Connection> connect(duckdb.Database database) async =>
      connection;

  @override
  Future<duckdb.Database> open(String path) async {
    openedPaths.add(path);
    return database;
  }
}

final class _Database implements duckdb.Database {
  @override
  Future<void> dispose() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _Connection implements duckdb.Connection {
  final executedSql = <String>[];
  @override
  Future<void> dispose() async {}
  @override
  Future<void> execute(
    String query, {
    duckdb.DuckDBCancellationToken? token,
  }) async {
    executedSql.add(query);
  }

  @override
  Future<duckdb.PreparedStatement> prepare(String query) async => _Statement();
  @override
  Future<duckdb.ResultSet> query(
    String query, {
    duckdb.DuckDBCancellationToken? token,
  }) async => _ResultSet();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _Statement implements duckdb.PreparedStatement {
  @override
  void bindParams(List parameters) {}
  @override
  Future<void> dispose() async {}
  @override
  Future<duckdb.ResultSet> execute({
    duckdb.DuckDBCancellationToken? token,
  }) async => _ResultSet();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _ResultSet implements duckdb.ResultSet {
  @override
  Future<void> dispose() async {}
  @override
  List<List<Object?>> fetchAll({int? batchSize}) => const [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
