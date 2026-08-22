import { describe, expect, it } from 'vitest';

import {
  type SseConnection,
  SseConnectionRegistry,
} from '../src/transport/sse-connection-registry.js';

describe('SseConnectionRegistry', () => {
  it('given_connected_clients_when_a_live_delivery_is_broadcast_then_writes_one_sse_event_to_each', () => {
    const registry = new SseConnectionRegistry();
    const first = new FakeConnection();
    const second = new FakeConnection();
    registry.add(first);
    registry.add(second);

    registry.broadcast({ deliveryId: '42', packet: { packetId: 'packet-42' } });

    expect(first.chunks).toEqual([
      'id: 42\ndata: {"deliveryId":"42","packet":{"packetId":"packet-42"}}\n\n',
    ]);
    expect(second.chunks).toEqual(first.chunks);
    registry.close();
  });

  it('given_connected_client_when_heartbeat_runs_then_writes_comment_and_cleans_up_on_close', () => {
    let heartbeat: (() => void) | undefined;
    let stopped = false;
    const registry = new SseConnectionRegistry({
      startInterval: (callback) => {
        heartbeat = callback;
        return 1 as unknown as ReturnType<typeof setInterval>;
      },
      stopInterval: () => {
        stopped = true;
      },
    });
    const connection = new FakeConnection();
    registry.add(connection);

    heartbeat?.();
    connection.close();

    expect(connection.chunks).toEqual([': heartbeat\n\n']);
    expect(registry.size).toBe(0);
    expect(stopped).toBe(true);
  });

  it('given_active_heartbeat_when_registry_closed_then_stops_it_and_forgets_clients', () => {
    let stopped = false;
    const registry = new SseConnectionRegistry({
      startInterval: () => 1 as unknown as ReturnType<typeof setInterval>,
      stopInterval: () => {
        stopped = true;
      },
    });
    registry.add(new FakeConnection());

    registry.close();

    expect(registry.size).toBe(0);
    expect(stopped).toBe(true);
  });
});

class FakeConnection implements SseConnection {
  readonly chunks: string[] = [];
  private closeListener: (() => void) | undefined;

  on(event: 'close', listener: () => void): unknown {
    this.closeListener = event === 'close' ? listener : undefined;
    return undefined;
  }

  write(chunk: string): unknown {
    this.chunks.push(chunk);
    return undefined;
  }

  close(): void {
    this.closeListener?.();
  }
}
