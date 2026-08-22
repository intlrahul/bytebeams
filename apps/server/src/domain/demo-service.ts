import { SqliteDemoRepository } from '../data/sqlite-demo-repository.js';

export interface DemoTransportService {
  bootstrap(): Readonly<Record<string, unknown>>;
  deliveriesAfter(cursor: string): readonly Record<string, unknown>[];
  replayGap(
    cursor: string,
  ): Readonly<{ oldestAvailableCursor: string; requestedCursor: string }> | null;
  publishNextDelivery(): Readonly<Record<string, unknown>>;
}

export class DemoService implements DemoTransportService {
  constructor(
    private readonly repository: SqliteDemoRepository,
    private readonly startAtUtc: Date,
  ) {}

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

  publishNextDelivery(): Readonly<Record<string, unknown>> {
    const sequence = Number(this.repository.cursor()) + 1;
    const vehicleNumber = String(((sequence - 1) % 500) + 1).padStart(3, '0');
    const eventTimestamp = new Date(this.startAtUtc.getTime() + sequence * 1000).toISOString();
    const delivery = this.repository.appendPacket(
      {
        packetId: `live:${String(sequence)}`,
        vehicleId: `vehicle-${vehicleNumber}`,
        eventTimestamp,
        signalName: 'last_ping',
        value: { kind: 'boolean', booleanValue: true },
      },
      eventTimestamp,
    );
    return {
      deliveryId: String(delivery.deliveryId),
      packet: packetFromDelivery(delivery),
    };
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
