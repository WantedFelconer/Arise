import {
  Controller,
  Get,
  Post,
  Patch,
  Param,
  Body,
  Query,
  UsePipes,
  Inject,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { BossService } from '../service/boss.service';
import { CurrentUser } from '../../../core/decorators/current-user.decorator';
import { ZodValidationPipe } from '../../../core/pipes/zod-validation.pipe';
import {
  createBossSchema,
  updateBossSchema,
  CreateBossInput,
  UpdateBossInput,
} from '../validation/boss.schema';

@Controller('bosses')
export class BossController {
  constructor(@Inject(BossService) private bossService: BossService) {}

  @Get()
  async list(
    @CurrentUser('userId') userId: string,
    @Query('status') status?: string,
    @Query('dungeonId') dungeonId?: string,
  ) {
    const data = await this.bossService.listBosses(userId, { status, dungeonId });
    return { data };
  }

  @Get('history')
  async history(@CurrentUser('userId') userId: string) {
    const data = await this.bossService.getBossHistory(userId);
    return { data };
  }

  @Get(':id')
  async get(@CurrentUser('userId') userId: string, @Param('id') id: string) {
    const data = await this.bossService.getBoss(userId, id);
    return { data };
  }

  @Post()
  @UsePipes(new ZodValidationPipe(createBossSchema))
  async create(@CurrentUser('userId') userId: string, @Body() body: CreateBossInput) {
    const data = await this.bossService.createBoss(userId, body);
    return { data };
  }

  @Patch(':id')
  @UsePipes(new ZodValidationPipe(updateBossSchema))
  async update(
    @CurrentUser('userId') userId: string,
    @Param('id') id: string,
    @Body() body: UpdateBossInput,
  ) {
    const data = await this.bossService.updateBoss(userId, id, body);
    return { data };
  }

  @Post(':id/abandon')
  @HttpCode(HttpStatus.OK)
  async abandon(@CurrentUser('userId') userId: string, @Param('id') id: string) {
    const data = await this.bossService.abandonBoss(userId, id);
    return { data };
  }

  @Post(':id/reactivate')
  @HttpCode(HttpStatus.OK)
  async reactivate(@CurrentUser('userId') userId: string, @Param('id') id: string) {
    const data = await this.bossService.reactivateBoss(userId, id);
    return { data };
  }
}
