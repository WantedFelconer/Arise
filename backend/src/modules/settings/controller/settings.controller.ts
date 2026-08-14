import {
  Controller,
  Get,
  Patch,
  Put,
  Post,
  Body,
  HttpCode,
  HttpStatus,
  Inject,
} from '@nestjs/common';
import { CurrentUser } from '../../../core/decorators/current-user.decorator';
import { ZodValidationPipe } from '../../../core/pipes/zod-validation.pipe';
import { SettingsService } from '../service/settings.service';
import {
  setDifficultyModeSchema,
  updateSettingsSchema,
} from '../validation/settings.schema';
import {
  SetDifficultyModeDto,
  UpdateSettingsDto,
} from '../dto/settings.dto';

@Controller('settings')
export class SettingsController {
  constructor(@Inject(SettingsService) private readonly settingsService: SettingsService) {}

  @Get()
  async getSettings(@CurrentUser('userId') userId: string) {
    const data = await this.settingsService.getSettings(userId);
    return { data };
  }

  @Patch()
  async updateSettings(
    @CurrentUser('userId') userId: string,
    @Body(new ZodValidationPipe(updateSettingsSchema)) dto: UpdateSettingsDto,
  ) {
    const data = await this.settingsService.updateSettings(userId, dto);
    return { data };
  }

  @Get('difficulty-mode')
  async getDifficultyMode(@CurrentUser('userId') userId: string) {
    const data = await this.settingsService.getDifficultyMode(userId);
    return { data };
  }

  @Put('difficulty-mode')
  async setDifficultyMode(
    @CurrentUser('userId') userId: string,
    @Body(new ZodValidationPipe(setDifficultyModeSchema)) dto: SetDifficultyModeDto,
  ) {
    const data = await this.settingsService.setDifficultyMode(userId, dto);
    return { data };
  }

  @Get('export')
  async exportData(@CurrentUser('userId') userId: string) {
    const data = await this.settingsService.exportUserData(userId);
    return { data };
  }

  @Post('account/delete')
  @HttpCode(HttpStatus.OK)
  async requestAccountDeletion(@CurrentUser('userId') userId: string) {
    const data = await this.settingsService.requestAccountDeletion(userId);
    return { data };
  }

  @Post('account/cancel-deletion')
  @HttpCode(HttpStatus.OK)
  async cancelAccountDeletion(@CurrentUser('userId') userId: string) {
    const data = await this.settingsService.cancelAccountDeletion(userId);
    return { data };
  }
}
