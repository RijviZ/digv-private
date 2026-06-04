class NotificationEntity {
  final String notificationId;
  final String userId;
  final String type;
  final String channel;
  final String title;
  final String body;
  final String? clickAction;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime? readAt;
  final String status;
  final String? error;
  final DateTime? sentAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? icon;

  NotificationEntity({
    required this.notificationId,
    required this.userId,
    required this.type,
    required this.channel,
    required this.title,
    required this.body,
    this.clickAction,
    this.data,
    required this.isRead,
    this.readAt,
    required this.status,
    this.error,
    this.sentAt,
    required this.createdAt,
    required this.updatedAt,
    this.icon,
  });
}

class NotificationDataEntity {
  final List<NotificationEntity> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  NotificationDataEntity({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });
}
