import { mkdtempSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

import Database from 'better-sqlite3';
import { describe, expect, it } from 'vitest';

import { migrations } from '../src/data/migrations.js';
import { SqliteDemoRepository } from '../src/data/sqlite-demo-repository.js';
import { migrate } from '../src/data/sqlite-migrator.js';
import { createDemoPackets, createDemoVehicles } from '../src/domain/demo-fixtures.js';
import { DemoService } from '../src/domain/demo-service.js';

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
    const packets = createDemoPackets(vehicles, new Date('2026-08-21T00:00:00Z'));
    expect(snapshot.telemetry).toHaveLength(packets.length);
    expect(repository.readAfter('0')).toHaveLength(packets.length);
    expect(repository.oldestCursor()).toBe('1');
    database.close();
  });

  it('given_an_empty_log_when_oldest_cursor_read_then_returns_null', () => {
    const database = new Database(':memory:');
    migrate(database, migrations);
    expect(new SqliteDemoRepository(database).oldestCursor()).toBeNull();
    database.close();
  });

  it('given_seeded_sqlite_when_live_delivery_published_then_persists_and_replays_it', () => {
    const database = new Database(':memory:');
    migrate(database, migrations);
    const vehicles = createDemoVehicles('seed', 1);
    const repository = new SqliteDemoRepository(database);
    repository.seed(
      vehicles,
      createDemoPackets(vehicles, new Date('2026-08-21T00:00:00Z')),
      '2026-08-21T00:00:00Z',
    );
    const service = new DemoService(repository, new Date('2026-08-21T00:00:00Z'));
    const initialCursor = repository.cursor();

    const deliveries = service.publishNextDeliveries();

    expect(deliveries.map((delivery) => delivery.deliveryId)).toEqual([
      String(Number(initialCursor) + 1),
      String(Number(initialCursor) + 2),
    ]);
    expect(repository.cursor()).toBe(deliveries[1]?.deliveryId);
    expect(repository.readAfter(initialCursor)).toHaveLength(2);
    database.close();
  });

  it('given_a_large_bootstrap_cursor_when_live_delivery_published_then_timestamp_starts_at_live_sequence', () => {
    // Given
    const database = new Database(':memory:');
    migrate(database, migrations);
    const startAtUtc = new Date('2026-08-21T00:00:00.000Z');
    const vehicles = createDemoVehicles('seed', 500);
    const repository = new SqliteDemoRepository(database);
    repository.seed(vehicles, createDemoPackets(vehicles, startAtUtc), startAtUtc.toISOString());
    const initialCursor = repository.cursor();
    const service = new DemoService(repository, startAtUtc);

    // When
    const deliveries = service.publishNextDeliveries();

    // Then
    expect(Number(initialCursor)).toBeGreaterThan(300);
    expect(deliveries).toMatchObject([
      {
        deliveryId: String(Number(initialCursor) + 1),
        packet: {
          packetId: 'live:ping:0',
          eventTimestamp: '2026-08-21T00:00:01.000Z',
        },
      },
      {
        deliveryId: String(Number(initialCursor) + 2),
        packet: {
          packetId: 'live:location:0',
          eventTimestamp: '2026-08-21T00:00:01.000Z',
        },
      },
    ]);
    const restarted = new DemoService(repository, startAtUtc);
    expect(restarted.publishNextDeliveries()[1]).toMatchObject({
      packet: { packetId: 'live:location:1' },
    });
    database.close();
  });
});
