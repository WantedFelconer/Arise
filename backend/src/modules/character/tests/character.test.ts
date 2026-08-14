import { describe, it, expect, beforeEach } from 'vitest';
import { RpgEngine } from '../../../core/rpg-engine';
import { CharacterService } from '../service/character.service';
import { CharacterRepository } from '../repository/character.repository';

describe('Core RPG Engine & Progression System', () => {
  let characterService: CharacterService;
  let characterRepository: CharacterRepository;

  beforeEach(() => {
    characterRepository = new CharacterRepository();
    characterRepository.clearMemoryStore();
    characterService = new CharacterService(characterRepository);
  });

  describe('FR-CHAR-001: Level Formula Math', () => {
    it('accurately computes levels across zero, thresholds, and large XP values', () => {
      // level = floor(0.1 * sqrt(total_xp)) + 1
      expect(RpgEngine.calculateLevel(0)).toBe(1);
      expect(RpgEngine.calculateLevel(50)).toBe(1);
      expect(RpgEngine.calculateLevel(99)).toBe(1);

      // Exact boundaries: 100 -> sqrt(100)=10 -> 0.1*10=1 -> 1+1=2
      expect(RpgEngine.calculateLevel(100)).toBe(2);
      expect(RpgEngine.calculateLevel(399)).toBe(2);
      expect(RpgEngine.calculateLevel(400)).toBe(3);
      expect(RpgEngine.calculateLevel(900)).toBe(4);
      expect(RpgEngine.calculateLevel(10000)).toBe(11);
      expect(RpgEngine.calculateLevel(1000000)).toBe(101);
    });

    it('calculates XP required for specific level target', () => {
      expect(RpgEngine.xpForLevel(1)).toBe(0);
      expect(RpgEngine.xpForLevel(2)).toBe(100);
      expect(RpgEngine.xpForLevel(3)).toBe(400);
      expect(RpgEngine.xpForLevel(4)).toBe(900);
      expect(RpgEngine.xpForLevel(11)).toBe(10000);
    });
  });

  describe('FR-CHAR-003: Config-Driven Rank Thresholds', () => {
    it('evaluates rank from level based on config table', () => {
      expect(RpgEngine.calculateRank(1)).toBe('E');
      expect(RpgEngine.calculateRank(9)).toBe('E');
      expect(RpgEngine.calculateRank(10)).toBe('D');
      expect(RpgEngine.calculateRank(24)).toBe('D');
      expect(RpgEngine.calculateRank(25)).toBe('C');
      expect(RpgEngine.calculateRank(44)).toBe('C');
      expect(RpgEngine.calculateRank(45)).toBe('B');
      expect(RpgEngine.calculateRank(69)).toBe('B');
      expect(RpgEngine.calculateRank(70)).toBe('A');
      expect(RpgEngine.calculateRank(99)).toBe('A');
      expect(RpgEngine.calculateRank(100)).toBe('S');
      expect(RpgEngine.calculateRank(250)).toBe('S');
    });
  });

  describe('FR-XP-002: XP Award Multiplier Formula', () => {
    it('computes pure XP calculation with difficulty, streak, and gate bonuses', () => {
      const xp = RpgEngine.calculateQuestXp({
        baseXp: 100,
        difficultyMultiplier: 1.5,
        streakBonus: 0.1,
        gateStabilityBonus: 0.2,
      });
      expect(xp).toBe(198);
    });

    it('handles default multipliers when bonuses are absent', () => {
      const xp = RpgEngine.calculateQuestXp({ baseXp: 50 });
      expect(xp).toBe(50);
    });
  });

  describe('FR-MANA-001: Mana Clamping', () => {
    it('clamps mana strictly within [0, max_mana]', () => {
      expect(RpgEngine.clampMana(50, 100)).toBe(50);
      expect(RpgEngine.clampMana(150, 100)).toBe(100);
      expect(RpgEngine.clampMana(-25, 100)).toBe(0);
      expect(RpgEngine.clampMana(0, 100)).toBe(0);
      expect(RpgEngine.clampMana(100, 100)).toBe(100);
    });
  });

  describe('FR-ENERGY-001: Circadian Intraday Curves', () => {
    it('computes hourly energy based on configured profile', () => {
      const earlyPeak = RpgEngine.calculateHourlyEnergy('early_bird', 8);
      expect(earlyPeak).toBe(100);

      const nightPeak = RpgEngine.calculateHourlyEnergy('night_owl', 19);
      expect(nightPeak).toBe(100);
    });
  });

  describe('Ledger-First Execution & Progression Service', () => {
    it('awards XP, writes transaction, updates level/rank and specific tagged stats', async () => {
      const userId = 'test-user-1';
      await characterRepository.createCharacter({ userId });

      const result = await characterService.awardXp(userId, {
        amount: 400,
        sourceType: 'quest',
        sourceId: 'quest-uuid-1',
        statKey: 'coding',
        reason: 'Implemented authentication module',
      });

      expect(result.xpAwarded).toBe(400);
      expect(result.newLevel).toBe(3);
      expect(result.newRank).toBe('E');
      expect((result.character.stats as unknown as Record<string, number>).coding).toBeGreaterThan(
        10,
      );

      const history = await characterService.getTransactionHistory(userId);
      expect(history.xpTransactions.length).toBe(1);
      expect(history.xpTransactions[0]?.amount).toBe(400);
      expect(history.xpTransactions[0]?.statKey).toBe('coding');

      const aggregates = await characterService.getXpAggregates(userId);
      expect(aggregates.today).toBe(400);
      expect(aggregates.lifetime).toBe(400);
    });

    it('modifies mana and enforces clamp invariants via ledger', async () => {
      const userId = 'test-user-2';
      await characterRepository.createCharacter({ userId });

      const depleteRes = await characterService.modifyMana(userId, {
        delta: -30,
        sourceType: 'screen_time',
        reason: 'Excessive Instagram browsing',
      });

      expect(depleteRes.currentMana).toBe(70);

      const clampRes = await characterService.modifyMana(userId, {
        delta: -100,
        sourceType: 'gate_collapse',
      });

      expect(clampRes.currentMana).toBe(0);

      const history = await characterService.getTransactionHistory(userId);
      expect(history.manaTransactions.length).toBe(2);
    });
  });
});
