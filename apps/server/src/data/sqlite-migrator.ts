import type Database from 'better-sqlite3';

export type SqliteMigration = Readonly<{ version: number; sql: string }>;

export function migrate(database: Database.Database, migrations: readonly SqliteMigration[]): void {
  database.exec('CREATE TABLE IF NOT EXISTS schema_migrations (version INTEGER PRIMARY KEY)');
  const applied = new Set<number>(
    database
      .prepare('SELECT version FROM schema_migrations')
      .all()
      .map((row) => (row as { version: number }).version),
  );
  const apply = database.transaction(() => {
    for (const migration of migrations.toSorted((left, right) => left.version - right.version)) {
      if (applied.has(migration.version)) continue;
      database.exec(migration.sql);
      database.prepare('INSERT INTO schema_migrations (version) VALUES (?)').run(migration.version);
    }
  });
  apply();
}
