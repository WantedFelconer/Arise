import { describe, it, expect, beforeEach } from 'vitest';
import { DungeonRepository } from '../repository/dungeon.repository';
import { DungeonService } from '../service/dungeon.service';
import { BossRepository } from '../../bosses/repository/boss.repository';
import { BossService } from '../../bosses/service/boss.service';
import { memoryDb } from '../../../db/memory/memory-db';

describe('Dungeons Module — Unit & Progression Suite', () => {
  let dungeonRepository: DungeonRepository;
  let dungeonService: DungeonService;
  let bossService: BossService;
  const testUserId = 'user-dungeon-test-1';

  beforeEach(() => {
    memoryDb.clear();
    const bossRepo = new BossRepository();
    bossService = new BossService(bossRepo);
    dungeonRepository = new DungeonRepository();
    dungeonService = new DungeonService(dungeonRepository, bossService);
  });

  describe('1. Dungeon Creation & Boss Grouping (FR-DUNG-001)', () => {
    it('creates a dungeon and groups bosses', async () => {
      const dungeon = await dungeonService.createDungeon(testUserId, {
        title: 'Spring 2026 Semester',
      });

      const boss1 = await bossService.createBoss(testUserId, {
        title: 'Operating Systems Course',
        hpMax: 100,
        dungeonId: dungeon.id,
      });

      const boss2 = await bossService.createBoss(testUserId, {
        title: 'Database Systems Course',
        hpMax: 100,
        dungeonId: dungeon.id,
      });

      expect(boss1.id).toBeDefined();
      expect(boss2.id).toBeDefined();

      const details = await dungeonService.getDungeon(testUserId, dungeon.id);
      expect(details.totalBosses).toBe(2);
      expect(details.defeatedBosses).toBe(0);
      expect(details.progressPct).toBe(0);
      expect(details.status).toBe('active');
    });
  });

  describe('2. Dungeon Progress % and Auto-Complete (FR-DUNG-002, FR-DUNG-003)', () => {
    it('calculates progress percentage and marks completed when all bosses defeated', async () => {
      const dungeon = await dungeonService.createDungeon(testUserId, {
        title: 'Finals Week',
      });

      const boss1 = await bossService.createBoss(testUserId, {
        title: 'Exam 1',
        hpMax: 50,
        dungeonId: dungeon.id,
      });

      const boss2 = await bossService.createBoss(testUserId, {
        title: 'Exam 2',
        hpMax: 50,
        dungeonId: dungeon.id,
      });

      // Defeat boss 1 (50% progress)
      await bossService.applyDamage(testUserId, boss1.id, 50);

      const midDetails = await dungeonService.getDungeon(testUserId, dungeon.id);
      expect(midDetails.totalBosses).toBe(2);
      expect(midDetails.defeatedBosses).toBe(1);
      expect(midDetails.progressPct).toBe(50);
      expect(midDetails.status).toBe('active');

      // Defeat boss 2 (100% progress -> auto completed)
      await bossService.applyDamage(testUserId, boss2.id, 50);

      const finalDetails = await dungeonService.getDungeon(testUserId, dungeon.id);
      expect(finalDetails.totalBosses).toBe(2);
      expect(finalDetails.defeatedBosses).toBe(2);
      expect(finalDetails.progressPct).toBe(100);
      expect(finalDetails.status).toBe('completed');
    });
  });
});
