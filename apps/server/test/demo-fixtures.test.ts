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
});
