export interface SseConnection {
  on(event: 'close', listener: () => void): unknown;
  write(chunk: string): unknown;
}

type IntervalHandle = ReturnType<typeof setInterval>;
type IntervalStarter = (callback: () => void, intervalMs: number) => IntervalHandle;
type IntervalStopper = (handle: IntervalHandle) => void;

/// Owns active SSE clients for the demo process. It is deliberately transport
/// only: SQLite remains the replay source after a reconnect.
export class SseConnectionRegistry {
  constructor({
    heartbeatIntervalMs = 15_000,
    startInterval = setInterval,
    stopInterval = clearInterval,
  }: {
    heartbeatIntervalMs?: number;
    startInterval?: IntervalStarter;
    stopInterval?: IntervalStopper;
  } = {}) {
    this.heartbeatIntervalMs = heartbeatIntervalMs;
    this.startInterval = startInterval;
    this.stopInterval = stopInterval;
  }

  private readonly connections = new Set<SseConnection>();
  private readonly heartbeatIntervalMs: number;
  private readonly startInterval: IntervalStarter;
  private readonly stopInterval: IntervalStopper;
  private heartbeat: IntervalHandle | undefined;

  get size(): number {
    return this.connections.size;
  }

  add(connection: SseConnection): void {
    this.connections.add(connection);
    connection.on('close', () => {
      this.remove(connection);
    });
    this.ensureHeartbeat();
  }

  broadcast(delivery: Readonly<Record<string, unknown>>): void {
    this.writeAll(`id: ${String(delivery.deliveryId)}\ndata: ${JSON.stringify(delivery)}\n\n`);
  }

  close(): void {
    if (this.heartbeat !== undefined) {
      this.stopInterval(this.heartbeat);
      this.heartbeat = undefined;
    }
    this.connections.clear();
  }

  private remove(connection: SseConnection): void {
    this.connections.delete(connection);
    if (this.connections.size === 0 && this.heartbeat !== undefined) {
      this.stopInterval(this.heartbeat);
      this.heartbeat = undefined;
    }
  }

  private ensureHeartbeat(): void {
    this.heartbeat ??= this.startInterval(() => {
      this.writeAll(': heartbeat\n\n');
    }, this.heartbeatIntervalMs);
  }

  private writeAll(chunk: string): void {
    for (const connection of this.connections) {
      connection.write(chunk);
    }
  }
}
