# Vehicle Status and Alerts

## Freshness

Use an injected clock. A valid signal is fresh when `now - event_timestamp <= 10 minutes` and stale when the age is greater than 10 minutes. Displayed age must not be negative. The allowed future-clock-skew tolerance remains an explicit open decision.

`last_ping` is a special explicit signal. Its event timestamp is the ping time. Only a valid `last_ping` changes connectivity; receiving any other packet does not.

## Status

Evaluate in this order:

1. Latest valid `last_ping` older than 10 minutes: `OFFLINE`.
2. Otherwise latest known speed greater than zero: `MOVING`.
3. Otherwise ignition explicitly false: `STOPPED`.
4. Otherwise ignition explicitly true: `IDLE`.
5. If ignition has never reported: `STOPPED`.

Exactly 10 minutes is online. Status deliberately uses last-known speed and ignition even when those readings are stale. SQL supplies fleet rows and live filter counts. Tests must cover every boundary and missing-value combination.

## Reading verdicts

- Never reported: `—`, no pill.
- Invalid/unsupported only: no derived reading claim.
- Stale valid reading: `STALE`, with no normal/alert claim.
- Fresh and outside an alert threshold: `ALERT`.
- Fresh and within thresholds: `NORMAL`.

## Alert episode state machine

Low battery is one logical episode whose severity is Warning for `10 <= SOC < 20` and Critical for `SOC < 10`. Overheating is Critical for `battery_temp > 45°C`. Evaluate thresholds only on fresh valid readings.

- Inactive → condition active: create a new episode.
- Active → condition cleared: resolve the episode, regardless of dismissal.
- Resolved → condition active later: create a new episode.
- Warning → Critical: retain logical episode, escalate severity, and override a Warning dismissal.
- Staleness removes the ability to claim `NORMAL` or `ALERT`; it does not fabricate a clearing value.

Episode identity is `vehicle_id:alert_type:opened_packet_id`, where the opening
packet is the first fresh valid reading that makes the condition active. The
projection upserts this identity inside the telemetry transaction, so duplicate
packets cannot create another episode. A fresh valid clearing reading resolves
the active episode; stale readings leave it unchanged.

## Dismissal and Undo

Persist dismissal reason, `dismissed_at`, and `undo_expires_at`. Reasons appear in this exact order:

1. I am on it
2. Wrong alert
3. Something else...

Undo is available for five wall-clock seconds, including across backgrounding or restart. Undo reverses effective persisted dismissal and records audit history such as `undone_at`; it is not an in-memory-only reappearance. Use an injected clock for tests.
