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
    const eventTimestamp = new Date(startAtUtc.getTime() + index * 1000).toISOString();
    return [
      packet(vehicle.vehicleId, eventTimestamp, 'last_ping', {
        kind: 'boolean',
        booleanValue: true,
      }),
      packet(vehicle.vehicleId, eventTimestamp, 'soc', {
        kind: 'number',
        numberValue: 20 + (index % 70),
      }),
      packet(vehicle.vehicleId, eventTimestamp, 'speed', {
        kind: 'number',
        numberValue: index % 3 === 0 ? 45 : 0,
      }),
    ];
  });
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
