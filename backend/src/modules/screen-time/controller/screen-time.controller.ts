import {
  Controller,
  Get,
  Post,
  Put,
  Body,
  Param,
  HttpCode,
  HttpStatus,
  Inject,
} from '@nestjs/common';
import { CurrentUser } from '../../../core/decorators/current-user.decorator';
import { ZodValidationPipe } from '../../../core/pipes/zod-validation.pipe';
import { ScreenTimeService } from '../service/screen-time.service';
import {
  ingestSessionsSchema,
  setAppCategorySchema,
} from '../validation/screen-time.schema';
import { IngestSessionsDto, SetAppCategoryDto } from '../dto/screen-time.dto';

@Controller('screen-time')
export class ScreenTimeController {
  constructor(@Inject(ScreenTimeService) private readonly screenTimeService: ScreenTimeService) {}

  @Post('sessions')
  @HttpCode(HttpStatus.OK)
  async ingestSessions(
    @CurrentUser('userId') userId: string,
    @Body(new ZodValidationPipe(ingestSessionsSchema)) dto: IngestSessionsDto,
  ) {
    const data = await this.screenTimeService.ingestSessions(userId, dto);
    return { data };
  }

  @Get('insights')
  async getInsights(@CurrentUser('userId') userId: string) {
    const data = await this.screenTimeService.getInsights(userId);
    return { data };
  }

  @Get('categories')
  async getCategories(@CurrentUser('userId') userId: string) {
    const data = await this.screenTimeService.getCategoryConfig(userId);
    return { data };
  }

  @Put('categories/:appPackage')
  async setAppCategory(
    @CurrentUser('userId') userId: string,
    @Param('appPackage') appPackage: string,
    @Body(new ZodValidationPipe(setAppCategorySchema)) dto: SetAppCategoryDto,
  ) {
    const data = await this.screenTimeService.setAppCategory(userId, appPackage, dto);
    return data;
  }
}
