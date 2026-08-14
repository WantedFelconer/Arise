import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ConflictException,
  Inject,
  forwardRef,
} from '@nestjs/common';
import { GateRepository } from '../repository/gate.repository';
import { QuestService } from '../../quests/service/quest.service';
import { RewardCascadeService } from '../../../core/reward-cascade';
import { StartGateSessionInput, CollapseGateSessionInput } from '../validation/gate.schema';
import { GateSessionResponse, GateStatsResponse } from '../dto/gate.dto';

@Injectable()
export class GateService {
  constructor(
    @Inject(GateRepository) private gateRepository: GateRepository,
    @Inject(forwardRef(() => QuestService)) private questService: QuestService,
    @Inject(forwardRef(() => RewardCascadeService))
    private rewardCascadeService: RewardCascadeService,
  ) {}

  /**
   * FR-GATE-001: Start a new Gate Expedition session
   */
  async startSession(userId: string, input: StartGateSessionInput): Promise<GateSessionResponse> {
    if (input.questId) {
      await this.questService.getQuest(userId, input.questId);
    }

    const session = await this.gateRepository.create({
      userId,
      questId: input.questId || null,
      plannedDurationS: input.plannedDurationSeconds,
      deviceId: input.deviceId || null,
      clientEventId: input.clientEventId || null,
    });

    return this.mapToResponse(session);
  }

  async getSession(userId: string, id: string): Promise<GateSessionResponse> {
    const session = await this.gateRepository.findById(id, userId);
    if (!session) {
      throw new NotFoundException({
        code: 'GATE_SESSION_NOT_FOUND',
        message: 'Gate session not found or access denied',
      });
    }

    return this.mapToResponse(session);
  }

  /**
   * FR-GATE-006: Pause session (Casual mode allows 1 pause; Hardcore mode disallows pausing)
   */
  async pauseSession(
    userId: string,
    id: string,
    userDifficultyMode: string = 'casual',
  ): Promise<GateSessionResponse> {
    const session = await this.gateRepository.findById(id, userId);
    if (!session) {
      throw new NotFoundException({
        code: 'GATE_SESSION_NOT_FOUND',
        message: 'Gate session not found or access denied',
      });
    }

    if (session.status !== 'active') {
      throw new BadRequestException({
        code: 'INVALID_GATE_STATE',
        message: `Cannot pause a gate session with status '${session.status}'`,
      });
    }

    if (userDifficultyMode === 'hardcore') {
      throw new BadRequestException({
        code: 'HARDCORE_PAUSE_DISALLOWED',
        message: 'Pausing is strictly disallowed in Hardcore Mode',
      });
    }

    if (session.pauseCount >= 1) {
      throw new BadRequestException({
        code: 'MAX_PAUSES_EXCEEDED',
        message: 'Maximum of 1 pause allowed per Gate session in Casual mode',
      });
    }

    const updated = await this.gateRepository.update(id, userId, {
      status: 'paused',
      pausedAt: new Date(),
      pauseCount: session.pauseCount + 1,
    });

    return this.mapToResponse(updated!);
  }

  /**
   * Resume paused session
   */
  async resumeSession(userId: string, id: string): Promise<GateSessionResponse> {
    const session = await this.gateRepository.findById(id, userId);
    if (!session) {
      throw new NotFoundException({
        code: 'GATE_SESSION_NOT_FOUND',
        message: 'Gate session not found or access denied',
      });
    }

    if (session.status !== 'paused') {
      throw new BadRequestException({
        code: 'INVALID_GATE_STATE',
        message: `Cannot resume a gate session with status '${session.status}'. Expected 'paused'`,
      });
    }

    const now = new Date();
    const s = session as unknown as Record<string, unknown>;
    const pausedAtDate = s.pausedAt ? new Date(s.pausedAt as string | Date) : null;
    const pausedDurationMs = pausedAtDate ? now.getTime() - pausedAtDate.getTime() : 0;
    const pausedDurationS = Math.max(0, Math.floor(pausedDurationMs / 1000));
    const prevPausedS = Number(s.totalPausedDurationS) || 0;

    const updated = await this.gateRepository.update(id, userId, {
      status: 'active',
      pausedAt: null,
      totalPausedDurationS: prevPausedS + pausedDurationS,
    });

    return this.mapToResponse(updated!);
  }

  /**
   * FR-GATE-003 & FR-GATE-004: Complete Gate Expedition (100% stability reached)
   */
  async completeSession(userId: string, id: string): Promise<GateSessionResponse> {
    const session = await this.gateRepository.findById(id, userId);
    if (!session) {
      throw new NotFoundException({
        code: 'GATE_SESSION_NOT_FOUND',
        message: 'Gate session not found or access denied',
      });
    }

    if (session.status === 'cleared' || session.status === 'collapsed') {
      throw new ConflictException({
        code: 'GATE_ALREADY_RESOLVED',
        message: `Gate session is already ${session.status}`,
      });
    }

    const { stabilityPct, elapsedSeconds } = this.calculateServerStability(session);

    if (stabilityPct < 100) {
      throw new BadRequestException({
        code: 'GATE_NOT_READY',
        message: `Gate stability is at ${stabilityPct}%. Must reach 100% to clear.`,
      });
    }

    // Execute Gate Clear Reward Cascade
    const cascadeResult = await this.rewardCascadeService.executeGateClearRewardCascade(
      userId,
      session,
      100,
    );

    const updated = await this.gateRepository.update(id, userId, {
      status: 'cleared',
      stabilityFinal: 100,
      actualDurationS: elapsedSeconds,
      xpAwarded: cascadeResult.xpDelta,
      manaDelta: cascadeResult.manaDelta,
      endedAt: new Date(),
    });

    return this.mapToResponse(updated!);
  }

