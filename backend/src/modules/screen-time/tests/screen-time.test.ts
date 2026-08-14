import { describe, it, expect, beforeEach } from 'vitest';
import { ScreenTimeRepository } from '../repository/screen-time.repository';
import { ScreenTimeService } from '../service/screen-time.service';
import { CharacterService } from '../../character/service/character.service';
import { CharacterRepository } from '../../character/repository/character.repository';
import { memoryDb } from '../../../db/memory/memory-db';

describe('ScreenTimeService (FR-SCREEN-001 & FR-SCREEN-002)', () => {
  let repository: ScreenTimeRepository;
  let characterRepo: CharacterRepository;
  let characterService: CharacterService;
  let service: ScreenTimeService;
  const userId = 'screen-time-user-1';

  beforeEach(() => {
    memoryDb.clear();
    characterRepo = new CharacterRepository();
    characterService = new CharacterService(characterRepo);
    repository = new ScreenTimeRepository();
    service = new ScreenTimeService(repository, characterService);

    // Seed initial character with 100 mana
    memoryDb.characters.set(userId, {
      id: 'char-1',
      userId,
      level: 1,
      totalXp: 0,
      currentMana: 100,
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

  it('proves server-authoritative Mana calculation under a spoofed-delta attack', async () => {
    // Client attempts to claim +500 Mana for 60 minutes of TikTok (high distraction, should be -16 Mana)
    const result = await service.ingestSessions(userId, {
      sessions: [
        {
          appPackage: 'com.zhiliaoapp.musically', // TikTok
          durationS: 3600, // 60 minutes
          manaDelta: 500, // Spoofed value!
          manaImpact: 500, // Spoofed value!
        },
      ],
    });

    // Server calculation: 60 mins of TikTok = -16 Mana
    expect(result.sessionsProcessed).toBe(1);
    expect(result.totalDurationMinutes).toBe(60);
    expect(result.totalManaImpact).toBe(-16);
    expect(result.categoryBreakdown['high_distraction'].manaImpact).toBe(-16);

    // Verify character mana in memory was updated authoritatively to 84 (100 - 16)
    const char = await characterService.getCharacter(userId);
    expect(char.currentMana).toBe(84);
  });

  it('applies positive Mana delta for productive IDE apps', async () => {
    const result = await service.ingestSessions(userId, {
      sessions: [
        {
          appPackage: 'com.microsoft.vscode',
          category: 'productive',
          durationS: 3600, // 60 mins -> +4 Mana
        },
      ],
    });

    expect(result.totalManaImpact).toBe(4);
    const char = await characterService.getCharacter(userId);
    expect(char.currentMana).toBe(100); // 100 clamped at max 100
  });

  it('respects user app category overrides', async () => {
    // Override a specific app (e.g. Duolingo as productive with +0.2/min)
    await service.setAppCategory(userId, 'com.duolingo', {
      category: 'educational',
      manaModifierPerMinute: 0.2, // +6 for 30 mins
    });

    const result = await service.ingestSessions(userId, {
      sessions: [
        {
          appPackage: 'com.duolingo',
          durationS: 1800, // 30 mins
        },
      ],
    });

    expect(result.totalManaImpact).toBe(6);
  });

  it('calculates distraction and app usage insights', async () => {
    await service.ingestSessions(userId, {
      sessions: [
        {
          appPackage: 'com.instagram.android',
          durationS: 1800,
          occurredAt: '2026-08-14T14:00:00Z',
        },
        {
          appPackage: 'com.microsoft.vscode',
          durationS: 3600,
          occurredAt: '2026-08-14T10:00:00Z',
        },
      ],
    });

    const insights = await service.getInsights(userId);
    expect(insights.totalDurationMinutes).toBe(90);
    expect(insights.mostUsedApps.length).toBe(2);
    expect(insights.mostUsedApps[0].appPackage).toBe('com.microsoft.vscode');
    expect(insights.peakDistractionHours).toContain(14);
  });
});
