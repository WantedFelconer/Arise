import { Module } from '@nestjs/common';
import { FitnessController } from './controller/fitness.controller';
import { FitnessService } from './service/fitness.service';
import { FitnessRepository } from './repository/fitness.repository';
import { CharacterModule } from '../character/character.module';

@Module({
  imports: [CharacterModule],
  controllers: [FitnessController],
  providers: [FitnessService, FitnessRepository],
  exports: [FitnessService, FitnessRepository],
})
export class FitnessModule {}
