import type Database from 'better-sqlite3';

import type { DemoPacket, DemoVehicle } from '../domain/demo-fixtures.js';

export class SqliteDemoRepository {
  constructor(private readonly database: Database.Database) {}

  seed(vehicles: readonly DemoVehicle[], packets: readonly DemoPacket[], nowUtc: string): void {
    const write = this.database.transaction(() => {
      const vehicle = this.database.prepare(
        'INSERT OR IGNORE INTO vehicles (vehicle_id, registration_number, model) VALUES (?, ?, ?)',
      );
      const telemetry = this.database.prepare(
        'INSERT OR IGNORE INTO telemetry_packets (packet_id, vehicle_id, event_timestamp, signal_name, value_json, server_received_at) VALUES (?, ?, ?, ?, ?, ?)',
      );
      const delivery = this.database.prepare(
        'INSERT OR IGNORE INTO delivery_log (packet_id, created_at) VALUES (?, ?)',
      );
      for (const item of vehicles) vehicle.run(item.vehicleId, item.registrationNumber, item.model);
      for (const item of packets) {
        telemetry.run(
          item.packetId,
          item.vehicleId,
          item.eventTimestamp,
          item.signalName,
          JSON.stringify(item.value),
          nowUtc,
        );
        delivery.run(item.packetId, nowUtc);
      }
      this.prune(nowUtc);
    });
    write();
  }

  cursor(): string {
    return String(
      (
        this.database
          .prepare('SELECT COALESCE(MAX(delivery_id), 0) AS cursor FROM delivery_log')
          .get() as { cursor: number }
      ).cursor,
    );
  }

  bootstrap(): Readonly<{
    cursor: string;
    telemetry: readonly Record<string, unknown>[];
    vehicles: readonly Record<string, unknown>[];
  }> {
    const snapshot = this.database.transaction(() => ({
      cursor: this.cursor(),
      vehicles: this.database
        .prepare(
          'SELECT vehicle_id AS vehicleId, registration_number AS registrationNumber, model FROM vehicles ORDER BY vehicle_id',
        )
        .all() as readonly Record<string, unknown>[],
      telemetry: this.readAfter('0'),
    }));
    return snapshot();
  }

  readAfter(cursor: string): readonly Record<string, unknown>[] {
    return this.database
      .prepare(
        'SELECT d.delivery_id AS deliveryId, t.packet_id AS packetId, t.vehicle_id AS vehicleId, t.event_timestamp AS eventTimestamp, t.signal_name AS signalName, t.value_json AS valueJson, t.server_received_at AS serverReceivedAt FROM delivery_log d JOIN telemetry_packets t ON t.packet_id = d.packet_id WHERE d.delivery_id > ? ORDER BY d.delivery_id',
      )
      .all(Number(cursor)) as readonly Record<string, unknown>[];
  }

  simulatorState(key: string): string | null {
    const row = this.database
      .prepare('SELECT value FROM simulator_state WHERE key = ?')
      .get(key) as { value: string } | undefined;
    return row?.value ?? null;
  }

  appendPacketsAndSetSimulatorState(
    packets: readonly DemoPacket[],
    nowUtc: string,
    stateKey: string,
    stateValue: string,
  ): readonly Record<string, unknown>[] {
    const write = this.database.transaction(() => {
      const telemetry = this.database.prepare(
        'INSERT INTO telemetry_packets (packet_id, vehicle_id, event_timestamp, signal_name, value_json, server_received_at) VALUES (?, ?, ?, ?, ?, ?)',
      );
      const delivery = this.database.prepare(
        'INSERT INTO delivery_log (packet_id, created_at) VALUES (?, ?)',
      );
      const read = this.database.prepare(
        'SELECT d.delivery_id AS deliveryId, t.packet_id AS packetId, t.vehicle_id AS vehicleId, t.event_timestamp AS eventTimestamp, t.signal_name AS signalName, t.value_json AS valueJson, t.server_received_at AS serverReceivedAt FROM delivery_log d JOIN telemetry_packets t ON t.packet_id = d.packet_id WHERE d.delivery_id = ?',
      );
      const rows: Record<string, unknown>[] = [];
      for (const packet of packets) {
        telemetry.run(
          packet.packetId,
          packet.vehicleId,
          packet.eventTimestamp,
          packet.signalName,
          JSON.stringify(packet.value),
          nowUtc,
        );
        const result = delivery.run(packet.packetId, nowUtc);
        const row = read.get(result.lastInsertRowid) as Record<string, unknown> | undefined;
        if (row === undefined) {
          throw new Error('Newly persisted demo delivery could not be read');
        }
        rows.push(row);
      }
      this.database
        .prepare(
          'INSERT INTO simulator_state (key, value) VALUES (?, ?) ON CONFLICT(key) DO UPDATE SET value = excluded.value',
        )
        .run(stateKey, stateValue);
      this.prune(nowUtc);
      return rows;
    });
    return write();
  }

  oldestCursor(): string | null {
    const row = this.database
      .prepare('SELECT MIN(delivery_id) AS cursor FROM delivery_log')
      .get() as { cursor: number | null };
    return row.cursor === null ? null : String(row.cursor);
  }

  prune(nowUtc: string): void {
    this.database
      .prepare("DELETE FROM delivery_log WHERE created_at < datetime(?, '-7 days')")
      .run(nowUtc);
    this.database
      .prepare(
        'DELETE FROM delivery_log WHERE delivery_id <= (SELECT COALESCE(MAX(delivery_id), 0) - 10000 FROM delivery_log)',
      )
      .run();
  }
}
