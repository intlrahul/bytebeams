import { mkdirSync } from 'node:fs';
import { dirname } from 'node:path';

import Database from 'better-sqlite3';

import { createApp } from './app.js';
import { readServerConfig } from './config.js';
import { migrations } from './data/migrations.js';
import { SqliteDemoRepository } from './data/sqlite-demo-repository.js';
import { migrate } from './data/sqlite-migrator.js';
import { createDemoPackets, createDemoVehicles } from './domain/demo-fixtures.js';
import { DemoService } from './domain/demo-service.js';
import { SseConnectionRegistry } from './transport/sse-connection-registry.js';

const config = readServerConfig(process.env);
mkdirSync(dirname(config.databasePath), { recursive: true });
const database = new Database(config.databasePath);
migrate(database, migrations);
const repository = new SqliteDemoRepository(database);
const vehicles = createDemoVehicles(config.demoSeed);
repository.seed(
  vehicles,
  createDemoPackets(vehicles, config.demoStartAtUtc),
  config.demoStartAtUtc.toISOString(),
);
const service = new DemoService(repository, config.demoStartAtUtc);
const sseConnections = new SseConnectionRegistry();
const app = createApp(service, sseConnections);

setInterval(() => {
  sseConnections.broadcast(service.publishNextDelivery());
}, config.simulationIntervalMs).unref();

app.listen(config.port, () => {
  process.stdout.write(`ByteBeams demo server listening on port ${String(config.port)}\n`);
});
