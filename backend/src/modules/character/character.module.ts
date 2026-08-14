import { Module } from '@nestjs/common';
import { CharacterController } from './controller/character.controller';
import { CharacterService } from './service/character.service';
import { CharacterRepository } from './repository/character.repository';

@Module({
  controllers: [CharacterController],
  providers: [CharacterService, CharacterRepository],
  exports: [CharacterService, CharacterRepository],
})
export class CharacterModule {}
