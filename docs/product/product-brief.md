# Product Brief

## Problem

A fleet operator responsible for approximately 500 electric trucks needs a fast, trustworthy operational view. Connectivity is unreliable, so the interface must remain useful offline and must distinguish current information from data that is too old to trust.

## Primary user

A single fleet operator monitoring vehicle health, movement, connectivity, alerts, geofence membership, and automatically derived trips.

## Demo objective

Demonstrate that the application can:

- Persist and query fleet state locally rather than treating persistence as a cache.
- Reconstruct state deterministically from imperfect event-time telemetry.
- Surface urgent conditions without making claims from stale data.
- Recover after app and backend restarts.
- Handle duplicate, late, out-of-order, missing, and backlog deliveries idempotently.
- Explain architecture and correctness through focused tests and documentation.

## Experience principles

- Existing local information appears immediately on launch.
- Data age and uncertainty remain visible.
- The fleet home optimizes for scanning and attention.
- Empty, loading, syncing, degraded, and failure states are explicit.
- Demo fixtures are deterministic and synthetic.

## Scope boundaries

The take-home has no authentication, map, collaborative sync, or external analytics provider. The backend is a demo transport. Android is the first demonstration target.
