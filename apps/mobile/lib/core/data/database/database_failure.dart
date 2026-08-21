sealed class DatabaseFailure implements Exception {
  const DatabaseFailure(this.safeMessage, [this.cause]);

  final String safeMessage;
  final Object? cause;

  @override
  String toString() => safeMessage;
}

final class DatabaseOpenFailure extends DatabaseFailure {
  const DatabaseOpenFailure({required String safeMessage, Object? cause})
    : super(safeMessage, cause);
}

final class DatabaseMigrationFailure extends DatabaseFailure {
  const DatabaseMigrationFailure({
    required this.version,
    required String safeMessage,
    Object? cause,
  }) : super(safeMessage, cause);

  final int version;
}

final class DatabaseOperationFailure extends DatabaseFailure {
  const DatabaseOperationFailure({required String safeMessage, Object? cause})
    : super(safeMessage, cause);
}

final class DatabaseCloseFailure extends DatabaseFailure {
  const DatabaseCloseFailure({required String safeMessage, Object? cause})
    : super(safeMessage, cause);
}

final class DatabaseClosedFailure extends DatabaseFailure {
  const DatabaseClosedFailure()
    : super('The local database connection is already closed');
}
