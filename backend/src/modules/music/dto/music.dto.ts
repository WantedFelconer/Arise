export interface AudioTrackResponse {
  id: string;
  title: string;
  category: string;
  artist: string;
  durationS: number;
  streamUrl: string;
  coverArtUrl?: string;
  tags: string[];
}

export interface MusicCatalogResponse {
  categories: string[];
  totalTracks: number;
  tracks: AudioTrackResponse[];
}
