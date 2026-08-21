import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/core/data/database/database_failure.dart';
import 'package:bytebeams/core/data/database/database_migration.dart';
import 'package:bytebeams/core/time/clock.dart';

final class MigrationRunner {
  factory MigrationRunner({
    required List<DatabaseMigration> migrations,
    required Clock clock,
  }) {
    final runner = MigrationRunner._(migrations: migrations, clock: clock);
    final versions = runner._migrations
        .map((migration) => migration.version)
        .toSet();
    if (versions.length != runner._migrations.length) {
      throw ArgumentError.value(
        migrations,
        'migrations',
        'Migration versions must be unique',
      );
    }
    return runner;
  }

  MigrationRunner._({
    required List<DatabaseMigration> migrations,
    required this._clock,
  }) : _migrations = List.unmodifiable(
         [...migrations]
           ..sort((left, right) => left.version.compareTo(right.version)),
       );

  final List<DatabaseMigration> _migrations;
  final Clock _clock;

  Future<int> migrate(AppDatabase database) async {
    try {
      return await database.transaction((transaction) async {
        await transaction.execute(_createSchemaMigrationsSql);
        final appliedVersions = await _appliedVersions(transaction);
        _validateKnownVersions(appliedVersions);

        for (final migration in _migrations) {
          if (appliedVersions.contains(migration.version)) {
            continue;
          }

          try {
            await transaction.execute(migration.sql);
            await transaction.execute(
              'INSERT INTO schema_migrations (version, name, applied_at_utc) VALUES (?, ?, ?)',
              parameters: [
                migration.version,
                migration.name,
                _clock.nowUtc().toIso8601String(),
              ],
            );
          } on DatabaseFailure catch (failure) {
            throw DatabaseMigrationFailure(
              version: migration.version,
              safeMessage:
                  'Migration ${migration.version} could not be applied',
              cause: failure,
            );
          }
        }

        return _migrations.isEmpty ? 0 : _migrations.last.version;
      });
    } on DatabaseMigrationFailure {
      rethrow;
    } on DatabaseFailure catch (failure) {
      throw DatabaseMigrationFailure(
        version: _migrations.isEmpty ? 0 : _migrations.last.version,
        safeMessage: 'The local database migration could not complete',
        cause: failure,
      );
    }
  }

  Future<Set<int>> _appliedVersions(DatabaseTransaction transaction) async {
    final rows = await transaction.query(
      'SELECT version FROM schema_migrations ORDER BY version ASC',
    );
    return rows.map((row) => (row.single as num).toInt()).toSet();
  }

  void _validateKnownVersions(Set<int> appliedVersions) {
    final knownVersions = _migrations
        .map((migration) => migration.version)
        .toSet();
    final unsupportedVersion = appliedVersions.cast<int?>().firstWhere(
      (version) => !knownVersions.contains(version),
      orElse: () => null,
    );
    if (unsupportedVersion != null) {
      throw DatabaseMigrationFailure(
        version: unsupportedVersion,
        safeMessage: 'The local database uses an unsupported schema version',
      );
    }
  }
}

const _createSchemaMigrationsSql = '''
CREATE TABLE IF NOT EXISTS schema_migrations (
  version INTEGER PRIMARY KEY,
  name VARCHAR NOT NULL,
  applied_at_utc TIMESTAMPTZ NOT NULL
)
''';
