enum PaymentType { prepaid, postpaid }

enum OrderStatus {
  assigned,
  onTheWay,
  arrived,
  workStarted,
  workDoneOtp,
  completed,
}

extension OrderStatusLabel on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.assigned:
        return 'Technician Assigned';
      case OrderStatus.onTheWay:
        return 'On the Way';
      case OrderStatus.arrived:
        return 'Arrived';
      case OrderStatus.workStarted:
        return 'Work Started';
      case OrderStatus.workDoneOtp:
        return 'OTP Required';
      case OrderStatus.completed:
        return 'Completed';
    }
  }
}
