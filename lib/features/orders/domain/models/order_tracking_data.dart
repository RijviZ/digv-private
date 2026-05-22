class OrderTrackingLog {
  final String logId;
  final String serviceRequestId;
  final String? createdByUserId;
  final String action;
  final String? previousStatus;
  final String? newStatus;
  final String note;
  final String createdAt;
  final OrderTrackingActor? actor;

  const OrderTrackingLog({
    required this.logId,
    required this.serviceRequestId,
    this.createdByUserId,
    required this.action,
    this.previousStatus,
    this.newStatus,
    required this.note,
    required this.createdAt,
    this.actor,
  });

  factory OrderTrackingLog.fromJson(Map<String, dynamic> json) {
    return OrderTrackingLog(
      logId: json['logId'] as String? ?? '',
      serviceRequestId: json['serviceRequestId'] as String? ?? '',
      createdByUserId: json['createdByUserId'] as String?,
      action: json['action'] as String? ?? '',
      previousStatus: json['previousStatus'] as String?,
      newStatus: json['newStatus'] as String?,
      note: json['note'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      actor: json['actor'] != null
          ? OrderTrackingActor.fromJson(json['actor'] as Map<String, dynamic>)
          : null,
    );
  }
}

class OrderTrackingActor {
  final String userId;
  final String phoneNumber;
  final String countryCode;
  final String email;
  final String fullName;
  final String gender;
  final String? avatarUrl;

  const OrderTrackingActor({
    required this.userId,
    required this.phoneNumber,
    required this.countryCode,
    required this.email,
    required this.fullName,
    required this.gender,
    this.avatarUrl,
  });

  factory OrderTrackingActor.fromJson(Map<String, dynamic> json) {
    return OrderTrackingActor(
      userId: json['userId'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      countryCode: json['countryCode'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}

class OrderTrackingData {
  final String serviceRequestId;
  final List<OrderTrackingLog> logs;

  const OrderTrackingData({
    required this.serviceRequestId,
    required this.logs,
  });

  factory OrderTrackingData.fromJson(Map<String, dynamic> json) {
    final logsList = json['logs'] as List? ?? [];
    return OrderTrackingData(
      serviceRequestId: json['serviceRequestId'] as String? ?? '',
      logs: logsList
          .map((log) => OrderTrackingLog.fromJson(log as Map<String, dynamic>))
          .toList(),
    );
  }
}
