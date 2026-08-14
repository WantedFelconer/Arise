import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Param,
  Query,
  HttpCode,
  HttpStatus,
  Inject,
} from '@nestjs/common';
import { CurrentUser } from '../../../core/decorators/current-user.decorator';
import { ZodValidationPipe } from '../../../core/pipes/zod-validation.pipe';
import { NotificationService } from '../service/notification.service';
import {
  notificationFilterSchema,
} from '../validation/notification.schema';
import {
  NotificationFilterDto,
} from '../dto/notification.dto';

@Controller('notifications')
export class NotificationController {
  constructor(@Inject(NotificationService) private readonly notificationService: NotificationService) {}

  @Get()
  async listNotifications(
    @CurrentUser('userId') userId: string,
    @Query(new ZodValidationPipe(notificationFilterSchema)) filter: NotificationFilterDto,
  ) {
    const result = await this.notificationService.listNotifications(userId, filter);
    return { data: result };
  }

  @Get('unread-count')
  async getUnreadCount(@CurrentUser('userId') userId: string) {
    const result = await this.notificationService.getUnreadCount(userId);
    return { data: result };
  }

  @Patch(':id/read')
  async markAsRead(
    @CurrentUser('userId') userId: string,
    @Param('id') id: string,
  ) {
    const result = await this.notificationService.markAsRead(userId, id);
    return { data: result };
  }

  @Post('read-all')
  @HttpCode(HttpStatus.OK)
  async markAllAsRead(@CurrentUser('userId') userId: string) {
    const result = await this.notificationService.markAllAsRead(userId);
    return { data: result };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async deleteNotification(
    @CurrentUser('userId') userId: string,
    @Param('id') id: string,
  ) {
    await this.notificationService.deleteNotification(userId, id);
  }
}
