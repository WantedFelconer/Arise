import { Injectable } from '@nestjs/common';
import musicCatalog from '../../../config/music_catalog.json';
import { AudioTrackResponse, MusicCatalogResponse } from '../dto/music.dto';

@Injectable()
export class MusicService {
  private tracks: AudioTrackResponse[] = musicCatalog as AudioTrackResponse[];

  async getCatalog(): Promise<MusicCatalogResponse> {
    const categories = Array.from(new Set(this.tracks.map((t) => t.category)));
    return {
      categories,
      totalTracks: this.tracks.length,
      tracks: this.tracks,
    };
  }

  async getTracks(category?: string): Promise<AudioTrackResponse[]> {
    if (category) {
      return this.tracks.filter((t) => t.category.toLowerCase() === category.toLowerCase());
    }
    return this.tracks;
  }

  async getTrackById(id: string): Promise<AudioTrackResponse | null> {
    return this.tracks.find((t) => t.id === id) || null;
  }
}
