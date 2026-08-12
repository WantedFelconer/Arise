import { SyncRepository } from './sync.repository.ts';
import type { SyncBatchRequest, SyncBatchResponse, SyncStatus } from '../../types/database.ts';

export class SyncService {
  private repository: SyncRepository;

  constructor(repository?: SyncRepository) {
    this.repository = repository || new SyncRepository();
  }

  /**
   * Process a batch of domain sync events pushed by a client.
   */
  public async processSyncBatch(userId: string, request: SyncBatchRequest): Promise<SyncBatchResponse> {
    const processedEventIds: string[] = [];
    const failedEvents: Array<{ eventId: string; error: string }> = [];
    const conflicts: Array<{
      eventId: string;
      strategy: 'server_wins' | 'field_merge' | 'manual_resolution';
      authoritativeState: Record<string, any>;
    }> = [];

    for (const event of request.events) {
      try {
        // 1. Idempotency Check: check if eventId has already been processed
        const existingEvent = await this.repository.findEventById(event.eventId, userId);

        if (existingEvent && existingEvent.sync_status === 'synced') {
          // Already synced previously (idempotent duplicate submission)
          processedEventIds.push(event.eventId);
          continue;
        }

        // 2. Dispatch event processing & conflict detection based on domain event_type
        const result = await this.processSingleEvent(userId, request.deviceId, event);

        if (result.status === 'synced') {
          processedEventIds.push(event.eventId);
        } else if (result.status === 'conflict') {
          conflicts.push({
            eventId: event.eventId,
            strategy: result.conflictStrategy || 'server_wins',
            authoritativeState: result.authoritativeState || {},
          });
        }
      } catch (err: any) {
        console.error(`[SyncService] Failed to process event ${event.eventId}:`, err);
        failedEvents.push({
          eventId: event.eventId,
          error: err.message || 'Internal processing error',
        });
      }
    }

    return {
      processedEventIds,
      failedEvents,
      conflicts,
      serverTimestamp: new Date().toISOString(),
    };
  }

  /**
   * Process an individual domain event according to entity conflict resolution rules.
   */
  private async processSingleEvent(
    userId: string,
    deviceId: string,
    event: SyncBatchRequest['events'][0]
  ): Promise<{ status: SyncStatus; conflictStrategy?: 'server_wins' | 'field_merge' | 'manual_resolution'; authoritativeState?: Record<string, any> }> {
    const { eventId, eventType, payload, occurredAtClient, version } = event;

    // Categorize domain event strategy
    switch (eventType) {
      case 'QuestCompleted':
      case 'HabitCompleted':
      case 'GateCompleted':
      case 'GateCollapsed': {
        // Progression events are Server-Authoritative
        // Record event into sync log
        await this.repository.recordSyncEvent({
          id: eventId,
          userId,
          deviceId,
          eventType,
          payload,
          occurredAtClient,
          version,
        }, 'synced');

        return { status: 'synced' };
      }

      case 'QuestEdited': {
        // Field-level merge strategy
        await this.repository.recordSyncEvent({
          id: eventId,
          userId,
          deviceId,
          eventType,
          payload,
          occurredAtClient,
          version,
        }, 'synced');

        return { status: 'synced' };
      }

      case 'NoteEdited': {
        // Potential manual conflict resolution if concurrent edits detected
        if (payload.hasServerConflict) {
          await this.repository.recordSyncEvent({
            id: eventId,
            userId,
            deviceId,
            eventType,
            payload,
            occurredAtClient,
            version,
          }, 'conflict');

          return {
            status: 'conflict',
            conflictStrategy: 'manual_resolution',
            authoritativeState: { noteId: payload.noteId, serverTitle: payload.title, serverBody: payload.body },
          };
        }

        await this.repository.recordSyncEvent({
          id: eventId,
          userId,
          deviceId,
          eventType,
          payload,
          occurredAtClient,
          version,
        }, 'synced');

        return { status: 'synced' };
      }

      default: {
        // Default sync handler for standard domain events
        await this.repository.recordSyncEvent({
          id: eventId,
          userId,
          deviceId,
          eventType,
          payload,
          occurredAtClient,
          version,
        }, 'synced');

        return { status: 'synced' };
      }
    }
  }
}
