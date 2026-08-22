import { SqliteDemoRepository } from '../data/sqlite-demo-repository.js';

export interface DemoTransportService {
  bootstrap(): Readonly<Record<string, unknown>>;
  deliveriesAfter(cursor: string): readonly Record<string, unknown>[];
  replayGap(
    cursor: string,
  ): Readonly<{ oldestAvailableCursor: string; requestedCursor: string }> | null;
}

export class DemoService implements DemoTransportService {
  constructor(private readonly repository: SqliteDemoRepository) {}

  bootstrap(): Readonly<Record<string, unknown>> {
    const snapshot = this.repository.bootstrap();
    return {
      vehicles: snapshot.vehicles,
      telemetry: snapshot.telemetry.map(packetFromDelivery),
      deliveryCursor: snapshot.cursor,
    };
  }

  deliveriesAfter(cursor: string): readonly Record<string, unknown>[] {
    return this.repository.readAfter(cursor).map((row) => ({
      deliveryId: String(row.deliveryId),
      packet: packetFromDelivery(row),
    }));
  }

  replayGap(
    cursor: string,
  ): Readonly<{ oldestAvailableCursor: string; requestedCursor: string }> | null {
    const oldest = this.repository.oldestCursor();
    return oldest !== null && Number(cursor) < Number(oldest) - 1
      ? { oldestAvailableCursor: oldest, requestedCursor: cursor }
      : null;
  }
}

function packetFromDelivery(row: Record<string, unknown>): Readonly<Record<string, unknown>> {
  return {
    packetId: row.packetId,
    vehicleId: row.vehicleId,
    eventTimestamp: row.eventTimestamp,
    signalName: row.signalName,
    value: JSON.parse(String(row.valueJson)) as unknown,
    serverReceivedAt: row.serverReceivedAt,
  };
}
