# Geofences and Trips

## Versioned geofences

A geofence has stable identity, name, centre, radius, active state, and immutable versions. Create at least three deterministic seeds. Edits and deactivation apply prospectively. Each version owns a half-open interval `[effective_from, effective_until)`. Historical and late locations use the definition effective at event time.

The first release provides a dedicated, map-free Geofences screen with a list,
add form, edit form, and deactivation action. A geofence is never hard-deleted:
historical versions remain available for interpretation. Validate a trimmed name
as 1–80 characters, radius as 50 m–50 km inclusive, latitude as -90…90, and
longitude as -180…180. The app seeds five synthetic, demo-labelled Bengaluru
sites: Sarjapur Hub, Electronic City Depot, Whitefield Service Yard, Peenya
Logistics Hub, and Yelahanka Charging Yard. Each seed starts with a 1 km radius.

The demo backend owns the synthetic movement script. On every simulation tick
it appends one connectivity packet and one location packet, then advances both
sequence positions in SQLite in the same transaction. The persisted sequence
is resumed after a server restart, so packet IDs and route progress do not
repeat. The mobile app treats these as ordinary raw telemetry and remains the
owner of geofence classification, confirmation, replay, and derived state.

### Demo movement scenario

The 500 bootstrap vehicles are distributed deterministically across the five
sites. Five showcase vehicles then emit one location each per one-second server
tick:

- `vehicle-001` approaches, enters, dwells at, and leaves Sarjapur.
- `vehicle-002` leaves Electronic City and later returns to the same origin.
- `vehicle-003` remains at Whitefield to demonstrate stable membership.
- `vehicle-004` travels from Peenya to Yelahanka and returns.
- `vehicle-005` approaches Yelahanka with boundary and rejected-accuracy noise.

Each route is twelve ticks and loops. Clearly inside and outside states include
two supporting readings. The monotonically increasing route tick is persisted,
so looping changes coordinates predictably without reusing packet IDs and a
server restart resumes the next tick. With the mobile five-second ingestion
window, visible counts normally change within 5–10 seconds.

Every showcase waypoint also defines its operational state. Location, speed,
ignition, and `last_ping` are emitted each second. SOC, range, odometer, and
battery temperature are emitted every five ticks and immediately on a motion
state change. Moving consumes 0.2 SOC percentage points per second; charging
adds 0.5, bounded to 10–90%. Range uses the deterministic 300 km full-charge
model `range_km = SOC × 3`. Odometer advances by `speed_kph / 3600` each tick.
The backend persists SOC, odometer, and the previous motion state atomically
with its emitted packets. Fleet status and Vehicle Detail therefore update from
the same committed telemetry that drives the route, while geofence derivation
continues to use location packets only.

For a clean walkthrough, stop both processes, remove the configured backend
demo SQLite file (the default is `.data/bytebeams-demo.sqlite`), clear the
mobile app's local data, then start the server before the app. Watch vehicles
001–005 on Vehicle Detail and the five counts on Geofences.

## Reading classification

For reported GPS accuracy `a`:

```text
margin = min(max(20 m, a), 75 m)
inside        if distance <= radius - margin
outside       if distance >= radius + margin
indeterminate otherwise
```

A reading with accuracy greater than 100 m cannot confirm a transition. Use a documented geodesic distance calculation consistently.

## Confirmation

- Two qualifying readings confirm entry or exit.
- The transition event time is the first supporting reading; the second proves it.
- Indeterminate and rejected-accuracy readings neither advance nor reset a candidate.
- A decisive reading supporting the opposite state resets the candidate.
- “Consecutive” means consecutive decisive readings; indeterminate readings may occur between them.
- Duplicate packet IDs never count twice.
- The initial confirmed state establishes a baseline and emits no entry or exit.

Example:

```text
10:00 inside
10:05 outside   first support
10:06 outside   confirmation
exit_at = 10:05
```

## Overlap and direct movement

Choose the winning clearly-inside geofence by smallest radius, then shortest centre distance, then stable `geofence_id`. A confirmed direct move from A to B emits exit A and entry B even without an observed outside-all state. Both may use the first B-supporting reading time.

## Missing and late data

Do not infer a physical crossing time in a missing interval. A late reading causes deterministic replay of the affected vehicle's event-time window. Reconcile by deleting obsolete derived rows and upserting current transitions/trips; append-only correction is insufficient.

Deterministic transition identity inputs and the safe replay-window strategy must be fixed before implementation and covered by permutation tests.

For the initial release, rebuild every affected vehicle from its complete
retained location history. This deliberately favours correctness over a
shorter, unverified replay window. A transition ID is the deterministic tuple
`vehicle_id + geofence_id + geofence_version + transition_type +
event_timestamp + packet_id`.

## Trips

- Confirmed exit starts an `IN_PROGRESS` trip only if the vehicle has no active trip.
- The next confirmed entry completes it.
- Additional exits remain transition history but cannot start a second active trip.
- Origin and destination may be the same.
- Late data may revise start, end, origin, or destination visibly.
- `trip_id = deterministic(vehicle_id + exit_transition_id)`.

Enforce one active trip per vehicle at both domain and database levels where DuckDB supports the chosen constraint strategy. If replay replaces the originating exit transition, remove the obsolete trip and create the newly identified trip. If only destination/completion changes, retain trip identity.
