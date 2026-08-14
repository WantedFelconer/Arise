import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  HttpCode,
  HttpStatus,
  Inject,
} from '@nestjs/common';
import { CurrentUser } from '../../../core/decorators/current-user.decorator';
import { ZodValidationPipe } from '../../../core/pipes/zod-validation.pipe';
import { ReminderService } from '../service/reminder.service';
import {
  createReminderSchema,
  updateReminderSchema,
  snoozeReminderSchema,
} from '../validation/reminder.schema';
import {
  CreateReminderDto,
  UpdateReminderDto,
  SnoozeReminderDto,
} from '../dto/reminder.dto';

@Controller('reminders')
export class ReminderController {
  constructor(@Inject(ReminderService) private readonly reminderService: ReminderService) {}

  @Get()
  async listReminders(
    @CurrentUser('userId') userId: string,
    @Query('activeOnly') activeOnly?: string,
  ) {
    const data = await this.reminderService.listReminders(userId, activeOnly === 'true');
    return { data };
  }

  @Post()
  async createReminder(
    @CurrentUser('userId') userId: string,
    @Body(new ZodValidationPipe(createReminderSchema)) dto: CreateReminderDto,
  ) {
    const data = await this.reminderService.createReminder(userId, dto);
    return { data };
  }

  @Get(':id')
  async getReminder(
    @CurrentUser('userId') userId: string,
    @Param('id') id: string,
  ) {
    const data = await this.reminderService.getReminder(userId, id);
    return { data };
  }

  @Patch(':id')
  async updateReminder(
    @CurrentUser('userId') userId: string,
    @Param('id') id: string,
    @Body(new ZodValidationPipe(updateReminderSchema)) dto: UpdateReminderDto,
  ) {
    const data = await this.reminderService.updateReminder(userId, id, dto);
    return { data };
  }

  @Post(':id/snooze')
  @HttpCode(HttpStatus.OK)
  async snoozeReminder(
    @CurrentUser('userId') userId: string,
    @Param('id') id: string,
    @Body(new ZodValidationPipe(snoozeReminderSchema)) dto: SnoozeReminderDto,
  ) {
    const data = await this.reminderService.snoozeReminder(userId, id, dto);
    return { data };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async deleteReminder(
    @CurrentUser('userId') userId: string,
    @Param('id') id: string,
  ) {
    await this.reminderService.deleteReminder(userId, id);
  }
}
