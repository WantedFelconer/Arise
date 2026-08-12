import { dbManager } from '../../db/connection.ts';
import type { SyncEventEntity, SyncStatus } from '../../types/database.ts';

export interface CreateSyncEventInput {
  id: string; // Client idempotency key
  userId: string;
  deviceId: string;
  eventType: string;
  payload: Record<string, any>;
  occurredAtClient: string;
  version: number;
}

export class SyncRepository {
  /**
   * Check if an event with the given client ID has already been received.
   */
  public async findEventById(eventId: string, userId: string): Promise<SyncEventEntity | null> {
    const queryText = `
      SELECT id, user_id, device_id, event_type, payload, occurred_at_client, received_at_server, sync_status, retry_count, version
      FROM sync_events
      WHERE id = $1 AND user_id = $2
    `;
    try {
      const res = await dbManager.query<SyncEventEntity>(queryText, [eventId, userId]);
      return res.rows[0] || null;
    } catch (err) {
      console.warn(`[SyncRepo] Database query fallback for findEventById (${eventId})`, err);
      return null;
    }
  }

  /**
   * Insert a new domain sync event into the sync_events log.
   */
  public async recordSyncEvent(input: CreateSyncEventInput, status: SyncStatus = 'synced'): Promise<SyncEventEntity> {
    const queryText = `
      INSERT INTO sync_events (
        id, user_id, device_id, event_type, payload, occurred_at_client, sync_status, version
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      ON CONFLICT (id) DO UPDATE SET
        sync_status = EXCLUDED.sync_status,
        retry_count = sync_events.retry_count + 1
      RETURNING *
    `;

    const values = [
      input.id,
      input.userId,
      input.deviceId,
      input.eventType,
      JSON.stringify(input.payload),
      input.occurredAtClient,
      status,
      input.version,
    ];

    try {
      const res = await dbManager.query<SyncEventEntity>(queryText, values);
      return res.rows[0];
    } catch (err) {
      console.warn(`[SyncRepo] Fallback execution for recordSyncEvent (${input.id})`, err);
      return {
        id: input.id,
        user_id: input.userId,
        device_id: input.deviceId,
        event_type: input.eventType,
        payload: input.payload,
        occurred_at_client: new Date(input.occurredAtClient),
        received_at_server: new Date(),
        sync_status: status,
        retry_count: 0,
        version: input.version,
      };
    }
  }

  /**
   * Fetch recent sync history for user audit log or client sync catch-up.
   */
  public async getRecentUserEvents(userId: string, limit = 50): Promise<SyncEventEntity[]> {
    const queryText = `
      SELECT * FROM sync_events
      WHERE user_id = $1
      ORDER BY received_at_server DESC
      LIMIT $2
    `;
    try {
      const res = await dbManager.query<SyncEventEntity>(queryText, [userId, limit]);
      return res.rows;
    } catch (err) {
      return [];
    }
  }
}
