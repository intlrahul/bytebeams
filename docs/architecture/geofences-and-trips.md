# Geofences and Trips

## Versioned geofences

A geofence has stable identity, name, centre, radius, active state, and immutable versions. Create at least three deterministic seeds. Edits and deactivation apply prospectively. Each version owns a half-open interval `[effective_from, effective_until)`. Historical and late locations use the definition effective at event time.

The first release provides a dedicated, map-free Geofences screen with a list,
add form, edit form, and deactivation action. A geofence is never hard-deleted:
historical versions remain available for interpretation. Validate a trimmed name
as 1–80 characters, radius as 50 m–50 km inclusive, latitude as -90…90, and
longitude as -180…180. The app seeds the synthetic, demo-labelled Bengaluru
sites Sarjapur Hub, Electronic City Depot, and Whitefield Service Yard.

The demo backend owns the synthetic movement script. On every simulation tick
it appends one connectivity packet and one location packet, then advances both
sequence positions in SQLite in the same transaction. The persisted sequence
is resumed after a server restart, so packet IDs and route progress do not
repeat. The mobile app treats these as ordinary raw telemetry and remains the
owner of geofence classification, confirmation, replay, and derived state.

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
