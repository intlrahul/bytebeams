import type { DemoPacket } from './demo-fixtures.js';

type DemoLocationPoint = Readonly<{
  accuracyMeters: number;
  latitude: number;
  longitude: number;
  vehicleId: string;
}>;

const sarjapur = { latitude: 12.9016, longitude: 77.6877 };
const electronicCity = { latitude: 12.8456, longitude: 77.6603 };
const whitefield = { latitude: 12.9698, longitude: 77.7499 };

const locationScript: readonly DemoLocationPoint[] = [
  point('vehicle-001', 12.9016, 77.7077),
  point('vehicle-001', 12.9016, 77.7077),
  point('vehicle-001', sarjapur.latitude, sarjapur.longitude),
  point('vehicle-001', sarjapur.latitude, sarjapur.longitude),
  point('vehicle-002', whitefield.latitude, whitefield.longitude),
  point('vehicle-002', whitefield.latitude, whitefield.longitude),
  point('vehicle-003', electronicCity.latitude, electronicCity.longitude, 120),
  point('vehicle-003', sarjapur.latitude, sarjapur.longitude),
  point('vehicle-003', sarjapur.latitude, sarjapur.longitude),
  point('vehicle-004', 12.9016, 77.6969),
  point('vehicle-004', 12.9016, 77.6969),
  point('vehicle-004', 12.9016, 77.7077),
  point('vehicle-004', 12.9016, 77.7077),
];

export function createLiveLocationPacket(step: number, eventTimestamp: string): DemoPacket {
  const location = locationScript[step % locationScript.length];
  if (location === undefined) {
    throw new Error('Demo location scenario is unavailable');
  }
  return {
    packetId: `live:location:${String(step)}`,
    vehicleId: location.vehicleId,
    eventTimestamp,
    signalName: 'location',
    value: {
      kind: 'location',
      locationValue: {
        latitude: location.latitude,
        longitude: location.longitude,
        accuracyMeters: location.accuracyMeters,
      },
    },
  };
}

function point(
  vehicleId: string,
  latitude: number,
  longitude: number,
  accuracyMeters = 10,
): DemoLocationPoint {
  return { vehicleId, latitude, longitude, accuracyMeters };
}
