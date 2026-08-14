import { describe, it, expect } from 'vitest';
import { CalendarService } from '../service/calendar.service';
import { CalendarRepository } from '../repository/calendar.repository';

describe('Calendar Module (Scaffold)', () => {
  const mockRepo: CalendarRepository = {
    findById: async () => ({ id: 'test-id' }),
  };

  it('instantiates service cleanly', async () => {
    const service = new CalendarService(mockRepo);
    const result = await service.getById('test-id');
    expect(result).toEqual({ id: 'test-id' });
  });
});
