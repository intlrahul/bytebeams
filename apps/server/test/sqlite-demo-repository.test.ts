import { mkdtempSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

import Database from 'better-sqlite3';
import { describe, expect, it } from 'vitest';

import { migrations } from '../src/data/migrations.js';
import { SqliteDemoRepository } from '../src/data/sqlite-demo-repository.js';
import { migrate } from '../src/data/sqlite-migrator.js';
import { createDemoPackets, createDemoVehicles } from '../src/domain/demo-fixtures.js';

describe('sqlite demo repository', () => {
  it('given_seeded_sqlite_when_reopened_then_preserves_delivery_cursor', () => {
    const path = join(mkdtempSync(join(tmpdir(), 'bytebeams-')), 'demo.sqlite');
    const first = new Database(path);
    migrate(first, migrations);
    const vehicles = createDemoVehicles('seed', 1);
    new SqliteDemoRepository(first).seed(
      vehicles,
      createDemoPackets(vehicles, new Date('2026-08-21T00:00:00Z')),
      '2026-08-21T00:00:00Z',
    );
    const cursor = new SqliteDemoRepository(first).cursor();
    first.close();
    const reopened = new Database(path);
    migrate(reopened, migrations);
    expect(new SqliteDemoRepository(reopened).cursor()).toBe(cursor);
    reopened.close();
  });

  it('given_seeded_sqlite_when_bootstrap_and_replay_read_then_returns_consistent_rows', () => {
    const database = new Database(':memory:');
    migrate(database, migrations);
    const vehicles = createDemoVehicles('seed', 2);
    const repository = new SqliteDemoRepository(database);
    repository.seed(
      vehicles,
      createDemoPackets(vehicles, new Date('2026-08-21T00:00:00Z')),
      '2026-08-21T00:00:00Z',
    );
    const snapshot = repository.bootstrap();
    expect(snapshot.vehicles).toHaveLength(2);
    expect(snapshot.telemetry).toHaveLength(6);
    expect(repository.readAfter('0')).toHaveLength(6);
    expect(repository.oldestCursor()).toBe('1');
    database.close();
  });

  it('given_an_empty_log_when_oldest_cursor_read_then_returns_null', () => {
    const database = new Database(':memory:');
    migrate(database, migrations);
    expect(new SqliteDemoRepository(database).oldestCursor()).toBeNull();
    database.close();
  });
});
