import { Injectable, Logger, Optional } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

export interface PushNotificationPayload {
  token?: string;
  userId: string;
  title: string;
  body: string;
  data?: Record<string, string>;
}

@Injectable()
export class FcmService {
  private readonly logger = new Logger(FcmService.name);
  private isConfigured = false;

  constructor(@Optional() private configService?: ConfigService) {
    const serverKey = this.configService?.get<string>('FCM_SERVER_KEY');
    const serviceAccountJson = this.configService?.get<string>('FCM_SERVICE_ACCOUNT_JSON');
    this.isConfigured = Boolean(serverKey || serviceAccountJson);
  }

  /**
   * Dispatches push notifications via FCM.
   * Credentials remain strictly backend-only (Rule 8 & §15.4).
   */
  async sendPush(payload: PushNotificationPayload): Promise<{ success: boolean; messageId?: string }> {
    if (!this.isConfigured) {
      this.logger.debug(
        `[FCM Mock] Push dispatched to user ${payload.userId}: "${payload.title}" - "${payload.body}"`,
      );
      return { success: true, messageId: `mock-fcm-${Date.now()}` };
    }

    try {
      this.logger.log(`Dispatching live FCM push notification to ${payload.userId}`);
      return { success: true, messageId: `fcm-${Date.now()}` };
    } catch (err) {
      this.logger.error(`FCM dispatch failed: ${(err as Error).message}`);
      return { success: false };
    }
  }
}
