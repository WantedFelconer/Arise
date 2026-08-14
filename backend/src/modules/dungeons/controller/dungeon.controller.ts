import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Param,
  Body,
  UsePipes,
  Inject,
} from '@nestjs/common';
import { DungeonService } from '../service/dungeon.service';
import { CurrentUser } from '../../../core/decorators/current-user.decorator';
import { ZodValidationPipe } from '../../../core/pipes/zod-validation.pipe';
import {
  createDungeonSchema,
  updateDungeonSchema,
  CreateDungeonInput,
  UpdateDungeonInput,
} from '../validation/dungeon.schema';

@Controller('dungeons')
export class DungeonController {
  constructor(@Inject(DungeonService) private dungeonService: DungeonService) {}

  @Get()
  async list(@CurrentUser('userId') userId: string) {
    const data = await this.dungeonService.listDungeons(userId);
    return { data };
  }

  @Get(':id')
  async get(@CurrentUser('userId') userId: string, @Param('id') id: string) {
    const data = await this.dungeonService.getDungeon(userId, id);
    return { data };
  }

  @Post()
  @UsePipes(new ZodValidationPipe(createDungeonSchema))
  async create(@CurrentUser('userId') userId: string, @Body() body: CreateDungeonInput) {
    const data = await this.dungeonService.createDungeon(userId, body);
    return { data };
  }

  @Patch(':id')
  @UsePipes(new ZodValidationPipe(updateDungeonSchema))
  async update(
    @CurrentUser('userId') userId: string,
    @Param('id') id: string,
    @Body() body: UpdateDungeonInput,
  ) {
    const data = await this.dungeonService.updateDungeon(userId, id, body);
    return { data };
  }

  @Delete(':id')
  async delete(@CurrentUser('userId') userId: string, @Param('id') id: string) {
    const data = await this.dungeonService.deleteDungeon(userId, id);
    return { data };
  }
}
