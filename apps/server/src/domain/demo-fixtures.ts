import { bootstrapLocation } from './demo-location-scenarios.js';

export type DemoVehicle = Readonly<{
  model: string;
  registrationNumber: string;
  vehicleId: string;
}>;

export type DemoPacket = Readonly<{
  eventTimestamp: string;
  packetId: string;
  signalName: string;
  value: Readonly<Record<string, unknown>>;
  vehicleId: string;
}>;

export function createDemoVehicles(seed: string, count = 500): readonly DemoVehicle[] {
  return Array.from({ length: count }, (_, index) => {
    const number = String(index + 1).padStart(3, '0');
    return {
      vehicleId: `vehicle-${number}`,
      registrationNumber: `BB-${seed.slice(0, 3).toUpperCase()}-${number}`,
      model: index % 2 === 0 ? 'ByteBeam Haul 8' : 'ByteBeam Haul 12',
    };
  });
}

export function createDemoPackets(
  vehicles: readonly DemoVehicle[],
  startAtUtc: Date,
): readonly DemoPacket[] {
  return vehicles.flatMap((vehicle, index) => {
    const status =
      index < 150 ? 'moving' : index < 275 ? 'idle' : index < 400 ? 'stopped' : 'offline';
    const eventTimestamp = new Date(
      startAtUtc.getTime() - (status === 'offline' ? 11 * 60_000 : index * 1000),
    ).toISOString();
    const soc = index % 50 === 0 ? 8 : index % 25 === 0 ? 15 : 35 + (index % 55);
    const packets: DemoPacket[] = [
      packet(vehicle.vehicleId, eventTimestamp, 'last_ping', {
        kind: 'boolean',
        booleanValue: true,
      }),
      ...locationPackets(vehicle.vehicleId, eventTimestamp, index),
      packet(vehicle.vehicleId, eventTimestamp, 'soc', {
        kind: 'number',
        numberValue: soc,
      }),
      packet(vehicle.vehicleId, eventTimestamp, 'range', {
        kind: 'number',
        numberValue: soc * 3,
      }),
      packet(vehicle.vehicleId, eventTimestamp, 'odometer', {
        kind: 'number',
        numberValue: 12_000 + index * 100,
      }),
    ];
    if (status === 'moving') {
      packets.push(
        packet(vehicle.vehicleId, eventTimestamp, 'speed', { kind: 'number', numberValue: 45 }),
      );
    } else if (status === 'idle') {
      packets.push(
        packet(vehicle.vehicleId, eventTimestamp, 'speed', { kind: 'number', numberValue: 0 }),
        packet(vehicle.vehicleId, eventTimestamp, 'ignition', {
          kind: 'boolean',
          booleanValue: true,
        }),
      );
    } else {
      packets.push(
        packet(vehicle.vehicleId, eventTimestamp, 'speed', { kind: 'number', numberValue: 0 }),
        packet(vehicle.vehicleId, eventTimestamp, 'ignition', {
          kind: 'boolean',
          booleanValue: false,
        }),
      );
    }
    if (index % 40 === 0) {
      packets.push(
        packet(vehicle.vehicleId, eventTimestamp, 'battery_temp', {
          kind: 'number',
          numberValue: 50,
        }),
      );
    }
    return packets;
  });
}

function locationPackets(
  vehicleId: string,
  eventTimestamp: string,
  index: number,
): readonly DemoPacket[] {
  const location = bootstrapLocation(vehicleId, index);
  const firstTimestamp = new Date(new Date(eventTimestamp).getTime() - 60_000).toISOString();
  const value = {
    kind: 'location',
    locationValue: {
      latitude: location.latitude,
      longitude: location.longitude,
      accuracyMeters: location.accuracyMeters ?? 10,
    },
  };
  return [
    packet(vehicleId, firstTimestamp, 'location', value),
    packet(vehicleId, eventTimestamp, 'location', value),
  ];
}

function packet(
  vehicleId: string,
  eventTimestamp: string,
  signalName: string,
  value: Readonly<Record<string, unknown>>,
): DemoPacket {
  return {
    packetId: `${vehicleId}:${eventTimestamp}:${signalName}`,
    vehicleId,
    eventTimestamp,
    signalName,
    value,
  };
}
