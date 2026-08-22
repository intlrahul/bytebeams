import request from 'supertest';
import { describe, expect, it } from 'vitest';

import { createApp } from '../src/app.js';
import type { DemoTransportService } from '../src/domain/demo-service.js';

describe('demo transport', () => {
  it('given_a_demo_service_when_bootstrap_requested_then_returns_snapshot', async () => {
    const response = await request(createApp(service())).get('/bootstrap');
    expect(response.status).toBe(200);
    expect(response.body).toEqual({
      deliveryCursor: '3',
      telemetry: [],
      vehicles: [],
    });
  });
  it('given_both_cursors_when_telemetry_requested_then_last_event_id_wins', async () => {
    const response = await request(createApp(service()))
      .get('/telemetry?after=1')
      .set('Last-Event-ID', '2');
    expect(response.status).toBe(200);
    expect(response.text).toContain('id: 3');
  });
  it('given_a_replay_gap_when_telemetry_requested_then_returns_409_contract', async () => {
    const response = await request(
      createApp({
        ...service(),
        replayGap: () => ({ requestedCursor: '1', oldestAvailableCursor: '5' }),
      }),
    ).get('/telemetry?after=1');
    expect(response.status).toBe(409);
    expect(response.body).toEqual({
      code: 'replay_gap',
      requestedCursor: '1',
      oldestAvailableCursor: '5',
    });
  });
  it('given_a_non_numeric_cursor_when_telemetry_requested_then_returns_400', async () => {
    expect((await request(createApp(service())).get('/telemetry?after=nope')).status).toBe(400);
  });
});

function service(): DemoTransportService {
  return {
    bootstrap: () => ({ vehicles: [], telemetry: [], deliveryCursor: '3' }),
    deliveriesAfter: (cursor) => [{ deliveryId: String(Number(cursor) + 1), packet: {} }],
    replayGap: () => null,
  };
}
