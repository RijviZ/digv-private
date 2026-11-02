enum OrderTab { active, upcoming, past, disputes, cancelled }

enum OrderBadgeStatus { active, upcoming, completed, cancelled }

extension OrderBadgeStatusLabel on OrderBadgeStatus {
  String get label {
    switch (this) {
      case OrderBadgeStatus.active:
        return 'Active';
      case OrderBadgeStatus.upcoming:
        return 'Upcoming';
      case OrderBadgeStatus.completed:
        return 'Completed';
      case OrderBadgeStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class OrderItem {
  final String id;
  final String? providerId;
  final String? serviceItemId;
  final String? providerServiceId;
  final String serviceName;
  final String? categoryName;
  final String? serviceTypeName;
  final String? description;
  final String orderId;
  final OrderBadgeStatus status;
  final String scheduledTime;
  final String location;
  final String technicianName;
  final String? technicianImageUrl;
  final String price;
  final int quantity;
  final double? unitPrice;
  final double? rating;
  final String? cancelReason;
  final String? paymentStatus;
  final String? paymentMethod;
  final String? providerPhoneNumber;
  final int? reviews;
  final String? otp;

  const OrderItem({
    required this.id,
    this.providerId,
    this.serviceItemId,
    this.providerServiceId,
    required this.serviceName,
    this.categoryName,
    this.serviceTypeName,
    this.description,
    required this.orderId,
    required this.status,
    required this.scheduledTime,
    required this.location,
    required this.technicianName,
    this.technicianImageUrl,
    required this.price,
    this.quantity = 1,
    this.unitPrice,
    this.rating,
    this.cancelReason,
    this.paymentStatus,
    this.paymentMethod,
    this.providerPhoneNumber,
    this.reviews,
    this.otp,
  });
}
