import { Injectable, Optional } from '@nestjs/common';
import { PrismaService } from '../../../db/prisma/prisma.service';
import { memoryDb, StoredRefreshToken } from '../../../db/memory/memory-db';

export interface CreateUserData {
  email: string;
  passwordHash: string;
  difficultyMode: string;
  chronotype: string;
}

@Injectable()
export class AuthRepository {
  constructor(@Optional() private prisma?: PrismaService) {}

  private isDbAvailable(): boolean {
    return Boolean(this.prisma && process.env.DATABASE_URL && process.env.NODE_ENV !== 'test');
  }

  async findUserByEmail(email: string) {
    if (this.isDbAvailable()) {
      return this.prisma!.user.findUnique({
        where: { email: email.toLowerCase() },
        include: { character: true },
      });
    }

    const user = Array.from(memoryDb.users.values()).find(
      (u) => u.email.toLowerCase() === email.toLowerCase() && !u.deletedAt,
    );
    if (!user) return null;
    const character = Array.from(memoryDb.characters.values()).find((c) => c.userId === user.id);
    return { ...user, character };
  }

  async findUserById(id: string) {
    if (this.isDbAvailable()) {
      return this.prisma!.user.findUnique({
        where: { id },
        include: { character: true },
      });
    }

    const user = memoryDb.users.get(id);
    if (!user || user.deletedAt) return null;
    const character = Array.from(memoryDb.characters.values()).find((c) => c.userId === user.id);
    return { ...user, character };
  }

  async createUserWithInitialState(data: CreateUserData) {
    const userId = crypto.randomUUID();
    const characterId = crypto.randomUUID();
    const settingsId = crypto.randomUUID();
    const circadianId = crypto.randomUUID();
    const now = new Date();

    if (this.isDbAvailable()) {
      return this.prisma!.$transaction(async (tx) => {
        const user = await tx.user.create({
          data: {
            id: userId,
            email: data.email.toLowerCase(),
            passwordHash: data.passwordHash,
            difficultyMode: data.difficultyMode,
          },
        });

        const character = await tx.character.create({
          data: {
            id: characterId,
            userId: user.id,
            level: 1,
            totalXp: 0,
            currentMana: 100,
            maxMana: 100,
            rank: 'E',
            stats: {
              intelligence: 10,
              discipline: 10,
              fitness: 10,
              creativity: 10,
              coding: 10,
              business: 10,
              health: 10,
            },
          },
        });

        await tx.settings.create({
          data: {
            id: settingsId,
            userId: user.id,
          },
        });

        await tx.circadianProfile.create({
          data: {
            id: circadianId,
            userId: user.id,
            profileType: data.chronotype,
          },
        });

        return { ...user, character };
      });
    }

    const user = {
      id: userId,
      email: data.email.toLowerCase(),
      passwordHash: data.passwordHash,
      difficultyMode: data.difficultyMode,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    };
    const character = {
      id: characterId,
      userId: user.id,
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
      updatedAt: now,
    };
    const settings = {
      id: settingsId,
      userId: user.id,
      theme: 'system_dark',
      soundEnabled: true,
      hapticsEnabled: true,
      createdAt: now,
      updatedAt: now,
    };
    const circadian = {
      id: circadianId,
      userId: user.id,
      profileType: data.chronotype,
      createdAt: now,
      updatedAt: now,
    };

    memoryDb.users.set(user.id, user);
    memoryDb.characters.set(character.id, character);
    memoryDb.settings.set(user.id, settings);
    memoryDb.circadianProfiles.set(user.id, circadian);

    return { ...user, character };
  }

  async saveRefreshToken(userId: string, tokenHash: string, expiresAt: Date) {
    if (this.isDbAvailable()) {
      return this.prisma!.refreshToken.create({
        data: {
          userId,
          tokenHash,
          expiresAt,
        },
      });
    }

    const record: StoredRefreshToken = {
      id: crypto.randomUUID(),
      userId,
      tokenHash,
      revokedAt: null,
      expiresAt,
      createdAt: new Date(),
    };
    memoryDb.refreshTokens.set(tokenHash, record);
    return record;
  }

  async findRefreshToken(tokenHash: string): Promise<StoredRefreshToken | null> {
    if (this.isDbAvailable()) {
      return this.prisma!.refreshToken.findUnique({
        where: { tokenHash },
      });
    }

    return memoryDb.refreshTokens.get(tokenHash) || null;
  }

  async revokeRefreshToken(tokenHash: string) {
    const now = new Date();
    if (this.isDbAvailable()) {
      return this.prisma!.refreshToken.update({
        where: { tokenHash },
        data: { revokedAt: now },
      });
    }

    const record = memoryDb.refreshTokens.get(tokenHash);
    if (record) {
      record.revokedAt = now;
    }
    return record;
  }

  async revokeAllUserRefreshTokens(userId: string) {
    const now = new Date();
    if (this.isDbAvailable()) {
      return this.prisma!.refreshToken.updateMany({
        where: { userId, revokedAt: null },
        data: { revokedAt: now },
      });
    }

    let count = 0;
    for (const token of memoryDb.refreshTokens.values()) {
      if (token.userId === userId) {
        token.revokedAt = now;
        count++;
      }
    }
    return { count };
  }

  async softDeleteUser(userId: string) {
    const now = new Date();
    if (this.isDbAvailable()) {
      await this.prisma!.user.update({
        where: { id: userId },
        data: { deletedAt: now },
      });
      await this.revokeAllUserRefreshTokens(userId);
      return;
    }

    const user = memoryDb.users.get(userId);
    if (user) {
      user.deletedAt = now;
      await this.revokeAllUserRefreshTokens(userId);
    }
  }

  async updateUserPassword(userId: string, passwordHash: string) {
    if (this.isDbAvailable()) {
      return this.prisma!.user.update({
        where: { id: userId },
        data: { passwordHash },
      });
    }

    const user = memoryDb.users.get(userId);
    if (user) {
      user.passwordHash = passwordHash;
      user.updatedAt = new Date();
    }
    return user;
  }

  clearMemoryStore() {
    memoryDb.clear();
  }
}
