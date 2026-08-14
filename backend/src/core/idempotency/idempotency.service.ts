import { Injectable, Optional } from '@nestjs/common';
import { PrismaService } from '../../db/prisma/prisma.service';
import { memoryDb, StoredIdempotencyRecord } from '../../db/memory/memory-db';
import { Prisma } from '@prisma/client';

export interface CachedResponse<T = unknown> {
  status: number;
  body: T;
  fromCache: boolean;
}

@Injectable()
export class IdempotencyService {
  constructor(@Optional() private prisma?: PrismaService) {}

  private isDbAvailable(): boolean {
    return Boolean(this.prisma && process.env.DATABASE_URL && process.env.NODE_ENV !== 'test');
  }

  private getKey(userId: string, idempotencyKey: string): string {
    return `${userId}:${idempotencyKey}`;
  }

  async getRecord(userId: string, idempotencyKey: string): Promise<StoredIdempotencyRecord | null> {
    if (this.isDbAvailable()) {
      return this.prisma!.idempotencyRecord.findUnique({
        where: {
          userId_idempotencyKey: {
            userId,
            idempotencyKey,
          },
        },
      });
    }

    return memoryDb.idempotencyRecords.get(this.getKey(userId, idempotencyKey)) || null;
  }

  async saveRecord(
    userId: string,
    idempotencyKey: string,
    operationType: string,
    responseStatus: number,
    responseBody: unknown,
  ) {
    if (this.isDbAvailable()) {
      return this.prisma!.idempotencyRecord.create({
        data: {
          userId,
          idempotencyKey,
          operationType,
          responseStatus,
          responseBody: responseBody as Prisma.InputJsonValue,
        },
      });
    }

    const record: StoredIdempotencyRecord = {
      id: crypto.randomUUID(),
      userId,
      idempotencyKey,
      operationType,
      responseStatus,
      responseBody,
      createdAt: new Date(),
    };
    memoryDb.idempotencyRecords.set(this.getKey(userId, idempotencyKey), record);
    return record;
  }

  async executeIdempotent<T>(
    userId: string,
    idempotencyKey: string,
    operationType: string,
    operation: () => Promise<{ status: number; body: T }>,
  ): Promise<CachedResponse<T>> {
    const existing = await this.getRecord(userId, idempotencyKey);
    if (existing) {
      return {
        status: existing.responseStatus,
        body: existing.responseBody as T,
        fromCache: true,
      };
    }

    const result = await operation();

    await this.saveRecord(userId, idempotencyKey, operationType, result.status, result.body);

    return {
      status: result.status,
      body: result.body,
      fromCache: false,
    };
  }

  clearMemoryStore() {
    memoryDb.clear();
  }
}
