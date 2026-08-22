import { describe, expect, it } from 'vitest';

import {
  bootstrapLocation,
  createLiveLocationPackets,
  createLiveVehicleTelemetry,
  demoLocationScenarioLength,
  type DemoVehicleSimulatorStates,
} from '../src/domain/demo-location-scenarios.js';
import { demoSites } from '../src/domain/demo-sites.js';

describe('demo location scenarios', () => {
  it('given_a_simulation_tick_when_packets_created_then_emits_five_unique_vehicle_locations', () => {
    const packets = createLiveLocationPackets(0, '2026-08-21T00:00:01.000Z');

    expect(packets).toHaveLength(5);
    expect(new Set(packets.map((packet) => packet.vehicleId)).size).toBe(5);
    expect(new Set(packets.map((packet) => packet.packetId)).size).toBe(5);
    expect(packets.every((packet) => packet.signalName === 'location')).toBe(true);
  });

  it('given_a_completed_route_when_next_tick_created_then_coordinates_loop_with_new_packet_ids', () => {
    const first = createLiveLocationPackets(0, '2026-08-21T00:00:01.000Z');
    const looped = createLiveLocationPackets(
      demoLocationScenarioLength,
      '2026-08-21T00:00:13.000Z',
    );

    expect(looped.map((packet) => packet.value)).toEqual(first.map((packet) => packet.value));
    expect(looped.map((packet) => packet.packetId)).not.toEqual(
      first.map((packet) => packet.packetId),
    );
  });

  it('given_bootstrap_fleet_when_locations_created_then_uses_five_sites_and_route_origins', () => {
    const ordinarySites = Array.from({ length: 5 }, (_, index) =>
      bootstrapLocation(`vehicle-${String(index + 101)}`, index),
    );

    expect(ordinarySites).toEqual(demoSites);
    expect(bootstrapLocation('vehicle-001', 0).longitude).toBeGreaterThan(demoSites[0].longitude);
    expect(bootstrapLocation('vehicle-003', 2)).toMatchObject(demoSites[2]);
  });

  it('given_accuracy_noise_route_when_created_then_includes_rejected_accuracy', () => {
    const packets = Array.from({ length: demoLocationScenarioLength }, (_, step) =>
      createLiveLocationPackets(step, '2026-08-21T00:00:01.000Z'),
    ).flat();
    const accuracy = packets
      .filter((packet) => packet.vehicleId === 'vehicle-005')
      .map(
        (packet) =>
          (packet.value as { locationValue: { accuracyMeters: number } }).locationValue
            .accuracyMeters,
      );

    expect(accuracy).toContain(120);
  });

  it('given_moving_waypoint_when_telemetry_created_then_signals_motion_and_energy_use', () => {
    const result = createLiveVehicleTelemetry(0, '2026-08-21T00:00:01.000Z');

    expect(numberValue(result.packets, 'vehicle-001', 'speed')).toBe(32);
    expect(booleanValue(result.packets, 'vehicle-001', 'ignition')).toBe(true);
    expect(numberValue(result.packets, 'vehicle-001', 'soc')).toBe(81.8);
    expect(numberValue(result.packets, 'vehicle-001', 'range')).toBeCloseTo(81.8 * 3);
    expect(result.states['vehicle-001']?.odometerKm).toBeGreaterThan(12_000);
    expect(new Set(result.packets.map((packet) => packet.eventTimestamp))).toEqual(
      new Set(['2026-08-21T00:00:01.000Z']),
    );
  });

  it('given_parked_waypoint_when_telemetry_created_then_speed_and_ignition_are_off', () => {
    let states: DemoVehicleSimulatorStates = {};
    let packets = createLiveVehicleTelemetry(0, '2026-08-21T00:00:01.000Z').packets;
    for (let step = 0; step <= 4; step += 1) {
      const result = createLiveVehicleTelemetry(
        step,
        `2026-08-21T00:00:${String(step + 1).padStart(2, '0')}.000Z`,
        states,
      );
      states = result.states;
      packets = result.packets;
    }

    expect(numberValue(packets, 'vehicle-005', 'speed')).toBe(0);
    expect(booleanValue(packets, 'vehicle-005', 'ignition')).toBe(false);
  });

  it('given_peenya_vehicle_when_charging_then_soc_increases_and_odometer_does_not_decrease', () => {
    let states: DemoVehicleSimulatorStates = {};
    let beforeCharge = 0;
    let beforeOdometer = 0;
    for (let step = 0; step <= 7; step += 1) {
      const result = createLiveVehicleTelemetry(
        step,
        `2026-08-21T00:00:${String(step + 1).padStart(2, '0')}.000Z`,
        states,
      );
      states = result.states;
      if (step === 6) {
        beforeCharge = states['vehicle-004']?.soc ?? 0;
        beforeOdometer = states['vehicle-004']?.odometerKm ?? 0;
      }
    }

    expect(states['vehicle-004']?.soc).toBeGreaterThan(beforeCharge);
    expect(states['vehicle-004']?.odometerKm).toBeGreaterThanOrEqual(beforeOdometer);
    expect(states['vehicle-004']?.motion).toBe('charging');
  });
});

function numberValue(
  packets: readonly {
    signalName: string;
    value: Readonly<Record<string, unknown>>;
    vehicleId: string;
  }[],
  vehicleId: string,
  signalName: string,
): number {
  const packet = packets.find(
    (candidate) => candidate.vehicleId === vehicleId && candidate.signalName === signalName,
  );
  return (packet?.value as { numberValue?: number }).numberValue ?? Number.NaN;
}

function booleanValue(
  packets: readonly {
    signalName: string;
    value: Readonly<Record<string, unknown>>;
    vehicleId: string;
  }[],
  vehicleId: string,
  signalName: string,
): boolean | undefined {
  const packet = packets.find(
    (candidate) => candidate.vehicleId === vehicleId && candidate.signalName === signalName,
  );
  return (packet?.value as { booleanValue?: boolean }).booleanValue;
}
