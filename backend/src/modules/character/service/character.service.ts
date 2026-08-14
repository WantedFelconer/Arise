import { Injectable, NotFoundException, BadRequestException, Inject } from '@nestjs/common';
import { CharacterRepository } from '../repository/character.repository';
import { RpgEngine, CharacterStats, DEFAULT_STATS } from '../../../core/rpg-engine';
import {
  CharacterResponse,
  AwardXpInput,
  ModifyManaInput,
  XpAggregationSummary,
} from '../dto/character.dto';

@Injectable()
export class CharacterService {
  constructor(@Inject(CharacterRepository) private characterRepository: CharacterRepository) {}

  async getCharacter(userId: string): Promise<CharacterResponse> {
    const character = await this.characterRepository.findByUserId(userId);
    if (!character) {
      throw new NotFoundException({
        code: 'CHARACTER_NOT_FOUND',
        message: 'No character found for this user',
      });
    }

    const nextLevel = character.level + 1;
    const xpForNext = RpgEngine.xpForLevel(nextLevel);
    const xpToNextLevel = Math.max(0, xpForNext - character.totalXp);

    return {
      id: character.id,
      userId: character.userId,
      level: character.level,
      totalXp: character.totalXp,
      xpToNextLevel,
      currentMana: character.currentMana,
      maxMana: character.maxMana,
      coins: character.coins,
      gems: character.gems,
      rank: character.rank,
      activeTitleId: character.activeTitleId,
      stats: (character.stats as CharacterStats) || { ...DEFAULT_STATS },
    };
  }

  async getStats(userId: string) {
    const character = await this.getCharacter(userId);
    return {
      characterId: character.id,
      level: character.level,
      rank: character.rank,
      totalXp: character.totalXp,
      stats: character.stats,
    };
  }

  /**
   * Authoritative XP award method (FR-XP-001, FR-CHAR-001..003, §17.3 Rule 1)
   * Appends to xp_transactions BEFORE updating character cache.
   */
  async awardXp(userId: string, input: AwardXpInput) {
    if (input.amount <= 0) {
      throw new BadRequestException({
        code: 'INVALID_XP_AMOUNT',
        message: 'XP award amount must be greater than zero',
      });
    }

    const char = await this.characterRepository.findByUserId(userId);
    if (!char) {
      throw new NotFoundException({
        code: 'CHARACTER_NOT_FOUND',
        message: 'No character found for this user',
      });
    }

    const newTotalXp = char.totalXp + input.amount;
    const newLevel = RpgEngine.calculateLevel(newTotalXp);
    const newRank = RpgEngine.calculateRank(newLevel);

    const stats: CharacterStats = {
      ...((char.stats as CharacterStats) || DEFAULT_STATS),
    };

    if (input.statKey && input.statKey in stats) {
      const statGain = Math.max(1, Math.floor(input.amount / 50));
      stats[input.statKey] = (stats[input.statKey] || 10) + statGain;
    }

    const result = await this.characterRepository.appendXpTransactionAndSyncCache(
      char.id,
      {
        amount: input.amount,
        sourceType: input.sourceType,
        sourceId: input.sourceId,
        statKey: input.statKey,
        reason: input.reason,
      },
      {
        totalXp: newTotalXp,
        level: newLevel,
        rank: newRank,
        stats,
      },
    );

    return {
      character: result.character!,
      xpAwarded: input.amount,
      levelGained: newLevel > char.level,
      previousLevel: char.level,
      newLevel,
      newRank,
    };
  }

