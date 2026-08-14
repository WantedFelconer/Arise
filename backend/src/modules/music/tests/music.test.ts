import { describe, it, expect, beforeEach } from 'vitest';
import { MusicService } from '../service/music.service';

describe('MusicService (FR-MUSIC-001)', () => {
  let service: MusicService;

  beforeEach(() => {
    service = new MusicService();
  });

  it('retrieves ambient tracks catalog with category grouping', async () => {
    const catalog = await service.getCatalog();
    expect(catalog.totalTracks).toBeGreaterThan(0);
    expect(catalog.categories).toContain('lofi');
    expect(catalog.categories).toContain('nature');
  });

  it('filters tracks by category', async () => {
    const lofiTracks = await service.getTracks('lofi');
    expect(lofiTracks.length).toBeGreaterThan(0);
    expect(lofiTracks[0].category).toBe('lofi');
  });
});
