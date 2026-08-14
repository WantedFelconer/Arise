import { describe, it, expect, beforeEach } from 'vitest';
import { FitnessRepository } from '../repository/fitness.repository';
import { FitnessService } from '../service/fitness.service';
import { CharacterService } from '../../character/service/character.service';
import { CharacterRepository } from '../../character/repository/character.repository';
import { memoryDb } from '../../../db/memory/memory-db';

describe('FitnessService (FR-FIT-001 & FR-FIT-002)', () => {
  let repository: FitnessRepository;
  let characterRepo: CharacterRepository;
  let characterService: CharacterService;
  let service: FitnessService;
  const userId = 'fitness-test-user-1';

  beforeEach(() => {
    memoryDb.clear();
    characterRepo = new CharacterRepository();
    characterService = new CharacterService(characterRepo);
    repository = new FitnessRepository();
    service = new FitnessService(repository, characterService);

    memoryDb.characters.set(userId, {
      id: 'char-1',
      userId,
      level: 1,
      totalXp: 0,
      currentMana: 50,
      maxMana: 100,
      coins: 0,
      gems: 0,
      rank: 'E',
      activeTitleId: null,
      stats: {
        intelligence: 10,
        discipline: 10,
        fitness: 10,
        creativity: 10,
        coding: 10,
        business: 10,
        health: 10,
      },
      updatedAt: new Date(),
    });
  });

  it('awards XP and Mana when activity exceeds threshold (8000 steps)', async () => {
    const res = await service.logActivity(userId, {
      logType: 'steps',
      value: 8500,
      unit: 'count',
    });

    expect(res.rewards?.thresholdReached).toBe(true);
    expect(res.rewards?.xpAwarded).toBe(50);
    expect(res.rewards?.manaDelta).toBe(10);
    expect(res.rewards?.statKey).toBe('fitness');

    const char = await characterService.getCharacter(userId);
    expect(char.totalXp).toBe(50);
    expect(char.currentMana).toBe(60); // 50 + 10
    expect(char.stats.fitness).toBe(11);
  });

  it('does NOT award XP or Mana when activity is below threshold (2000 steps)', async () => {
    const res = await service.logActivity(userId, {
      logType: 'steps',
      value: 2000,
      unit: 'count',
    });

    expect(res.rewards?.thresholdReached).toBe(false);
    expect(res.rewards?.xpAwarded).toBe(0);
    expect(res.rewards?.manaDelta).toBe(0);

    const char = await characterService.getCharacter(userId);
    expect(char.totalXp).toBe(0);
    expect(char.currentMana).toBe(50);
  });

  it('computes aggregated fitness summary', async () => {
    await service.logActivity(userId, { logType: 'steps', value: 8000, unit: 'count' });
    await service.logActivity(userId, { logType: 'steps', value: 4000, unit: 'count' });
    await service.logActivity(userId, { logType: 'workout', value: 45, unit: 'minutes' });
    await service.logActivity(userId, { logType: 'sleep', value: 7.5, unit: 'hours' });
    await service.logActivity(userId, { logType: 'water', value: 2000, unit: 'ml' });

    const summary = await service.getSummary(userId);
    expect(summary.totalSteps).toBe(12000);
    expect(summary.totalWorkoutMinutes).toBe(45);
    expect(summary.totalWaterMl).toBe(2000);
    expect(summary.averageSleepHours).toBe(7.5);
  });
});
