enum OrderTab { active, upcoming, past, cancelled }

enum OrderBadgeStatus { active, upcoming, completed, inProgress, pending, cancelled }

extension OrderBadgeStatusLabel on OrderBadgeStatus {
  String get label {
    switch (this) {
      case OrderBadgeStatus.active:
        return 'Active';
      case OrderBadgeStatus.upcoming:
        return 'Upcoming';
      case OrderBadgeStatus.completed:
        return 'Completed';
      case OrderBadgeStatus.inProgress:
        return 'In Progress';
      case OrderBadgeStatus.pending:
        return 'Pending';
      case OrderBadgeStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class OrderItem {
  final String id;
  final String serviceName;
  final String orderId;
  final OrderBadgeStatus status;
  final String scheduledTime;
  final String location;
  final String technicianName;
  final String? technicianImageUrl;
  final String price;
  final double? rating;

  const OrderItem({
    required this.id,
    required this.serviceName,
    required this.orderId,
    required this.status,
    required this.scheduledTime,
    required this.location,
    required this.technicianName,
    this.technicianImageUrl,
    required this.price,
    this.rating,
  });
}
