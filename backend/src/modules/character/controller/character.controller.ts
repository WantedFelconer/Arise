import {
  Controller,
  Get,
  Patch,
  Body,
  UsePipes,
  HttpCode,
  HttpStatus,
  Inject,
} from '@nestjs/common';
import { CharacterService } from '../service/character.service';
import { CurrentUser } from '../../../core/decorators/current-user.decorator';
import { ZodValidationPipe } from '../../../core/pipes/zod-validation.pipe';
import { equipTitleSchema } from '../validation/character.schema';
import { EquipTitleDto } from '../dto/character.dto';

@Controller('character')
export class CharacterController {
  constructor(@Inject(CharacterService) private characterService: CharacterService) {}

  @Get()
  @HttpCode(HttpStatus.OK)
  async getCharacter(@CurrentUser('userId') userId: string) {
    const data = await this.characterService.getCharacter(userId);
    return { data };
  }

  @Get('stats')
  @HttpCode(HttpStatus.OK)
  async getStats(@CurrentUser('userId') userId: string) {
    const data = await this.characterService.getStats(userId);
    return { data };
  }

  @Get('history')
  @HttpCode(HttpStatus.OK)
  async getHistory(@CurrentUser('userId') userId: string) {
    const data = await this.characterService.getTransactionHistory(userId);
    return { data };
  }

  @Get('aggregates')
  @HttpCode(HttpStatus.OK)
  async getAggregates(@CurrentUser('userId') userId: string) {
    const data = await this.characterService.getXpAggregates(userId);
    return { data };
  }

  @Patch('title')
  @UsePipes(new ZodValidationPipe(equipTitleSchema))
  @HttpCode(HttpStatus.OK)
  async equipTitle(@CurrentUser('userId') userId: string, @Body() dto: EquipTitleDto) {
    const data = await this.characterService.equipTitle(userId, dto.titleId);
    return { data };
  }
}
