import request from 'supertest';
import { describe, expect, it } from 'vitest';

import { createApp } from '../src/app.js';

describe('GET /health', () => {
  it('given_running_server_when_health_requested_then_returns_ok', async () => {
    // Given
    const app = createApp();

    // When
    const response = await request(app).get('/health');

    // Then
    expect(response.status).toBe(200);
    expect(response.body).toEqual({ status: 'ok' });
  });
});
