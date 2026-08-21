abstract interface class DatabaseTransaction {
  Future<void> execute(String sql, {List<Object?> parameters = const []});

  Future<List<List<Object?>>> query(
    String sql, {
    List<Object?> parameters = const [],
  });
}

abstract interface class AppDatabase implements DatabaseTransaction {
  Future<T> transaction<T>(
    Future<T> Function(DatabaseTransaction transaction) action,
  );

  Future<int> currentSchemaVersion();

  Future<void> close();
}
