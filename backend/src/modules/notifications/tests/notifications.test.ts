import { describe, it, expect } from 'vitest';
import { NotificationService } from '../service/notifications.service';
import { NotificationRepository } from '../repository/notifications.repository';

describe('Notification Module (Scaffold)', () => {
  const mockRepo: NotificationRepository = {
    findById: async () => ({ id: 'test-id' }),
  };

  it('instantiates service cleanly', async () => {
    const service = new NotificationService(mockRepo);
    const result = await service.getById('test-id');
    expect(result).toEqual({ id: 'test-id' });
  });
});
