import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/core/data/database/database_failure.dart';
import 'package:bytebeams/core/data/database/database_migration.dart';
import 'package:bytebeams/core/data/database/migration_runner.dart';
import 'package:bytebeams/core/time/clock.dart';
import 'package:dart_duckdb/dart_duckdb.dart' as duckdb;

abstract interface class DuckDbDriver {
  Future<duckdb.Database> open(String path);

  Future<duckdb.Connection> connect(duckdb.Database database);
}

final class NativeDuckDbDriver implements DuckDbDriver {
  const NativeDuckDbDriver();

  @override
  Future<duckdb.Connection> connect(duckdb.Database database) {
    return duckdb.duckdb.connect(database);
  }

  @override
  Future<duckdb.Database> open(String path) {
    return duckdb.duckdb.open(path);
  }
}

final class DuckDbAppDatabase implements AppDatabase {
  DuckDbAppDatabase._(this._database, this._connection);

  final duckdb.Database _database;
  final duckdb.Connection _connection;
  final _OperationQueue _queue = _OperationQueue();
  var _isClosed = false;

  static Future<DuckDbAppDatabase> open({
    required String path,
    required List<DatabaseMigration> migrations,
    required Clock clock,
    DuckDbDriver driver = const NativeDuckDbDriver(),
  }) async {
    duckdb.Database? database;
    duckdb.Connection? connection;

    try {
      database = await driver.open(path);
      connection = await driver.connect(database);
      final appDatabase = DuckDbAppDatabase._(database, connection);
      await MigrationRunner(
        migrations: migrations,
        clock: clock,
      ).migrate(appDatabase);
      return appDatabase;
    } on DatabaseFailure {
      await _disposeQuietly(connection, database);
      rethrow;
    } catch (error) {
      await _disposeQuietly(connection, database);
      throw DatabaseOpenFailure(
        safeMessage: 'The local database could not be opened',
        cause: error,
      );
    }
  }

  /// Creates an adapter around owned handles for deterministic adapter tests.
  factory DuckDbAppDatabase.withHandlesForTesting({
    required duckdb.Database database,
    required duckdb.Connection connection,
  }) {
    return DuckDbAppDatabase._(database, connection);
  }

  static Future<void> _disposeQuietly(
    duckdb.Connection? connection,
    duckdb.Database? database,
  ) async {
    try {
      await connection?.dispose();
    } catch (_) {
      // The original open or migration failure remains the useful diagnostic.
    }
    try {
      await database?.dispose();
    } catch (_) {
      // The original open or migration failure remains the useful diagnostic.
    }
  }

  @override
  Future<void> execute(String sql, {List<Object?> parameters = const []}) {
    return _queue.run(() async {
      _ensureOpen();
      return _executeWith(_connection, sql, parameters);
    });
  }

  @override
  Future<List<List<Object?>>> query(
    String sql, {
    List<Object?> parameters = const [],
  }) {
    return _queue.run(() async {
      _ensureOpen();
      return _queryWith(_connection, sql, parameters);
    });
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(DatabaseTransaction transaction) action,
  ) {
    return _queue.run(() async {
      _ensureOpen();
      try {
        await _connection.execute('BEGIN TRANSACTION');
        final result = await action(_DuckDbTransaction(_connection));
        await _connection.execute('COMMIT');
        return result;
      } on DatabaseFailure {
        await _rollbackQuietly();
        rethrow;
      } catch (error) {
        await _rollbackQuietly();
        throw DatabaseOperationFailure(
          safeMessage: 'The local database transaction could not complete',
          cause: error,
        );
      }
    });
  }

  @override
  Future<int> currentSchemaVersion() async {
    final rows = await query(
      'SELECT COALESCE(MAX(version), 0) FROM schema_migrations',
    );
    return (rows.single.single as num).toInt();
  }

  @override
  Future<void> close() {
    return _queue.run(() async {
      if (_isClosed) {
        return;
      }
      try {
        await _connection.dispose();
        await _database.dispose();
        _isClosed = true;
      } catch (error) {
        throw DatabaseCloseFailure(
          safeMessage: 'The local database could not be closed',
          cause: error,
        );
      }
    });
  }

  Future<void> _rollbackQuietly() async {
    try {
      await _connection.execute('ROLLBACK');
    } catch (_) {
      // Preserve the operation failure that caused rollback.
    }
  }

  void _ensureOpen() {
    if (_isClosed) {
      throw const DatabaseClosedFailure();
    }
  }
}

final class _DuckDbTransaction implements DatabaseTransaction {
  const _DuckDbTransaction(this._connection);

  final duckdb.Connection _connection;

  @override
  Future<void> execute(String sql, {List<Object?> parameters = const []}) {
    return _executeWith(_connection, sql, parameters);
  }

  @override
  Future<List<List<Object?>>> query(
    String sql, {
    List<Object?> parameters = const [],
  }) {
    return _queryWith(_connection, sql, parameters);
  }
}

Future<void> _executeWith(
  duckdb.Connection connection,
  String sql,
  List<Object?> parameters,
) async {
  try {
    if (parameters.isEmpty) {
      await connection.execute(sql);
      return;
    }

    final statement = await connection.prepare(sql);
    try {
      statement.bindParams(parameters);
      final result = await statement.execute();
      await result.dispose();
    } finally {
      await statement.dispose();
    }
  } catch (error) {
    throw DatabaseOperationFailure(
      safeMessage: 'A local database statement could not be executed',
      cause: error,
    );
  }
}

Future<List<List<Object?>>> _queryWith(
  duckdb.Connection connection,
  String sql,
  List<Object?> parameters,
) async {
  duckdb.ResultSet? result;
  duckdb.PreparedStatement? statement;
  try {
    if (parameters.isEmpty) {
      result = await connection.query(sql);
    } else {
      statement = await connection.prepare(sql);
      statement.bindParams(parameters);
      result = await statement.execute();
    }
    return result.fetchAll();
  } catch (error) {
    throw DatabaseOperationFailure(
      safeMessage: 'A local database query could not be executed',
      cause: error,
    );
  } finally {
    await result?.dispose();
    await statement?.dispose();
  }
}

final class _OperationQueue {
  Future<void> _tail = Future.value();

  Future<T> run<T>(Future<T> Function() operation) {
    final result = _tail.then((_) => operation());
    _tail = result.then<void>((_) {}, onError: (_, _) {});
    return result;
  }
}
