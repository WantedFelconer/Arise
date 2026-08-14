import { describe, it, expect, beforeEach } from 'vitest';
import { AdminService } from '../service/admin.service';
import { memoryDb } from '../../../db/memory/memory-db';

describe('AdminService (FR-ADMIN-002)', () => {
  let service: AdminService;

  beforeEach(() => {
    memoryDb.clear();
    service = new AdminService();
  });

  it('exposes balancing config tables without requiring code redeployments', () => {
    const config = service.getBalancingConfig();

    expect(config.rankThresholds).toBeDefined();
    expect(config.bossDamageTable).toBeDefined();
    expect(config.gateRewards).toBeDefined();
    expect(config.screenTimeModifiers).toBeDefined();
    expect(config.fitnessThresholds).toBeDefined();
    expect(config.difficultyModes).toBeDefined();
  });

  it('reads active feature flags', () => {
    memoryDb.featureFlags.set('flag-1', {
      id: 'flag-1',
      userId: null,
      flagKey: 'screen_time_enabled',
      enabled: true,
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    const flags = service.getFeatureFlags();
    expect(flags.length).toBe(1);
    expect(flags[0].flagKey).toBe('screen_time_enabled');
  });
});