  /**
   * FR-GATE-005 & §19 AC-GATE-005: Collapse Gate Expedition (Early exit penalty)
   */
  async collapseSession(
    userId: string,
    id: string,
    userDifficultyMode: string = 'casual',
    input?: CollapseGateSessionInput,
  ): Promise<GateSessionResponse> {
    const session = await this.gateRepository.findById(id, userId);
    if (!session) {
      throw new NotFoundException({
        code: 'GATE_SESSION_NOT_FOUND',
        message: 'Gate session not found or access denied',
      });
    }

    if (session.status === 'cleared' || session.status === 'collapsed') {
      throw new ConflictException({
        code: 'GATE_ALREADY_RESOLVED',
        message: `Gate session is already ${session.status}`,
      });
    }

    const { stabilityPct, elapsedSeconds } = this.calculateServerStability(session);

    // Execute Gate Collapse Reward Cascade
    const cascadeResult = await this.rewardCascadeService.executeGateCollapseRewardCascade(
      userId,
      session,
      userDifficultyMode,
    );

    const updated = await this.gateRepository.update(id, userId, {
      status: 'collapsed',
      stabilityFinal: stabilityPct,
      actualDurationS: elapsedSeconds,
      exitReason: input?.exitReason || 'user_exit',
      xpAwarded: cascadeResult.xpDelta,
      manaDelta: cascadeResult.manaDelta,
      endedAt: new Date(),
    });

    return this.mapToResponse(updated!);
  }

  /**
   * FR-GATE-007: Expedition statistics
   */
  async getStats(userId: string): Promise<GateStatsResponse> {
    const sessions = await this.gateRepository.findMany(userId);

    const cleared = sessions.filter((s) => s.status === 'cleared');
    const collapsed = sessions.filter((s) => s.status === 'collapsed');

    const totalSessions = sessions.length;
    const totalCleared = cleared.length;
    const totalCollapsed = collapsed.length;
    const resolvedCount = totalCleared + totalCollapsed;
    const successRatePct =
      resolvedCount === 0 ? 0 : Math.round((totalCleared / resolvedCount) * 100);

    let longestExpeditionSeconds = 0;
    let totalFocusTimeSeconds = 0;

    for (const s of sessions) {
      const dur = s.actualDurationS || 0;
      totalFocusTimeSeconds += dur;
      if (s.status === 'cleared' && dur > longestExpeditionSeconds) {
        longestExpeditionSeconds = dur;
      }
    }

    return {
      totalSessions,
      totalCleared,
      totalCollapsed,
      successRatePct,
      longestExpeditionSeconds,
      totalFocusTimeSeconds,
    };
  }

  /**
   * FR-GATE-008 (Anti-tamper) & FR-GATE-002:
   * Stability is monotonically calculated server-side from server clock startedAt & plannedDurationS.
   */
  private calculateServerStability(session: unknown): {
    stabilityPct: number;
    elapsedSeconds: number;
  } {
    const s = session as Record<string, unknown>;
    if (s.status === 'cleared') {
      return {
        stabilityPct: (s.stabilityFinal as number) ?? 100,
        elapsedSeconds: (s.actualDurationS as number) || (s.plannedDurationS as number),
      };
    }
    if (s.status === 'collapsed') {
      return {
        stabilityPct: (s.stabilityFinal as number) ?? 0,
        elapsedSeconds: (s.actualDurationS as number) || 0,
      };
    }

    const now = Date.now();
    const pausedTotalMs = (Number(s.totalPausedDurationS) || 0) * 1000;
    const startedAtTime = new Date(s.startedAt as string | Date).getTime();
    let elapsedMs = now - startedAtTime - pausedTotalMs;

    if (s.status === 'paused' && s.pausedAt) {
      const currentPauseMs = now - new Date(s.pausedAt as string | Date).getTime();
      elapsedMs -= currentPauseMs;
    }

    const elapsedSeconds = Math.max(0, Math.floor(elapsedMs / 1000));
    const plannedDurationS = Number(s.plannedDurationS) || 1;
    const stabilityPct = Math.min(
      100,
      Math.max(0, Math.floor((elapsedSeconds / plannedDurationS) * 100)),
    );

    return { stabilityPct, elapsedSeconds };
  }

  private mapToResponse(session: unknown): GateSessionResponse {
    const s = session as Record<string, unknown>;
    const { stabilityPct, elapsedSeconds } = this.calculateServerStability(s);

    return {
      id: s.id as string,
      userId: s.userId as string,
      questId: (s.questId as string) ?? null,
      plannedDurationS: Number(s.plannedDurationS),
      actualDurationS: (Number(s.actualDurationS) || elapsedSeconds) as number,
      pauseCount: (Number(s.pauseCount) || 0) as number,
      status: s.status as 'active' | 'paused' | 'cleared' | 'collapsed',
      stabilityPct,
      stabilityFinal: (s.stabilityFinal as number) ?? null,
      xpAwarded: (s.xpAwarded as number) ?? null,
      manaDelta: (s.manaDelta as number) ?? null,
      exitReason: (s.exitReason as string) ?? null,
      startedAt: s.startedAt as Date,
      endedAt: (s.endedAt as Date) ?? null,
    };
  }
}
