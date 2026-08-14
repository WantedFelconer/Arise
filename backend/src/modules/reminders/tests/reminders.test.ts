import { describe, it, expect } from 'vitest';
import { ReminderService } from '../service/reminders.service';
import { ReminderRepository } from '../repository/reminders.repository';

describe('Reminder Module (Scaffold)', () => {
  const mockRepo: ReminderRepository = {
    findById: async () => ({ id: 'test-id' }),
  };

  it('instantiates service cleanly', async () => {
    const service = new ReminderService(mockRepo);
    const result = await service.getById('test-id');
    expect(result).toEqual({ id: 'test-id' });
  });
});
