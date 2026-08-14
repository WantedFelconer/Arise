import { Injectable } from '@nestjs/common';
import { v4 as uuidv4 } from 'uuid';
import { memoryDb, StoredFitnessLog } from '../../../db/memory/memory-db';
import { CreateFitnessLogDto } from '../dto/fitness.dto';

@Injectable()
export class FitnessRepository {
  async create(userId: string, dto: CreateFitnessLogDto): Promise<StoredFitnessLog> {
    const recordedAt = dto.recordedAt ? new Date(dto.recordedAt) : new Date();
    const log: StoredFitnessLog = {
      id: uuidv4(),
      userId,
      logType: dto.logType,
      value: dto.value,
      unit: dto.unit,
      recordedAt,
      metadata: dto.metadata,
      createdAt: new Date(),
    };

    memoryDb.fitnessLogs.push(log);
    return log;
  }

  async findByUser(
    userId: string,
    filter?: { logType?: string; startDate?: Date; endDate?: Date; limit?: number; offset?: number },
  ): Promise<StoredFitnessLog[]> {
    let items = memoryDb.fitnessLogs.filter((f) => f.userId === userId);

    if (filter?.logType) {
      items = items.filter((f) => f.logType === filter.logType);
    }
    if (filter?.startDate) {
      items = items.filter((f) => f.recordedAt >= filter.startDate!);
    }
    if (filter?.endDate) {
      items = items.filter((f) => f.recordedAt <= filter.endDate!);
    }

    items.sort((a, b) => b.recordedAt.getTime() - a.recordedAt.getTime());

    const offset = filter?.offset || 0;
    const limit = filter?.limit || 50;
    return items.slice(offset, offset + limit);
  }

  async deleteByUserId(userId: string): Promise<number> {
    const initLen = memoryDb.fitnessLogs.length;
    memoryDb.fitnessLogs = memoryDb.fitnessLogs.filter((f) => f.userId !== userId);
    return initLen - memoryDb.fitnessLogs.length;
  }
}
