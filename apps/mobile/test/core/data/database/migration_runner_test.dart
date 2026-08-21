import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/core/data/database/database_failure.dart';
import 'package:bytebeams/core/data/database/database_migration.dart';
import 'package:bytebeams/core/data/database/migration_runner.dart';
import 'package:bytebeams/core/time/clock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final clock = _FixedClock(DateTime.utc(2026, 8, 21));
  final initialMigrations = [
    const DatabaseMigration(
      version: 1,
      name: 'create schema migrations',
      sql: 'CREATE TABLE IF NOT EXISTS schema_migrations',
    ),
  ];

  test(
    'given_a_new_database_when_migrated_then_records_schema_version_one',
    () async {
      final database = _FakeDatabase();

      await MigrationRunner(
        migrations: initialMigrations,
        clock: clock,
      ).migrate(database);

      expect(database.appliedVersions, {1});
      expect(
        database.appliedAtUtcByVersion[1],
        DateTime.utc(2026, 8, 21).toIso8601String(),
      );
    },
  );

  test('given_an_applied_migration_when_migrations_run_again_then_keeps_one_version_record', () async {
    final database = _FakeDatabase();
    final runner = MigrationRunner(migrations: initialMigrations, clock: clock);
    await runner.migrate(database);

    await runner.migrate(database);

    expect(database.appliedVersions, {1});
  });

  test('given_a_failed_pending_migration_when_migrated_then_rolls_back_its_schema_and_version', () async {
    final database = _FakeDatabase();
    await MigrationRunner(
      migrations: initialMigrations,
      clock: clock,
    ).migrate(database);
    final migrations = [
      ...initialMigrations,
      const DatabaseMigration(
        version: 2,
        name: 'create transient probe',
        sql: 'CREATE TABLE transient_probe',
      ),
      const DatabaseMigration(
        version: 3,
        name: 'fail intentionally',
        sql: 'INVALID SQL',
      ),
    ];

    await expectLater(
      MigrationRunner(migrations: migrations, clock: clock).migrate(database),
      throwsA(isA<Exception>()),
    );

    expect(database.appliedVersions, {1});
    expect(database.tables, isNot(contains('transient_probe')));
  });

  test('given_duplicate_migration_versions_when_creating_a_runner_then_rejects_the_configuration', () {
    expect(
      () => MigrationRunner(
        clock: clock,
        migrations: [
          ...initialMigrations,
          const DatabaseMigration(
            version: 1,
            name: 'duplicate',
            sql: 'SELECT 1',
          ),
        ],
      ),
      throwsArgumentError,
    );
  });

  test(
    'given_an_unknown_persisted_schema_version_when_migrated_then_rejects_it',
    () async {
      final database = _FakeDatabase()..appliedVersions = {99};

      await expectLater(
        MigrationRunner(
          migrations: initialMigrations,
          clock: clock,
        ).migrate(database),
        throwsA(isA<DatabaseMigrationFailure>()),
      );
    },
  );

  test('given_version_one_when_version_two_is_available_then_applies_only_version_two', () async {
    final database = _FakeDatabase()..appliedVersions = {1};
    final migrations = [
      ...initialMigrations,
      const DatabaseMigration(
        version: 2,
        name: 'create telemetry events',
        sql: 'CREATE TABLE telemetry_events',
      ),
    ];

    await MigrationRunner(
      migrations: migrations,
      clock: clock,
    ).migrate(database);

    expect(database.appliedVersions, {1, 2});
    expect(database.tables, contains('telemetry_events'));
  });
}

final class _FakeDatabase implements AppDatabase {
  Set<int> appliedVersions = {};
  Map<int, String> appliedAtUtcByVersion = {};
  Set<String> tables = {};

  @override
  Future<void> close() async {}

  @override
  Future<int> currentSchemaVersion() async =>
      appliedVersions.isEmpty ? 0 : appliedVersions.last;

  @override
  Future<void> execute(
    String sql, {
    List<Object?> parameters = const [],
  }) async {
    if (sql == 'INVALID SQL') {
      throw const DatabaseOperationFailure(safeMessage: 'Invalid SQL');
    }
    if (sql.startsWith('CREATE TABLE')) {
      final tableName = sql.split(' ')[2];
      tables.add(tableName);
      return;
    }
    if (sql.startsWith('INSERT INTO schema_migrations')) {
      final version = parameters[0]! as int;
      appliedVersions = {...appliedVersions, version};
      appliedAtUtcByVersion = {
        ...appliedAtUtcByVersion,
        version: parameters[2]! as String,
      };
    }
  }

  @override
  Future<List<List<Object?>>> query(
    String sql, {
    List<Object?> parameters = const [],
  }) async {
    if (sql.startsWith('SELECT version FROM schema_migrations')) {
      return appliedVersions
          .map<List<Object?>>((version) => [version])
          .toList();
    }
    return [];
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(DatabaseTransaction transaction) action,
  ) async {
    final versionsBeforeTransaction = Set<int>.of(appliedVersions);
    final timestampsBeforeTransaction = Map<int, String>.of(
      appliedAtUtcByVersion,
    );
    final tablesBeforeTransaction = Set<String>.of(tables);
    try {
      return await action(this);
    } catch (_) {
      appliedVersions = versionsBeforeTransaction;
      appliedAtUtcByVersion = timestampsBeforeTransaction;
      tables = tablesBeforeTransaction;
      rethrow;
    }
  }
}

final class _FixedClock implements Clock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime nowUtc() => value;
}
