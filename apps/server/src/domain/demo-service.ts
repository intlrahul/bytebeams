import { SqliteDemoRepository } from '../data/sqlite-demo-repository.js';
import {
  createLiveVehicleTelemetry,
  type DemoVehicleSimulatorStates,
} from './demo-location-scenarios.js';

export interface DemoTransportService {
  bootstrap(): Readonly<Record<string, unknown>>;
  deliveriesAfter(cursor: string): readonly Record<string, unknown>[];
  replayGap(
    cursor: string,
  ): Readonly<{ oldestAvailableCursor: string; requestedCursor: string }> | null;
  publishNextDeliveries(): readonly Readonly<Record<string, unknown>>[];
}

export class DemoService implements DemoTransportService {
  private sessionTick = 0;

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

  publishNextDeliveries(): readonly Readonly<Record<string, unknown>>[] {
    const state = this.liveSimulatorState();
    this.sessionTick += 1;
    const eventTimestamp = new Date(
      this.startAtUtc.getTime() + this.sessionTick * 1000,
    ).toISOString();
    const vehicleNumber = String((state.pingStep % 495) + 6).padStart(3, '0');
    const telemetry = createLiveVehicleTelemetry(
      state.locationStep,
      eventTimestamp,
      state.vehicles,
    );
    const packets = [
      {
        packetId: `live:ping:${String(state.pingStep)}`,
        vehicleId: `vehicle-${vehicleNumber}`,
        eventTimestamp,
        signalName: 'last_ping',
        value: { kind: 'boolean', booleanValue: true },
      },
      ...telemetry.packets,
    ];
    const deliveries = this.repository.appendPacketsAndSetSimulatorState(
      packets,
      eventTimestamp,
      'live_simulation',
      JSON.stringify({
        pingStep: state.pingStep + 1,
        locationStep: state.locationStep + 1,
        vehicles: telemetry.states,
      }),
    );
    return deliveries.map((delivery) => ({
      deliveryId: String(delivery.deliveryId),
      packet: packetFromDelivery(delivery),
    }));
  }

  private liveSimulatorState(): Readonly<{
    locationStep: number;
    pingStep: number;
    vehicles: DemoVehicleSimulatorStates;
  }> {
    const persisted = this.repository.simulatorState('live_simulation');
    if (persisted === null) return { locationStep: 0, pingStep: 0, vehicles: {} };
    const parsed = JSON.parse(persisted) as Partial<{
      locationStep: number;
      pingStep: number;
      vehicles: DemoVehicleSimulatorStates;
    }>;
    return {
      locationStep: parsed.locationStep ?? 0,
      pingStep: parsed.pingStep ?? 0,
      vehicles: parsed.vehicles ?? {},
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
