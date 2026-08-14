/**
 * In-Process Domain Event Bus
 * Provides decoupled event dispatch and subscription across feature modules.
 */

export type EventHandler<T = unknown> = (payload: T) => Promise<void> | void;

export class DomainEventBus {
  private handlers: Map<string, EventHandler[]>;

  constructor() {
    this.handlers = new Map();
  }

  subscribe<T>(eventName: string, handler: EventHandler<T>): void {
    const existing = this.handlers.get(eventName) ?? [];
    this.handlers.set(eventName, [...existing, handler as EventHandler]);
  }

  async emit<T>(eventName: string, payload: T): Promise<void> {
    const handlers = this.handlers.get(eventName) ?? [];
    for (const handler of handlers) {
      try {
        await handler(payload);
      } catch (err) {
        // Log event dispatch failure without crashing caller
        console.error(`[EventBus] Error handling event ${eventName}:`, err);
      }
    }
  }

  clear(): void {
    this.handlers.clear();
  }
}

export const eventBus = new DomainEventBus();
