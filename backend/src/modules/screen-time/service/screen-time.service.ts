import { Injectable, Inject, Optional } from '@nestjs/common';
import { ScreenTimeRepository } from '../repository/screen-time.repository';
import { CharacterService } from '../../character/service/character.service';
import { RpgEngine } from '../../../core/rpg-engine';
import {
  IngestSessionsDto,
  IngestSessionsResponse,
  ScreenTimeInsightResponse,
  SetAppCategoryDto,
} from '../dto/screen-time.dto';
import screenTimeConfig from '../../../config/screen_time_modifiers.json';

@Injectable()
export class ScreenTimeService {
  constructor(
    @Inject(ScreenTimeRepository) private screenTimeRepository: ScreenTimeRepository,
    @Optional() @Inject(CharacterService) private characterService?: CharacterService,
  ) {}

  /**
   * FR-SCREEN-001 & FR-SCREEN-002: Batch-log app usage sessions.
   * STRICT ANTI-CHEAT: Server computes Mana delta via RpgEngine, discarding any client-supplied delta.
   */
  async ingestSessions(userId: string, dto: IngestSessionsDto): Promise<IngestSessionsResponse> {
    const userOverrides = await this.screenTimeRepository.getUserAppOverrides(userId);

    const preparedSessions: Array<{
      appPackage: string;
      category: string;
      durationS: number;
      occurredAt: Date;
      manaModifierApplied: number;
    }> = [];

    let totalDurationS = 0;
    let totalManaImpact = 0;
    const categoryBreakdown: Record<string, { durationMinutes: number; manaImpact: number }> = {};

    for (const session of dto.sessions) {
      // Recompute mana impact server-side (ignore session.manaDelta/manaImpact)
      const { category, manaDelta } = RpgEngine.calculateScreenTimeManaImpact(session, userOverrides);

      const occurredAt = session.occurredAt ? new Date(session.occurredAt) : new Date();

      preparedSessions.push({
        appPackage: session.appPackage,
        category,
        durationS: session.durationS,
        occurredAt,
        manaModifierApplied: manaDelta,
      });

      totalDurationS += session.durationS;
      totalManaImpact += manaDelta;

      const durMins = Math.round(session.durationS / 60);
      if (!categoryBreakdown[category]) {
        categoryBreakdown[category] = { durationMinutes: 0, manaImpact: 0 };
      }
      categoryBreakdown[category].durationMinutes += durMins;
      categoryBreakdown[category].manaImpact += manaDelta;
    }

    // Persist sessions
    await this.screenTimeRepository.createSessions(userId, preparedSessions);

    // Apply authoritative Mana change to character ledger
    if (totalManaImpact !== 0 && this.characterService) {
      await this.characterService.modifyMana(userId, {
        delta: totalManaImpact,
        sourceType: 'screen_time',
        reason: `Screen time batch impact (${Math.round(totalDurationS / 60)} min)`,
      });
    }

    return {
      sessionsProcessed: preparedSessions.length,
      totalDurationMinutes: Math.round(totalDurationS / 60),
      totalManaImpact,
      categoryBreakdown,
    };
  }

  /**
   * Returns distraction and productivity insights for user
   */
  async getInsights(userId: string): Promise<ScreenTimeInsightResponse> {
    const sessions = await this.screenTimeRepository.findSessionsByUser(userId);

    let totalDurationS = 0;
    let netManaImpact = 0;
    const appMap = new Map<string, { durationS: number; category: string; manaImpact: number }>();
    const categoryBreakdown: Record<string, { durationMinutes: number; manaImpact: number }> = {};
    const hourCounts: Record<number, number> = {};

    for (const s of sessions) {
      totalDurationS += s.durationS;
      netManaImpact += s.manaModifierApplied;

      // App stats
      const app = appMap.get(s.appPackage) || { durationS: 0, category: s.category, manaImpact: 0 };
      app.durationS += s.durationS;
      app.manaImpact += s.manaModifierApplied;
      appMap.set(s.appPackage, app);

      // Category breakdown
      const durMins = Math.round(s.durationS / 60);
      if (!categoryBreakdown[s.category]) {
        categoryBreakdown[s.category] = { durationMinutes: 0, manaImpact: 0 };
      }
      categoryBreakdown[s.category].durationMinutes += durMins;
      categoryBreakdown[s.category].manaImpact += s.manaModifierApplied;

      // Track distraction hours
      if (s.category === 'high_distraction' || s.category === 'entertainment') {
        const hour = new Date(s.occurredAt).getUTCHours();
        hourCounts[hour] = (hourCounts[hour] || 0) + s.durationS;
      }
    }

    const mostUsedApps = Array.from(appMap.entries())
      .map(([appPackage, data]) => ({
        appPackage,
        durationMinutes: Math.round(data.durationS / 60),
        category: data.category,
        manaImpact: data.manaImpact,
      }))
      .sort((a, b) => b.durationMinutes - a.durationMinutes)
      .slice(0, 10);

    const peakDistractionHours = Object.entries(hourCounts)
      .sort(([, a], [, b]) => b - a)
      .slice(0, 3)
      .map(([hour]) => Number(hour));

    return {
      totalDurationMinutes: Math.round(totalDurationS / 60),
      netManaImpact,
      mostUsedApps,
      categoryBreakdown,
      peakDistractionHours,
    };
  }

  async getCategoryConfig(userId: string) {
    const userOverrides = await this.screenTimeRepository.getUserAppOverrides(userId);
    return {
      defaults: screenTimeConfig.categories,
      userOverrides: Array.from(userOverrides.values()),
    };
  }

  async setAppCategory(
    userId: string,
    appPackage: string,
    dto: SetAppCategoryDto,
  ) {
    const override = await this.screenTimeRepository.upsertAppCategory(
      userId,
      appPackage,
      dto.category,
      dto.manaModifierPerMinute,
    );
    return { data: override };
  }
}
