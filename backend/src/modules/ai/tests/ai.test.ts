import { describe, it, expect } from 'vitest';
import { AiPlannerService, AiCoachService, AiQuotaService } from '../service/ai.service';
import { AiPlannerController, AiCoachController } from '../controller/ai.controller';

describe('AI Module Entrypoints & Wiring', () => {
  it('correctly exports AI services and controllers', () => {
    expect(AiPlannerService).toBeDefined();
    expect(AiCoachService).toBeDefined();
    expect(AiQuotaService).toBeDefined();
    expect(AiPlannerController).toBeDefined();
    expect(AiCoachController).toBeDefined();
  });
});
