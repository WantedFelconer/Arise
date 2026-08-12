export interface AntiCheatValidationInput {
  eventType: string;
  payload: Record<string, any>;
  occurredAtClient: string;
}

export interface AntiCheatValidationResult {
  valid: boolean;
  reason?: string;
  flaggedForAudit: boolean;
}

export class AntiCheatMiddleware {
  private static MAX_CLOCK_DRIFT_MS = 10 * 60 * 1000; // 10 minutes

  /**
   * Validate incoming client domain events against anti-cheat bounds (FR-VALID-1, FR-VALID-2).
   */
  public static validateEvent(input: AntiCheatValidationInput): AntiCheatValidationResult {
    const clientTime = new Date(input.occurredAtClient).getTime();
    const serverTime = Date.now();

    // 1. Clock Drift Bounds Check (Timestamp spoofing prevention)
    if (isNaN(clientTime) || Math.abs(serverTime - clientTime) > this.MAX_CLOCK_DRIFT_MS) {
      return {
        valid: false,
        reason: 'Event timestamp exhibits clock drift beyond allowed threshold (10m).',
        flaggedForAudit: true,
      };
    }

    // 2. Gate Focus Session Sanity Validation
    if (input.eventType === 'GateCompleted' || input.eventType === 'GateCollapsed') {
      const { actualDurationSeconds, plannedDurationSeconds } = input.payload;

      if (actualDurationSeconds < 0 || actualDurationSeconds > 86400) {
        return {
          valid: false,
          reason: 'Gate session duration is outside physical bounds.',
          flaggedForAudit: true,
        };
      }

      // Check if client submitted suspicious XP values directly
      if ('xpAwarded' in input.payload || 'level' in input.payload) {
        return {
          valid: false,
          reason: 'Client-submitted progression state rejected. Server recalculation mandatory (FR-VALID-1).',
          flaggedForAudit: true,
        };
      }
    }

    // 3. Quest Completion Sanity Check
    if (input.eventType === 'QuestCompleted') {
      if ('xp' in input.payload || 'characterLevel' in input.payload) {
        return {
          valid: false,
          reason: 'Client attempt to directly mutate XP/Level rejected (FR-VALID-1).',
          flaggedForAudit: true,
        };
      }
    }

    return {
      valid: true,
      flaggedForAudit: false,
    };
  }
}
