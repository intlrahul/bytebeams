# Product Requirements

## Fleet home

Show all vehicles with registration number, model, SOC, range, alert badge, and status. Provide `All`, `Moving`, `Idle`, `Stopped`, and `Offline` filter chips with live counts calculated in SQL. Show a purposeful empty state when a filter has no results.

Status uses the first matching rule:

1. Latest valid explicit `last_ping` age greater than 10 minutes: `OFFLINE`.
2. Otherwise, latest known speed greater than zero: `MOVING`.
3. Otherwise, latest known ignition explicitly false: `STOPPED`.
4. Otherwise, latest known ignition explicitly true: `IDLE`.
5. If ignition has never reported: deterministic fallback to `STOPPED`.

Exactly 10 minutes is fresh. Speed and ignition may be used for status even when individually stale. Other packets never refresh connectivity. `All` is a filter, not a status. The deliberately conservative fallback replaces an unrequested `UNKNOWN` status.

## Vehicle detail

Show one row for each of SOC, range, speed, battery temperature, odometer, and last ping. Each row contains a label, formatted value, its own age, and verdict:

- `NORMAL`: fresh and within threshold.
- `ALERT`: fresh and outside threshold.
- `STALE`: too old to make a normal/alert claim.
- Never reported: show `—` and no verdict.

Show SOC history for the previous 24 hours by querying the retained event log.

## Alerts

Evaluate only fresh, valid readings:

| Logical alert | Condition | Severity |
| --- | --- | --- |
| Low battery | `10 <= SOC < 20` | Warning |
| Low battery | `SOC < 10` | Critical |
| Battery overheating | `battery_temp > 45°C` | Critical |

The SOC levels form one escalating alert episode, not two alerts. Dismissal reasons appear in this order: **I am on it**, **Wrong alert**, **Something else...**.

- Dismissal persists for the current episode.
- A clearing condition resolves the episode independently of dismissal.
- A later recurrence creates a new episode.
- Warning-to-Critical escalation overrides a Warning dismissal.
- Dismissal persists in DuckDB.
- Undo is available for five wall-clock seconds and reverses persisted effective dismissal state.
- Persist dismissal/undo history for auditability.

## Geofences

Create, edit, deactivate, and persist circular geofences containing name, centre, radius, and active state. Seed at least three. Retain deactivated definitions and every version for historical interpretation. Display current vehicle membership and live counts. A map is out of scope.

Edits apply prospectively over version intervals `[effective_from, effective_until)`. Historical and late events use the version effective at their event time.

## Automatic trips

- Confirmed exit starts a trip when none is active.
- The next confirmed entry completes the active trip.
- Without an entry the trip remains `IN_PROGRESS`.
- Returning to the origin is valid and needs no special label.
- A vehicle has at most one active trip.
- An extra exit while a trip is active is retained as a transition but creates no trip.
- Duplicate packets create nothing twice.
- Late packets may visibly revise boundaries, origin, or destination.
- `trip_id = deterministic(vehicle_id + exit_transition_id)`.

## Persistence and synchronization

- Backend-supplied vehicle registry and telemetry are persisted in DuckDB.
- Existing local state renders before network synchronization.
- A fresh install uses `GET /bootstrap`, imports registry/backfill/cursor transactionally, then connects to SSE.
- SSE resumes from a server delivery cursor and supports `Last-Event-ID` reconnects.
- Explicit demo fallback is offered only after bootstrap failure.
- Killing and relaunching the app restores everything known from disk.

## Retention

- Valid raw telemetry: 30 days by event time.
- Invalid, unsupported, and quarantined records: 30 days. Quarantine retention uses receipt time when the event is already outside the event-time window.
- Trips, transitions, alert history, dismissals, and geofence versions: retained without automatic demo expiry.
