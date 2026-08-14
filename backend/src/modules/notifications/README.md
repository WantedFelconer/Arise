# Notifications Module (`modules/notifications`)

## Purpose
Manages user-facing in-app notification center, read/unread states, and push dispatch integration via Firebase Cloud Messaging (FCM) per §6.21 (FR-NOTIF-001, FR-NOTIF-002).

## Public API
- `NotificationService.sendNotification(dto)`: Creates in-app notification and optionally dispatches FCM push.
- `NotificationService.listNotifications(userId, filter)`: Lists paged notifications with unread counts.
- `NotificationService.getUnreadCount(userId)`: Fast unread badge query.
- `NotificationService.markAsRead(userId, id)`: Marks single notification as read.
- `NotificationService.markAllAsRead(userId)`: Bulk marks all unread notifications.
- `NotificationService.deleteNotification(userId, id)`: Deletes a notification.

## Endpoints
- `GET /api/v1/notifications`: List notifications.
- `GET /api/v1/notifications/unread-count`: Unread counter.
- `PATCH /api/v1/notifications/:id/read`: Mark read.
- `POST /api/v1/notifications/read-all`: Mark all read.
- `DELETE /api/v1/notifications/:id`: Delete notification.

## Security & Secrets
- Push dispatch uses backend credentials (`FCM_SERVER_KEY` / `FCM_SERVICE_ACCOUNT_JSON`), never exposing keys to clients (§15.4, Rule 8).
