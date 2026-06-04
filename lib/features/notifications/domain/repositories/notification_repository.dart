import 'package:digv/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<NotificationDataEntity> getNotifications({int page = 1, int limit = 100});
  Future<int> getUnreadCount();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
}
