import { Module } from '@nestjs/common';
import { MusicController } from './controller/music.controller';
import { MusicService } from './service/music.service';

@Module({
  controllers: [MusicController],
  providers: [MusicService],
  exports: [MusicService],
})
export class MusicModule {}
