import { describe, it, expect, beforeEach } from 'vitest';
import { GateRepository } from '../repository/gate.repository';
import { GateService } from '../service/gate.service';
import { QuestRepository } from '../../quests/repository/quest.repository';
import { QuestService } from '../../quests/service/quest.service';
import { BossRepository } from '../../bosses/repository/boss.repository';
import { BossService } from '../../bosses/service/boss.service';
import { CharacterRepository } from '../../character/repository/character.repository';
import { CharacterService } from '../../character/service/character.service';
import { AchievementRepository } from '../../achievements/repository/achievement.repository';
import { AchievementService } from '../../achievements/service/achievement.service';
import { RewardCascadeService } from '../../../core/reward-cascade';
import { memoryDb } from '../../../db/memory/memory-db';

describe('Gates Module — Unit & Focus Session Suite', () => {
  let gateRepository: GateRepository;
  let gateService: GateService;
  let questService: QuestService;
  let bossService: BossService;
  let characterService: CharacterService;
  let rewardCascadeService: RewardCascadeService;
  const testUserId = 'user-gate-test-1';

  beforeEach(async () => {
    memoryDb.clear();

    const charRepo = new CharacterRepository();
    characterService = new CharacterService(charRepo);
    await charRepo.createCharacter({ userId: testUserId });

    const bossRepo = new BossRepository();
    bossService = new BossService(bossRepo);

    const achRepo = new AchievementRepository();
    const achievementService = new AchievementService(achRepo, characterService);

    const questRepo = new QuestRepository();
    rewardCascadeService = new RewardCascadeService(
      characterService,
      bossService,
      achievementService,
      questRepo,
    );

    questService = new QuestService(questRepo, bossService, characterService, rewardCascadeService);

    gateRepository = new GateRepository();
    gateService = new GateService(gateRepository, questService, rewardCascadeService);
  });

  describe('1. Session Starting and Anti-Tamper Calculation (FR-GATE-001, FR-GATE-008)', () => {
    it('starts session and calculates stability from server timestamps', async () => {
      const session = await gateService.startSession(testUserId, {
        plannedDurationSeconds: 1500, // 25 min
      });

      expect(session.id).toBeDefined();
      expect(session.status).toBe('active');
      expect(session.plannedDurationS).toBe(1500);
      expect(session.stabilityPct).toBeGreaterThanOrEqual(0);
      expect(session.pauseCount).toBe(0);
    });
  });

  describe('2. Pause & Resume Mechanics (FR-GATE-006)', () => {
    it('allows 1 pause in casual mode and rejects second pause', async () => {
      const session = await gateService.startSession(testUserId, {
        plannedDurationSeconds: 1500,
      });

      const paused = await gateService.pauseSession(testUserId, session.id, 'casual');
      expect(paused.status).toBe('paused');
      expect(paused.pauseCount).toBe(1);

      const resumed = await gateService.resumeSession(testUserId, session.id);
      expect(resumed.status).toBe('active');

      // Second pause attempt in casual mode should throw MAX_PAUSES_EXCEEDED
      await expect(gateService.pauseSession(testUserId, session.id, 'casual')).rejects.toThrow(
        /Maximum of 1 pause allowed/i,
      );
    });

    it('strictly disallows pausing in Hardcore Mode', async () => {
      const session = await gateService.startSession(testUserId, {
        plannedDurationSeconds: 1500,
      });

      await expect(gateService.pauseSession(testUserId, session.id, 'hardcore')).rejects.toThrow(
        /Pausing is strictly disallowed/i,
      );
    });
  });

  describe('3. Gate Collapse & Penalties (FR-GATE-005)', () => {
    it('applies collapse penalties and updates session status to collapsed', async () => {
      const session = await gateService.startSession(testUserId, {
        plannedDurationSeconds: 1500,
      });

      const collapsed = await gateService.collapseSession(testUserId, session.id, 'casual', {
        exitReason: 'phone_distraction',
      });

      expect(collapsed.status).toBe('collapsed');
      expect(collapsed.exitReason).toBe('phone_distraction');
      expect(collapsed.endedAt).toBeDefined();
    });
  });

  describe('4. Gate Statistics (FR-GATE-007)', () => {
    it('aggregates total sessions, cleared, collapsed, and success rate', async () => {
      const session1 = await gateService.startSession(testUserId, { plannedDurationSeconds: 60 });
      // Simulate fast clear by updating startedAt in memory store
      const stored = memoryDb.gateSessions.get(session1.id)!;
      stored.startedAt = new Date(Date.now() - 70000); // 70s ago

      await gateService.completeSession(testUserId, session1.id);

      const session2 = await gateService.startSession(testUserId, { plannedDurationSeconds: 60 });
      await gateService.collapseSession(testUserId, session2.id, 'casual');

      const stats = await gateService.getStats(testUserId);
      expect(stats.totalSessions).toBe(2);
      expect(stats.totalCleared).toBe(1);
      expect(stats.totalCollapsed).toBe(1);
      expect(stats.successRatePct).toBe(50);
    });
  });
});
