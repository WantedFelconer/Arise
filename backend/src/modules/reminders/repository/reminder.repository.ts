import { Injectable } from '@nestjs/common';
import { v4 as uuidv4 } from 'uuid';
import { memoryDb, StoredReminder } from '../../../db/memory/memory-db';
import { CreateReminderDto, UpdateReminderDto } from '../dto/reminder.dto';

@Injectable()
export class ReminderRepository {
  async create(userId: string, dto: CreateReminderDto): Promise<StoredReminder> {
    const now = new Date();
    const reminder: StoredReminder = {
      id: uuidv4(),
      userId,
      type: dto.type,
      message: dto.message,
      triggerConfig: dto.triggerConfig as Record<string, unknown>,
      priority: dto.priority || 'custom',
      active: dto.active ?? true,
      snoozedUntil: null,
      lastTriggeredAt: null,
      createdAt: now,
      updatedAt: now,
    };

    memoryDb.reminders.set(reminder.id, reminder);
    return reminder;
  }

  async findById(id: string, userId: string): Promise<StoredReminder | null> {
    const found = memoryDb.reminders.get(id);
    if (!found || found.userId !== userId) return null;
    return found;
  }

  async findByUser(userId: string, activeOnly = false): Promise<StoredReminder[]> {
    return Array.from(memoryDb.reminders.values()).filter((r) => {
      if (r.userId !== userId) return false;
      if (activeOnly && !r.active) return false;
      return true;
    });
  }

  async findAllActive(): Promise<StoredReminder[]> {
    return Array.from(memoryDb.reminders.values()).filter((r) => r.active);
  }

  async update(id: string, userId: string, dto: UpdateReminderDto): Promise<StoredReminder | null> {
    const found = await this.findById(id, userId);
    if (!found) return null;

    if (dto.type !== undefined) found.type = dto.type;
    if (dto.message !== undefined) found.message = dto.message;
    if (dto.triggerConfig !== undefined) found.triggerConfig = dto.triggerConfig as Record<string, unknown>;
    if (dto.priority !== undefined) found.priority = dto.priority;
    if (dto.active !== undefined) found.active = dto.active;
    found.updatedAt = new Date();

    memoryDb.reminders.set(id, found);
    return found;
  }

  async snooze(id: string, userId: string, snoozedUntil: Date): Promise<StoredReminder | null> {
    const found = await this.findById(id, userId);
    if (!found) return null;

    found.snoozedUntil = snoozedUntil;
    found.updatedAt = new Date();
    memoryDb.reminders.set(id, found);
    return found;
  }

  async recordTriggered(id: string): Promise<void> {
    const found = memoryDb.reminders.get(id);
    if (found) {
      found.lastTriggeredAt = new Date();
      found.snoozedUntil = null;
      found.updatedAt = new Date();
    }
  }

  async delete(id: string, userId: string): Promise<boolean> {
    const found = await this.findById(id, userId);
    if (!found) return false;
    return memoryDb.reminders.delete(id);
  }

  async deleteByUserId(userId: string): Promise<number> {
    let count = 0;
    for (const [id, r] of memoryDb.reminders.entries()) {
      if (r.userId === userId) {
        memoryDb.reminders.delete(id);
        count++;
      }
    }
    return count;
  }
}
