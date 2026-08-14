import { describe, it, expect, beforeEach } from 'vitest';
import { BossRepository } from '../repository/boss.repository';
import { BossService } from '../service/boss.service';
import { memoryDb } from '../../../db/memory/memory-db';

describe('Bosses Module — Unit & Lifecycle Suite', () => {
  let bossRepository: BossRepository;
  let bossService: BossService;
  const testUserId = 'user-boss-test-1';

  beforeEach(() => {
    memoryDb.clear();
    bossRepository = new BossRepository();
    bossService = new BossService(bossRepository);
  });

  describe('1. Boss CRUD & Multi-Boss Support (FR-BOSS-001, FR-BOSS-004)', () => {
    it('creates multiple active bosses for a user', async () => {
      const boss1 = await bossService.createBoss(testUserId, {
        title: 'Compiler Project',
        hpMax: 200,
        difficulty: 'hard',
      });

      const boss2 = await bossService.createBoss(testUserId, {
        title: 'Marathon Training',
        hpMax: 150,
        difficulty: 'medium',
      });

      expect(boss1.id).toBeDefined();
      expect(boss2.id).toBeDefined();
      expect(boss1.hpCurrent).toBe(200);
      expect(boss1.status).toBe('active');

      const allBosses = await bossService.listBosses(testUserId);
      expect(allBosses.length).toBe(2);
    });
  });

  describe('2. Damage Application & Defeat (FR-BOSS-002, FR-BOSS-003)', () => {
    it('reduces Boss HP on damage and marks defeated with rewards at 0 HP', async () => {
      const boss = await bossService.createBoss(testUserId, {
        title: 'Mini Boss',
        hpMax: 50,
        difficulty: 'medium',
      });

      // Partial damage
      const dam1 = await bossService.applyDamage(testUserId, boss.id, 20);
      expect(dam1.boss.hpCurrent).toBe(30);
      expect(dam1.defeated).toBe(false);

      // Defeating damage
      const dam2 = await bossService.applyDamage(testUserId, boss.id, 35);
      expect(dam2.boss.hpCurrent).toBe(0);
      expect(dam2.defeated).toBe(true);
      expect(dam2.boss.status).toBe('defeated');
      expect(dam2.boss.defeatedAt).toBeDefined();
      expect(dam2.rewards).toBeDefined();
      expect(dam2.rewards?.xp).toBeGreaterThan(0);
    });
  });

  describe('3. Boss Lifecycle & Abandon/Reactivate (§7.3)', () => {
    it('transitions active -> abandoned -> active', async () => {
      const boss = await bossService.createBoss(testUserId, {
        title: 'Optional Project',
        hpMax: 100,
      });

      const abandoned = await bossService.abandonBoss(testUserId, boss.id);
      expect(abandoned.status).toBe('abandoned');

      const reactivated = await bossService.reactivateBoss(testUserId, boss.id);
      expect(reactivated.status).toBe('active');
    });
  });

  describe('4. Boss Defeat History (FR-BOSS-005)', () => {
    it('returns defeated bosses with time-to-defeat', async () => {
      const boss = await bossService.createBoss(testUserId, {
        title: 'Sprint 2 Boss',
        hpMax: 20,
      });

      await bossService.applyDamage(testUserId, boss.id, 25);

      const history = await bossService.getBossHistory(testUserId);
      expect(history.length).toBe(1);
      expect(history[0]!.title).toBe('Sprint 2 Boss');
      expect(history[0]!.timeToDefeatMs).toBeGreaterThanOrEqual(0);
    });
  });
});
