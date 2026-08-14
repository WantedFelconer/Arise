import { Controller, Get, Query, Inject } from '@nestjs/common';
import { MusicService } from '../service/music.service';

@Controller('music')
export class MusicController {
  constructor(@Inject(MusicService) private readonly musicService: MusicService) {}

  @Get('catalog')
  async getCatalog() {
    const data = await this.musicService.getCatalog();
    return { data };
  }

  @Get('tracks')
  async getTracks(@Query('category') category?: string) {
    const data = await this.musicService.getTracks(category);
    return { data };
  }
}
