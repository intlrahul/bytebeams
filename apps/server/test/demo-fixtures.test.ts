import { describe, expect, it } from 'vitest';

import { createDemoPackets, createDemoVehicles } from '../src/domain/demo-fixtures.js';

describe('demo fixtures', () => {
  it('given_the_same_seed_when_vehicles_are_created_then_returns_500_identical_vehicles', () => {
    const first = createDemoVehicles('bytebeams-demo-v1');
    const second = createDemoVehicles('bytebeams-demo-v1');
    expect(first).toHaveLength(500);
    expect(second).toEqual(first);
  });

  it('given_the_same_vehicles_and_clock_when_packets_are_created_then_returns_identical_packets', () => {
    const vehicles = createDemoVehicles('bytebeams-demo-v1');
    const start = new Date('2026-08-21T00:00:00Z');
    expect(createDemoPackets(vehicles, start)).toEqual(createDemoPackets(vehicles, start));
  });

  it('given_demo_fixtures_when_created_then_produces_the_documented_status_mix', () => {
    const start = new Date('2026-08-22T12:00:00Z');
    const packets = createDemoPackets(createDemoVehicles('bytebeams-demo-v1'), start);
    const byVehicle = new Map<string, readonly (typeof packets)[number][]>();
    for (const packet of packets) {
      byVehicle.set(packet.vehicleId, [...(byVehicle.get(packet.vehicleId) ?? []), packet]);
    }
    const statuses = [...byVehicle.values()].map((vehiclePackets) => {
      const ping = vehiclePackets.find((packet) => packet.signalName === 'last_ping');
      const speed = vehiclePackets.find((packet) => packet.signalName === 'speed');
      if (ping === undefined || speed === undefined) {
        throw new Error('Each demo vehicle must have last_ping and speed signals');
      }
      const ignition = vehiclePackets.find((packet) => packet.signalName === 'ignition');
      return new Date(ping.eventTimestamp).getTime() < start.getTime() - 10 * 60_000
        ? 'offline'
        : (speed.value as { numberValue: number }).numberValue > 0
          ? 'moving'
          : (ignition?.value as { booleanValue?: boolean } | undefined)?.booleanValue
            ? 'idle'
            : 'stopped';
    });
    expect(statuses.filter((status) => status === 'moving')).toHaveLength(150);
    expect(statuses.filter((status) => status === 'idle')).toHaveLength(125);
    expect(statuses.filter((status) => status === 'stopped')).toHaveLength(125);
    expect(statuses.filter((status) => status === 'offline')).toHaveLength(100);
  });
});
