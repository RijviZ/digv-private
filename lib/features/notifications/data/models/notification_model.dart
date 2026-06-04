import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  NotificationModel({
    required super.notificationId,
    required super.userId,
    required super.type,
    required super.channel,
    required super.title,
    required super.body,
    super.clickAction,
    super.data,
    required super.isRead,
    super.readAt,
    required super.status,
    super.error,
    super.sentAt,
    required super.createdAt,
    required super.updatedAt,
    super.icon,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notificationId'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      channel: json['channel'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      clickAction: json['clickAction'],
      data: json['data'],
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      status: json['status'] ?? '',
      error: json['error'],
      sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      icon: json['icon'],
    );
  }
}

class NotificationDataModel extends NotificationDataEntity {
  NotificationDataModel({
    required super.items,
    required super.total,
    required super.page,
    required super.limit,
    required super.totalPages,
  });

  factory NotificationDataModel.fromJson(Map<String, dynamic> json) {
    return NotificationDataModel(
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['meta']?['total'] ?? 0,
      page: json['meta']?['page'] ?? 1,
      limit: json['meta']?['limit'] ?? 100,
      totalPages: json['meta']?['totalPages'] ?? 1,
    );
  }
}
