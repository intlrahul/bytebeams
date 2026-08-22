import type { DemoPacket } from './demo-fixtures.js';
import { demoSites } from './demo-sites.js';

type DemoLocationPoint = Readonly<{
  accuracyMeters?: number;
  latitude: number;
  longitude: number;
}>;

export type DemoMotionState = 'charging' | 'dwelling' | 'moving' | 'parked';

export type DemoVehicleSimulatorState = Readonly<{
  motion: DemoMotionState;
  odometerKm: number;
  soc: number;
}>;

export type DemoVehicleSimulatorStates = Readonly<Record<string, DemoVehicleSimulatorState>>;

type DemoWaypoint = DemoLocationPoint &
  Readonly<{
    motion: DemoMotionState;
    speedKph: number;
  }>;

type DemoVehicleRoute = Readonly<{
  points: readonly DemoWaypoint[];
  vehicleId: string;
}>;

const [sarjapur, electronicCity, whitefield, peenya, yelahanka] = demoSites;
const outsideEast = (site: DemoLocationPoint, degrees = 0.014): DemoLocationPoint =>
  point(site.latitude, site.longitude + degrees);
const insideEast = (site: DemoLocationPoint): DemoLocationPoint =>
  point(site.latitude, site.longitude + 0.008);
const boundaryEast = (site: DemoLocationPoint, accuracyMeters = 10): DemoLocationPoint =>
  point(site.latitude, site.longitude + 0.0092, accuracyMeters);

const routes: readonly DemoVehicleRoute[] = [
  route('vehicle-001', [
    moving(outsideEast(sarjapur), 32),
    moving(outsideEast(sarjapur), 28),
    moving(boundaryEast(sarjapur), 18),
    moving(insideEast(sarjapur), 10),
    moving(insideEast(sarjapur), 6),
    dwelling(sarjapur),
    dwelling(sarjapur),
    moving(insideEast(sarjapur), 8),
    moving(boundaryEast(sarjapur), 18),
    moving(outsideEast(sarjapur), 28),
    moving(outsideEast(sarjapur), 32),
    moving(outsideEast(sarjapur), 32),
  ]),
  route('vehicle-002', [
    dwelling(electronicCity),
    dwelling(electronicCity),
    moving(insideEast(electronicCity), 8),
    moving(boundaryEast(electronicCity), 16),
    moving(outsideEast(electronicCity), 28),
    moving(outsideEast(electronicCity), 34),
    moving(outsideEast(electronicCity), 34),
    moving(outsideEast(electronicCity), 28),
    moving(boundaryEast(electronicCity), 16),
    moving(insideEast(electronicCity), 8),
    moving(insideEast(electronicCity), 4),
    dwelling(electronicCity),
  ]),
  route('vehicle-003', Array<DemoWaypoint>(12).fill(parked(whitefield))),
  route('vehicle-004', [
    dwelling(peenya),
    dwelling(peenya),
    moving(outsideEast(peenya), 20),
    moving(outsideEast(peenya), 35),
    moving(midpoint(peenya, yelahanka), 45),
    moving(midpoint(peenya, yelahanka), 45),
    charging(yelahanka),
    charging(yelahanka),
    charging(yelahanka),
    moving(midpoint(peenya, yelahanka), 45),
    moving(peenya, 12),
    dwelling(peenya),
  ]),
  route('vehicle-005', [
    moving(outsideEast(yelahanka), 24),
    moving(outsideEast(yelahanka), 20),
    moving(boundaryEast(yelahanka, 120), 12),
    moving(point(yelahanka.latitude, yelahanka.longitude, 120), 6),
    parked(yelahanka),
    parked(yelahanka),
    parked(yelahanka),
    moving(insideEast(yelahanka), 8),
    moving(boundaryEast(yelahanka), 16),
    moving(outsideEast(yelahanka), 24),
    moving(outsideEast(yelahanka), 28),
    moving(outsideEast(yelahanka), 28),
  ]),
];

export const demoLocationScenarioLength = 12;

export function createLiveLocationPackets(
  step: number,
  eventTimestamp: string,
): readonly DemoPacket[] {
  return routes.map((scenario) => {
    const location = scenario.points[step % demoLocationScenarioLength];
    if (location === undefined) {
      throw new Error('Demo location scenario is unavailable');
    }
    return locationPacket(scenario.vehicleId, step, eventTimestamp, location);
  });
}

