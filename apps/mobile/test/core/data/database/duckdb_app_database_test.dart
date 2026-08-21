import 'package:bytebeams/core/data/database/database_failure.dart';
import 'package:bytebeams/core/data/database/database_migration.dart';
import 'package:bytebeams/core/data/database/duckdb_app_database.dart';
import 'package:bytebeams/core/time/clock.dart';
import 'package:dart_duckdb/dart_duckdb.dart' as duckdb;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'given_an_open_driver_when_opening_then_migrates_and_returns_a_database',
    () async {
      final database = _FakeDatabase();
      final connection = _FakeConnection();
      final driver = _FakeDriver(database: database, connection: connection);

      final appDatabase = await DuckDbAppDatabase.open(
        path: 'app.duckdb',
        migrations: [
          const DatabaseMigration(
            version: 1,
            name: 'schema',
            sql: 'CREATE TABLE demo',
          ),
        ],
        clock: _FixedClock(),
        driver: driver,
      );

      expect(driver.openedPaths, ['app.duckdb']);
      expect(connection.executedSql, contains('CREATE TABLE demo'));
      await appDatabase.close();
    },
  );

  test('given_a_parameterized_statement_when_executed_then_binds_and_disposes_resources', () async {
    final connection = _FakeConnection();
    final appDatabase = _database(connection);

    await appDatabase.execute(
      'INSERT INTO demo VALUES (?)',
      parameters: ['value'],
    );

    expect(connection.statement.boundParameters, ['value']);
    expect(connection.statement.disposed, isTrue);
    expect(connection.statement.result.disposed, isTrue);
  });

  test(
    'given_a_query_when_read_then_returns_rows_and_disposes_its_result',
    () async {
      final connection = _FakeConnection(
        queryRows: [
          [1, 'vehicle'],
        ],
      );
      final appDatabase = _database(connection);

      final rows = await appDatabase.query('SELECT * FROM vehicle');

      expect(rows, [
        [1, 'vehicle'],
      ]);
      expect(connection.queryResult.disposed, isTrue);
    },
  );

  test(
    'given_a_parameterized_query_when_read_then_binds_and_disposes_resources',
    () async {
      final connection = _FakeConnection();

      await _database(connection)
          .query('SELECT * FROM vehicle WHERE id = ?', parameters: [7]);

      expect(connection.statement.boundParameters, [7]);
      expect(connection.statement.disposed, isTrue);
      expect(connection.statement.result.disposed, isTrue);
    },
  );

  test('given_an_applied_schema_when_reading_version_then_returns_its_numeric_value', () async {
    final connection = _FakeConnection(
      queryRows: [
        [3],
      ],
    );

    expect(await _database(connection).currentSchemaVersion(), 3);
  });

  test('given_a_failed_transaction_when_run_then_rolls_back_and_returns_a_safe_failure', () async {
    final connection = _FakeConnection();
    final appDatabase = _database(connection);

    await expectLater(
      appDatabase.transaction<void>((_) => throw StateError('boom')),
      throwsA(isA<DatabaseOperationFailure>()),
    );

    expect(connection.executedSql, ['BEGIN TRANSACTION', 'ROLLBACK']);
  });

  test(
    'given_a_database_failure_in_a_transaction_when_run_then_preserves_it',
    () async {
      final connection = _FakeConnection();

      await expectLater(
        _database(connection).transaction<void>(
          (_) => throw const DatabaseOperationFailure(safeMessage: 'expected'),
        ),
        throwsA(isA<DatabaseOperationFailure>()),
      );

      expect(connection.executedSql, ['BEGIN TRANSACTION', 'ROLLBACK']);
    },
  );

  test(
    'given_a_statement_failure_when_executed_then_returns_a_safe_failure',
    () async {
      await expectLater(
        _database(_FakeConnection(failExecute: true))
            .execute('UPDATE vehicle SET soc = 20'),
        throwsA(isA<DatabaseOperationFailure>()),
      );
    },
  );

  test(
    'given_a_closed_database_when_used_then_rejects_the_operation',
    () async {
      final connection = _FakeConnection();
      final database = _FakeDatabase();
      final appDatabase = DuckDbAppDatabase.withHandlesForTesting(
        database: database,
        connection: connection,
      );

      await appDatabase.close();
      await appDatabase.close();

      await expectLater(
        appDatabase.execute('SELECT 1'),
        throwsA(isA<DatabaseClosedFailure>()),
      );
      expect(connection.disposed, isTrue);
      expect(database.disposed, isTrue);
    },
  );

  test(
    'given_a_driver_open_failure_when_opening_then_returns_a_safe_open_failure',
    () async {
      await expectLater(
        DuckDbAppDatabase.open(
          path: 'app.duckdb',
          migrations: const [],
          clock: _FixedClock(),
          driver: _FailingDriver(),
        ),
        throwsA(isA<DatabaseOpenFailure>()),
      );
    },
  );

  test(
    'given_a_close_failure_when_closing_then_returns_a_safe_close_failure',
    () async {
      final appDatabase = DuckDbAppDatabase.withHandlesForTesting(
        database: _FakeDatabase(),
        connection: _FakeConnection(failDispose: true),
      );

      await expectLater(
        appDatabase.close(),
        throwsA(isA<DatabaseCloseFailure>()),
      );
    },
  );

  test('given_the_system_clock_when_read_then_produces_a_utc_timestamp', () {
    expect(const SystemClock().nowUtc().isUtc, isTrue);
  });
}

