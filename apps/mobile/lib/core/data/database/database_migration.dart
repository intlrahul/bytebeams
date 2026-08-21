final class DatabaseMigration {
  const DatabaseMigration({
    required this.version,
    required this.name,
    required this.sql,
  }) : assert(version > 0),
       assert(name != ''),
       assert(sql != '');

  final int version;
  final String name;
  final String sql;
}
