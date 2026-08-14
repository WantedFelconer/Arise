import { Injectable, Inject, Optional } from '@nestjs/common';
import { FitnessRepository } from '../repository/fitness.repository';
import { CharacterService } from '../../character/service/character.service';
import { RpgEngine } from '../../../core/rpg-engine';
import {
  CreateFitnessLogDto,
  FitnessLogResponse,
  FitnessSummaryResponse,
} from '../dto/fitness.dto';

@Injectable()
export class FitnessService {
  constructor(
    @Inject(FitnessRepository) private fitnessRepository: FitnessRepository,
    @Optional() @Inject(CharacterService) private characterService?: CharacterService,
  ) {}

  /**
   * FR-FIT-001 & FR-FIT-002: Ingests fitness activity.
   * If threshold is met, awards XP & Mana via centralized RpgEngine.
   */
  async logActivity(userId: string, dto: CreateFitnessLogDto): Promise<FitnessLogResponse> {
    const log = await this.fitnessRepository.create(userId, dto);

    // Compute threshold progression reward via RpgEngine
    const reward = RpgEngine.calculateFitnessRewards(dto.logType, dto.value, dto.unit);

    if (reward.thresholdReached && this.characterService) {
      if (reward.xp > 0) {
        await this.characterService.awardXp(userId, {
          amount: reward.xp,
          sourceType: 'fitness',
          sourceId: log.id,
          statKey: reward.statKey,
          reason: `Fitness achievement: ${reward.label || dto.logType}`,
        });
      }

      if (reward.manaDelta > 0) {
        await this.characterService.modifyMana(userId, {
          delta: reward.manaDelta,
          sourceType: 'fitness',
          sourceId: log.id,
          reason: `Fitness recovery: ${reward.label || dto.logType}`,
        });
      }
    }

    return {
      id: log.id,
      userId: log.userId,
      logType: log.logType as any,
      value: log.value,
      unit: log.unit,
      recordedAt: log.recordedAt,
      metadata: log.metadata,
      rewards: {
        xpAwarded: reward.thresholdReached ? reward.xp : 0,
        manaDelta: reward.thresholdReached ? reward.manaDelta : 0,
        statKey: reward.statKey,
        thresholdReached: reward.thresholdReached,
        label: reward.label,
      },
      createdAt: log.createdAt,
    };
  }

  async listLogs(
    userId: string,
    filter?: { logType?: string; startDate?: string; endDate?: string; limit?: number; offset?: number },
  ): Promise<FitnessLogResponse[]> {
    const logs = await this.fitnessRepository.findByUser(userId, {
      logType: filter?.logType,
      startDate: filter?.startDate ? new Date(filter.startDate) : undefined,
      endDate: filter?.endDate ? new Date(filter.endDate) : undefined,
      limit: filter?.limit,
      offset: filter?.offset,
    });

    return logs.map((log) => ({
      id: log.id,
      userId: log.userId,
      logType: log.logType as any,
      value: log.value,
      unit: log.unit,
      recordedAt: log.recordedAt,
      metadata: log.metadata,
      createdAt: log.createdAt,
    }));
  }

  async getSummary(userId: string): Promise<FitnessSummaryResponse> {
    const logs = await this.fitnessRepository.findByUser(userId, { limit: 1000 });

    let totalSteps = 0;
    let totalWorkoutMinutes = 0;
    let totalWaterMl = 0;
    const sleepLogs: number[] = [];
    const hrLogs: number[] = [];
    let latestWeight: number | undefined;

    for (const log of logs) {
      if (log.logType === 'steps') totalSteps += log.value;
      if (log.logType === 'workout' || log.logType === 'exercise') totalWorkoutMinutes += log.value;
      if (log.logType === 'water') totalWaterMl += log.value;
      if (log.logType === 'sleep') sleepLogs.push(log.value);
      if (log.logType === 'heart_rate') hrLogs.push(log.value);
      if (log.logType === 'weight' && latestWeight === undefined) latestWeight = log.value;
    }

    const averageSleepHours =
      sleepLogs.length > 0 ? Number((sleepLogs.reduce((a, b) => a + b, 0) / sleepLogs.length).toFixed(1)) : 0;
    const averageHeartRateBpm =
      hrLogs.length > 0 ? Math.round(hrLogs.reduce((a, b) => a + b, 0) / hrLogs.length) : undefined;

    return {
      totalSteps,
      totalWorkoutMinutes,
      averageSleepHours,
      totalWaterMl,
      latestWeightKg: latestWeight,
      averageHeartRateBpm,
    };
  }
}
