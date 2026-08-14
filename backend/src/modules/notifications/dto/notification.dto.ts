export interface NotificationResponse {
  id: string;
  userId: string;
  title: string;
  message: string;
  type: string;
  read: boolean;
  data: Record<string, unknown> | null;
  createdAt: Date;
}

export interface CreateNotificationDto {
  userId: string;
  title: string;
  message: string;
  type?: string;
  data?: Record<string, unknown>;
  sendPush?: boolean;
}

export interface NotificationFilterDto {
  unreadOnly?: boolean;
  type?: string;
  limit?: number;
  offset?: number;
}