export function createLiveVehicleTelemetry(
  step: number,
  eventTimestamp: string,
  currentStates: DemoVehicleSimulatorStates = {},
): Readonly<{
  packets: readonly DemoPacket[];
  states: DemoVehicleSimulatorStates;
}> {
  const packets: DemoPacket[] = [];
  const states: Record<string, DemoVehicleSimulatorState> = {};
  for (const [index, scenario] of routes.entries()) {
    const waypoint = scenario.points[step % demoLocationScenarioLength];
    if (waypoint === undefined) {
      throw new Error('Demo telemetry scenario is unavailable');
    }
    const previous = currentStates[scenario.vehicleId] ?? initialState(index);
    const next = advanceState(previous, waypoint);
    states[scenario.vehicleId] = next;
    packets.push(
      locationPacket(scenario.vehicleId, step, eventTimestamp, waypoint),
      booleanPacket(scenario.vehicleId, step, eventTimestamp, 'last_ping', true),
      numberPacket(scenario.vehicleId, step, eventTimestamp, 'speed', waypoint.speedKph),
      booleanPacket(
        scenario.vehicleId,
        step,
        eventTimestamp,
        'ignition',
        waypoint.motion === 'moving' || waypoint.motion === 'dwelling',
      ),
    );
    if (step % 5 === 0 || previous.motion !== waypoint.motion) {
      packets.push(
        numberPacket(scenario.vehicleId, step, eventTimestamp, 'soc', next.soc),
        numberPacket(scenario.vehicleId, step, eventTimestamp, 'range', next.soc * 3),
        numberPacket(scenario.vehicleId, step, eventTimestamp, 'odometer', next.odometerKm),
        numberPacket(
          scenario.vehicleId,
          step,
          eventTimestamp,
          'battery_temp',
          batteryTemperature(waypoint),
        ),
      );
    }
  }
  return { packets, states };
}

export function bootstrapLocation(vehicleId: string, index: number): DemoLocationPoint {
  const scenario = routes.find((candidate) => candidate.vehicleId === vehicleId);
  if (scenario !== undefined) return scenario.points[0] ?? outsideEast(sarjapur);
  return demoSites[index % demoSites.length] ?? sarjapur;
}

function locationPacket(
  vehicleId: string,
  step: number,
  eventTimestamp: string,
  location: DemoLocationPoint,
): DemoPacket {
  return {
    packetId: `live:location:${String(step)}:${vehicleId}`,
    vehicleId,
    eventTimestamp,
    signalName: 'location',
    value: {
      kind: 'location',
      locationValue: {
        latitude: location.latitude,
        longitude: location.longitude,
        accuracyMeters: location.accuracyMeters ?? 10,
      },
    },
  };
}

function numberPacket(
  vehicleId: string,
  step: number,
  eventTimestamp: string,
  signalName: string,
  numberValue: number,
): DemoPacket {
  return {
    packetId: `live:${signalName}:${String(step)}:${vehicleId}`,
    vehicleId,
    eventTimestamp,
    signalName,
    value: { kind: 'number', numberValue },
  };
}

function booleanPacket(
  vehicleId: string,
  step: number,
  eventTimestamp: string,
  signalName: string,
  booleanValue: boolean,
): DemoPacket {
  return {
    packetId: `live:${signalName}:${String(step)}:${vehicleId}`,
    vehicleId,
    eventTimestamp,
    signalName,
    value: { kind: 'boolean', booleanValue },
  };
}

function route(vehicleId: string, points: readonly DemoWaypoint[]): DemoVehicleRoute {
  return { vehicleId, points };
}

function point(latitude: number, longitude: number, accuracyMeters = 10): DemoLocationPoint {
  return { latitude, longitude, accuracyMeters };
}

function midpoint(left: DemoLocationPoint, right: DemoLocationPoint): DemoLocationPoint {
  return point((left.latitude + right.latitude) / 2, (left.longitude + right.longitude) / 2);
}

function moving(location: DemoLocationPoint, speedKph: number): DemoWaypoint {
  return { ...location, motion: 'moving', speedKph };
}

function dwelling(location: DemoLocationPoint): DemoWaypoint {
  return { ...location, motion: 'dwelling', speedKph: 0 };
}

function parked(location: DemoLocationPoint): DemoWaypoint {
  return { ...location, motion: 'parked', speedKph: 0 };
}

function charging(location: DemoLocationPoint): DemoWaypoint {
  return { ...location, motion: 'charging', speedKph: 0 };
}

function initialState(index: number): DemoVehicleSimulatorState {
  return { motion: 'parked', odometerKm: 12_000 + index * 100, soc: 82 - index * 5 };
}

function advanceState(
  previous: DemoVehicleSimulatorState,
  waypoint: DemoWaypoint,
): DemoVehicleSimulatorState {
  const socDelta = waypoint.motion === 'moving' ? -0.2 : waypoint.motion === 'charging' ? 0.5 : 0;
  return {
    motion: waypoint.motion,
    odometerKm: round(previous.odometerKm + waypoint.speedKph / 3600, 3),
    soc: round(Math.min(90, Math.max(10, previous.soc + socDelta)), 1),
  };
}

function batteryTemperature(waypoint: DemoWaypoint): number {
  if (waypoint.motion === 'charging') return 31;
  if (waypoint.motion === 'moving') return round(28 + waypoint.speedKph * 0.08, 1);
  return 28;
}

function round(value: number, places: number): number {
  const factor = 10 ** places;
  return Math.round(value * factor) / factor;
}
