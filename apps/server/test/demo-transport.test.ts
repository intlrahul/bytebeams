import { request as httpRequest } from 'node:http';
import type { AddressInfo } from 'node:net';

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
    let requestedCursor: string | undefined;
    const app = createApp({
      ...service(),
      deliveriesAfter: (cursor) => {
        requestedCursor = cursor;
        return [{ deliveryId: String(Number(cursor) + 1), packet: {} }];
      },
    });
    const server = app.listen(0);
    const { port } = server.address() as AddressInfo;

    try {
      await new Promise<void>((resolve, reject) => {
        const client = httpRequest(
          {
            port,
            path: '/telemetry?after=1',
            headers: { 'Last-Event-ID': '2' },
          },
          (response) => {
            response.once('data', (chunk: Buffer) => {
              expect(chunk.toString()).toContain('id: 3');
              client.destroy();
              response.destroy();
              resolve();
            });
          },
        );
        client.once('error', reject);
        client.end();
      });
    } finally {
      await new Promise<void>((resolve) => server.close(() => resolve()));
    }

    expect(requestedCursor).toBe('2');
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
    publishNextDelivery: () => ({ deliveryId: '4', packet: {} }),
  };
}