DuckDbAppDatabase _database(_FakeConnection connection) {
  return DuckDbAppDatabase.withHandlesForTesting(
    database: _FakeDatabase(),
    connection: connection,
  );
}

final class _FakeDriver implements DuckDbDriver {
  _FakeDriver({required this.database, required this.connection});

  final duckdb.Database database;
  final duckdb.Connection connection;
  final List<String> openedPaths = [];

  @override
  Future<duckdb.Connection> connect(duckdb.Database database) async =>
      connection;

  @override
  Future<duckdb.Database> open(String path) async {
    openedPaths.add(path);
    return database;
  }
}

final class _FailingDriver implements DuckDbDriver {
  @override
  Future<duckdb.Connection> connect(duckdb.Database database) =>
      throw UnimplementedError();

  @override
  Future<duckdb.Database> open(String path) => throw StateError('unavailable');
}

final class _FakeDatabase implements duckdb.Database {
  var disposed = false;

  @override
  Future<void> dispose() async => disposed = true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _FakeConnection implements duckdb.Connection {
  _FakeConnection({
    List<List<Object?>> queryRows = const [],
    this.failDispose = false,
    this.failExecute = false,
  }) : queryResult = _FakeResultSet(queryRows);

  final List<String> executedSql = [];
  final _FakePreparedStatement statement = _FakePreparedStatement();
  final _FakeResultSet queryResult;
  final bool failDispose;
  final bool failExecute;
  var disposed = false;

  @override
  Future<void> dispose() async {
    if (failDispose) {
      throw StateError('could not dispose');
    }
    disposed = true;
  }

  @override
  Future<void> execute(
    String query, {
    duckdb.DuckDBCancellationToken? token,
  }) async {
    if (failExecute) {
      throw StateError('could not execute');
    }
    executedSql.add(query);
  }

  @override
  Future<duckdb.PreparedStatement> prepare(String query) async => statement;

  @override
  Future<duckdb.ResultSet> query(
    String query, {
    duckdb.DuckDBCancellationToken? token,
  }) async => queryResult;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _FakePreparedStatement implements duckdb.PreparedStatement {
  final _FakeResultSet result = _FakeResultSet(const []);
  List<Object?> boundParameters = const [];
  var disposed = false;

  @override
  void bindParams(List params) {
    boundParameters = List<Object?>.from(params);
  }

  @override
  Future<void> dispose() async => disposed = true;

  @override
  Future<duckdb.ResultSet> execute({
    duckdb.DuckDBCancellationToken? token,
  }) async => result;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _FakeResultSet implements duckdb.ResultSet {
  _FakeResultSet(this.rows);

  final List<List<Object?>> rows;
  var disposed = false;

  @override
  List<List<Object?>> fetchAll({int? batchSize}) => rows;

  @override
  Future<void> dispose() async => disposed = true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _FixedClock implements Clock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 8, 21);
}
