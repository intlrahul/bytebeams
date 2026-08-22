import express, { type Express } from 'express';

import type { DemoTransportService } from './domain/demo-service.js';

export function createApp(service?: DemoTransportService): Express {
  const app = express();

  app.disable('x-powered-by');
  app.use(express.json());
  app.get('/health', (_request, response) => {
    response.status(200).json({ status: 'ok' });
  });
  app.get('/bootstrap', (_request, response) => {
    if (service === undefined) {
      response
        .status(503)
        .json({ code: 'demo_unavailable', message: 'Demo transport is unavailable' });
      return;
    }
    response.status(200).json(service.bootstrap());
  });
  app.get('/telemetry', (request, response) => {
    if (service === undefined) {
      response
        .status(503)
        .json({ code: 'demo_unavailable', message: 'Demo transport is unavailable' });
      return;
    }
    const cursor = request.header('Last-Event-ID') ?? request.query.after ?? '0';
    if (typeof cursor !== 'string' || !/^\d+$/.test(cursor)) {
      response.status(400).json({ code: 'invalid_cursor', message: 'Cursor must be numeric' });
      return;
    }
    const replayGap = service.replayGap(cursor);
    if (replayGap !== null) {
      response.status(409).json({ code: 'replay_gap', ...replayGap });
      return;
    }
    response.status(200).set({
      'Cache-Control': 'no-cache',
      Connection: 'keep-alive',
      'Content-Type': 'text/event-stream',
    });
    for (const delivery of service.deliveriesAfter(cursor)) {
      response.write(`id: ${String(delivery.deliveryId)}\ndata: ${JSON.stringify(delivery)}\n\n`);
    }
    response.end();
  });

  return app;
}
