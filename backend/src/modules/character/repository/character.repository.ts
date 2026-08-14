import { Injectable, Optional } from '@nestjs/common';
import { PrismaService } from '../../../db/prisma/prisma.service';
import { CharacterStats, DEFAULT_STATS } from '../../../core/rpg-engine';
import { memoryDb, StoredXpTransaction, StoredManaTransaction } from '../../../db/memory/memory-db';
import { Prisma } from '@prisma/client';

@Injectable()
export class CharacterRepository {
  constructor(@Optional() private prisma?: PrismaService) {}

  private isDbAvailable(): boolean {
    return Boolean(this.prisma && process.env.DATABASE_URL && process.env.NODE_ENV !== 'test');
  }

  async findByUserId(userId: string) {
    if (this.isDbAvailable()) {
      return this.prisma!.character.findUnique({
        where: { userId },
      });
    }

    const char = Array.from(memoryDb.characters.values()).find((c) => c.userId === userId);
    return char || null;
  }

  async findById(id: string) {
    if (this.isDbAvailable()) {
      return this.prisma!.character.findUnique({
        where: { id },
      });
    }

    const char =
      memoryDb.characters.get(id) ||
      Array.from(memoryDb.characters.values()).find((c) => c.id === id);
    return char || null;
  }

  async createCharacter(data: { userId: string; id?: string }) {
    const id = data.id || crypto.randomUUID();
    const now = new Date();
    const character = {
      id,
      userId: data.userId,
      level: 1,
      totalXp: 0,
      currentMana: 100,
      maxMana: 100,
      coins: 0,
      gems: 0,
      rank: 'E',
      activeTitleId: null,
      stats: { ...DEFAULT_STATS },
      updatedAt: now,
    };

    if (this.isDbAvailable()) {
      return this.prisma!.character.create({
        data: {
          id: character.id,
          userId: character.userId,
          level: character.level,
          totalXp: character.totalXp,
          currentMana: character.currentMana,
          maxMana: character.maxMana,
          coins: character.coins,
          gems: character.gems,
          rank: character.rank,
          stats: character.stats as unknown as Prisma.InputJsonValue,
        },
      });
    }

    memoryDb.characters.set(id, character);
    return character;
  }

  /**
   * FR-XP-001 & §17.3 Rule 1:
   * Writes to xp_transactions ledger table FIRST, then updates character total_xp cache.
   */
  async appendXpTransactionAndSyncCache(
    characterId: string,
    txData: {
      amount: number;
      sourceType: string;
      sourceId?: string;
      statKey?: string;
      reason?: string;
    },
    cacheUpdate: {
      totalXp: number;
      level: number;
      rank: string;
      stats: CharacterStats;
    },
  ) {
    const txId = crypto.randomUUID();
    const now = new Date();

    if (this.isDbAvailable()) {
      return this.prisma!.$transaction(async (tx) => {
        const ledgerRow = await tx.xpTransaction.create({
          data: {
            id: txId,
            characterId,
            amount: txData.amount,
            sourceType: txData.sourceType,
            sourceId: txData.sourceId,
            statKey: txData.statKey,
            reason: txData.reason,
          },
        });

        const updatedChar = await tx.character.update({
          where: { id: characterId },
          data: {
            totalXp: cacheUpdate.totalXp,
            level: cacheUpdate.level,
            rank: cacheUpdate.rank,
            stats: cacheUpdate.stats as unknown as Prisma.InputJsonValue,
          },
        });

        return { ledgerRow, character: updatedChar };
      });
    }

    const ledgerRow: StoredXpTransaction = {
      id: txId,
      characterId,
      amount: txData.amount,
      sourceType: txData.sourceType,
      sourceId: txData.sourceId || null,
      statKey: txData.statKey || null,
      reason: txData.reason || null,
      createdAt: now,
    };
    memoryDb.xpTransactions.push(ledgerRow);

    const char =
      memoryDb.characters.get(characterId) ||
      Array.from(memoryDb.characters.values()).find(
        (c) => c.id === characterId || c.userId === characterId,
      );
    if (char) {
      char.totalXp = cacheUpdate.totalXp;
      char.level = cacheUpdate.level;
      char.rank = cacheUpdate.rank;
      char.stats = { ...cacheUpdate.stats };
      char.updatedAt = now;
    }

    return { ledgerRow, character: char };
  }

  /**
   * FR-MANA-001 & §17.3 Rule 1:
   * Writes to mana_transactions ledger table FIRST, then updates character current_mana cache.
   */
  async appendManaTransactionAndSyncCache(
    characterId: string,
    txData: {
      delta: number;
      sourceType: string;
      sourceId?: string;
      reason?: string;
    },
    newMana: number,
  ) {
    const txId = crypto.randomUUID();
    const now = new Date();

    if (this.isDbAvailable()) {
      return this.prisma!.$transaction(async (tx) => {
        const ledgerRow = await tx.manaTransaction.create({
          data: {
            id: txId,
            characterId,
            delta: txData.delta,
            sourceType: txData.sourceType,
            sourceId: txData.sourceId,
            reason: txData.reason,
          },
        });

        const updatedChar = await tx.character.update({
          where: { id: characterId },
          data: {
            currentMana: newMana,
          },
        });

        return { ledgerRow, character: updatedChar };
      });
    }

    const ledgerRow: StoredManaTransaction = {
      id: txId,
      characterId,
      delta: txData.delta,
      sourceType: txData.sourceType,
      sourceId: txData.sourceId || null,
      reason: txData.reason || null,
      createdAt: now,
    };
    memoryDb.manaTransactions.push(ledgerRow);

    const char =
      memoryDb.characters.get(characterId) ||
      Array.from(memoryDb.characters.values()).find(
        (c) => c.id === characterId || c.userId === characterId,
      );
    if (char) {
      char.currentMana = newMana;
      char.updatedAt = now;
    }

    return { ledgerRow, character: char };
  }

  async getXpTransactions(characterId: string, limit = 50) {
    if (this.isDbAvailable()) {
      return this.prisma!.xpTransaction.findMany({
        where: { characterId },
        orderBy: { createdAt: 'desc' },
        take: limit,
      });
    }

    return memoryDb.xpTransactions
      .filter((t) => t.characterId === characterId)
      .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime())
      .slice(0, limit);
  }

  async getManaTransactions(characterId: string, limit = 50) {
    if (this.isDbAvailable()) {
      return this.prisma!.manaTransaction.findMany({
        where: { characterId },
        orderBy: { createdAt: 'desc' },
        take: limit,
      });
    }

    return memoryDb.manaTransactions
      .filter((t) => t.characterId === characterId)
      .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime())
      .slice(0, limit);
  }

  async updateActiveTitle(characterId: string, activeTitleId: string | null) {
    if (this.isDbAvailable()) {
      return this.prisma!.character.update({
        where: { id: characterId },
        data: { activeTitleId },
      });
    }

    const char =
      memoryDb.characters.get(characterId) ||
      Array.from(memoryDb.characters.values()).find((c) => c.id === characterId);
    if (char) {
      char.activeTitleId = activeTitleId;
      char.updatedAt = new Date();
    }
    return char;
  }

  clearMemoryStore() {
    memoryDb.clear();
  }
}
