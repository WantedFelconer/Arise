import { describe, it, expect, beforeEach } from 'vitest';
import { SyncService } from '../service/sync.service';
import { IdempotencyService } from '../../../core/idempotency/idempotency.service';
import { CharacterService } from '../../character/service/character.service';
import { CharacterRepository } from '../../character/repository/character.repository';

describe('Sync Foundation & Idempotency Engine', () => {
  let syncService: SyncService;
  let idempotencyService: IdempotencyService;
  let characterService: CharacterService;
  let characterRepository: CharacterRepository;

  beforeEach(() => {
    idempotencyService = new IdempotencyService();
    idempotencyService.clearMemoryStore();
    characterRepository = new CharacterRepository();
    characterRepository.clearMemoryStore();
    characterService = new CharacterService(characterRepository);
    syncService = new SyncService(idempotencyService, characterService);
  });

  it('rejects progression write if Idempotency-Key is missing', async () => {
    await expect(syncService.executeTestCommand('user-1', undefined, 100)).rejects.toThrow(
      /Idempotency-Key header is required/i,
    );
  });

  /**
   * Hard Idempotency Guarantee:
   * Calling a command twice with the same key produces the EXACT same response
   * and creates ONLY ONE ledger row (zero duplicate XP / side effects).
   */
  it('replayed idempotency key produces exact same response and exactly 1 ledger transaction', async () => {
    const userId = 'user-replay-test';
    const idempotencyKey = 'cmd-quest-complete-987';
    await characterRepository.createCharacter({ userId });

    // 1. First execution (online or first sync attempt)
    const firstResponse = await syncService.executeTestCommand(userId, idempotencyKey, 150);
    expect(firstResponse.success).toBe(true);
    expect(firstResponse.xpAwarded).toBe(150);
    expect(firstResponse.totalXp).toBe(150);

    // Assert 1 transaction in ledger
    const history1 = await characterService.getTransactionHistory(userId);
    expect(history1.xpTransactions.length).toBe(1);

    // 2. Replay with identical idempotency key (simulating network retry / offline reconnect)
    const secondResponse = await syncService.executeTestCommand(userId, idempotencyKey, 150);
    expect(secondResponse).toEqual(firstResponse);

    // Assert STILL only 1 transaction in ledger (NO duplicate reward!)
    const history2 = await characterService.getTransactionHistory(userId);
    expect(history2.xpTransactions.length).toBe(1);

    // Total XP remains 150 (NOT 300!)
    const char = await characterService.getCharacter(userId);
    expect(char.totalXp).toBe(150);
  });
});