  /**
   * Authoritative Mana modification method (FR-MANA-001, §17.3 Rule 1)
   * Appends to mana_transactions BEFORE updating character cache.
   */
  async modifyMana(userId: string, input: ModifyManaInput) {
    const char = await this.characterRepository.findByUserId(userId);
    if (!char) {
      throw new NotFoundException({
        code: 'CHARACTER_NOT_FOUND',
        message: 'No character found for this user',
      });
    }

    const newMana = RpgEngine.clampMana(char.currentMana + input.delta, char.maxMana);

    const result = await this.characterRepository.appendManaTransactionAndSyncCache(
      char.id,
      {
        delta: input.delta,
        sourceType: input.sourceType,
        sourceId: input.sourceId,
        reason: input.reason,
      },
      newMana,
    );

    return {
      character: result.character!,
      manaDelta: input.delta,
      currentMana: newMana,
    };
  }

  /**
   * Authoritative XP penalty method (FR-GATE-005, §17.3 Rule 1, §19 AC-GATE-005)
   * Appends negative entry to xp_transactions BEFORE updating character cache.
   */
  async applyXpPenalty(
    userId: string,
    input: {
      amount: number;
      sourceType?: string;
      sourceId?: string;
      reason?: string;
    },
  ) {
    const penaltyAmount = Math.abs(input.amount);
    const char = await this.characterRepository.findByUserId(userId);
    if (!char) {
      throw new NotFoundException({
        code: 'CHARACTER_NOT_FOUND',
        message: 'No character found for this user',
      });
    }

    const newTotalXp = Math.max(0, char.totalXp - penaltyAmount);
    const newLevel = RpgEngine.calculateLevel(newTotalXp);
    const newRank = RpgEngine.calculateRank(newLevel);

    const stats: CharacterStats = {
      ...((char.stats as CharacterStats) || DEFAULT_STATS),
    };

    const result = await this.characterRepository.appendXpTransactionAndSyncCache(
      char.id,
      {
        amount: -penaltyAmount,
        sourceType: input.sourceType || 'penalty',
        sourceId: input.sourceId,
        reason: input.reason,
      },
      {
        totalXp: newTotalXp,
        level: newLevel,
        rank: newRank,
        stats,
      },
    );

    return {
      character: result.character!,
      xpPenalty: penaltyAmount,
      newTotalXp,
      newLevel,
      newRank,
    };
  }

  async equipTitle(userId: string, titleId: string | null) {
    const char = await this.characterRepository.findByUserId(userId);
    if (!char) {
      throw new NotFoundException({
        code: 'CHARACTER_NOT_FOUND',
        message: 'No character found for this user',
      });
    }

    return this.characterRepository.updateActiveTitle(char.id, titleId);
  }

  async getXpAggregates(userId: string): Promise<XpAggregationSummary> {
    const char = await this.characterRepository.findByUserId(userId);
    if (!char) {
      return { today: 0, thisWeek: 0, thisMonth: 0, lifetime: 0 };
    }

    const txs = await this.characterRepository.getXpTransactions(char.id, 1000);
    const now = new Date();
    const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const startOfWeek = new Date(
      startOfToday.getTime() - startOfToday.getDay() * 24 * 60 * 60 * 1000,
    );
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    let today = 0;
    let thisWeek = 0;
    let thisMonth = 0;
    let lifetime = 0;

    for (const tx of txs) {
      lifetime += tx.amount;
      const txTime = new Date(tx.createdAt).getTime();
      if (txTime >= startOfToday.getTime()) today += tx.amount;
      if (txTime >= startOfWeek.getTime()) thisWeek += tx.amount;
      if (txTime >= startOfMonth.getTime()) thisMonth += tx.amount;
    }

    return { today, thisWeek, thisMonth, lifetime };
  }

  async getTransactionHistory(userId: string) {
    const char = await this.characterRepository.findByUserId(userId);
    if (!char) {
      throw new NotFoundException({
        code: 'CHARACTER_NOT_FOUND',
        message: 'No character found for this user',
      });
    }

    const [xpTransactions, manaTransactions] = await Promise.all([
      this.characterRepository.getXpTransactions(char.id, 50),
      this.characterRepository.getManaTransactions(char.id, 50),
    ]);

    return {
      xpTransactions,
      manaTransactions,
    };
  }
}
