import type { SqliteMigration } from './sqlite-migrator.js';

export const migrations: readonly SqliteMigration[] = [
  {
    version: 1,
    sql: `
CREATE TABLE vehicles (vehicle_id TEXT PRIMARY KEY, registration_number TEXT NOT NULL, model TEXT NOT NULL);
CREATE TABLE telemetry_packets (packet_id TEXT PRIMARY KEY, vehicle_id TEXT NOT NULL, event_timestamp TEXT NOT NULL, signal_name TEXT NOT NULL, value_json TEXT NOT NULL, server_received_at TEXT NOT NULL);
CREATE TABLE delivery_log (delivery_id INTEGER PRIMARY KEY AUTOINCREMENT, packet_id TEXT NOT NULL UNIQUE, created_at TEXT NOT NULL);
CREATE TABLE simulator_state (key TEXT PRIMARY KEY, value TEXT NOT NULL);
`,
  },
];
