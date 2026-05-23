import 'package:intl/intl.dart';
import '../../domain/models/order_item.dart';
import '../../domain/models/order_tracking_data.dart';
import '../../domain/repositories/orders_repository.dart';
import '../sources/orders_remote_data_source.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource remoteDataSource;

  OrdersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<OrderItem>> getServiceRequests({String? status}) async {
    final items = await remoteDataSource.getServiceRequests(status: status);
    return items.map((map) => _mapToOrderItem(map)).toList();
  }

  OrderItem _mapToOrderItem(Map<String, dynamic> map) {
    final statusStr = map['status'] as String? ?? 'PENDING';
    
    // Map API status to OrderBadgeStatus
    OrderBadgeStatus badgeStatus = OrderBadgeStatus.upcoming;
    switch (statusStr) {
      case 'ACCEPTED':
        badgeStatus = OrderBadgeStatus.active;
        break;
      case 'ON_THE_WAY':
      case 'ARRIVED':
      case 'WORK_STARTED':
      case 'PENDING':
      case 'IN_PROGRESS':
        badgeStatus = OrderBadgeStatus.active;
        break;
      case 'COMPLETED':
        badgeStatus = OrderBadgeStatus.completed;
        break;
      case 'CANCELLED':
      case 'REJECTED':
        badgeStatus = OrderBadgeStatus.cancelled;
        break;
    }

    // Format scheduled time
    String scheduledTime = 'Scheduled';
    final scheduledAtStr = map['scheduledAt'] as String?;
    if (scheduledAtStr != null) {
      try {
        final dateTime = DateTime.parse(scheduledAtStr);
        scheduledTime = DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
      } catch (_) {}
    }

    // Price formatting
    final subtotalAmount = map['subtotalAmount'] as String? ?? '0.00';
    final doubleAmount = double.tryParse(subtotalAmount) ?? 0.0;
    final currencyStr = map['currency'] as String? ?? 'BDT';
    final symbol = currencyStr == 'BDT' ? '৳' : '₹';
    final priceStr = '$symbol${doubleAmount.toStringAsFixed(0)}';

    return OrderItem(
      id: map['serviceRequestId'] as String? ?? '',
      providerId: map['providerId'] as String?,
      serviceName: map['serviceTitle'] as String? ?? 'Service Request',
      orderId: 'ORD-${(map['serviceRequestId'] as String? ?? '').substring(0, 4).toUpperCase()}',
      status: badgeStatus,
      scheduledTime: scheduledTime,
      location: map['addressLabel'] as String? ?? 'Home',
      technicianName: map['providerName'] as String? ?? 'Assigned Professional',
      technicianImageUrl: map['providerAvatarUrl'] as String? ?? map['providerImageUrl'] as String?,
      price: priceStr,
      rating: map['rating'] != null ? (map['rating'] as num).toDouble() : null,
      cancelReason: map['cancelReason'] as String? ?? map['reason'] as String?,
      paymentStatus: map['paymentStatus'] as String?,
      paymentMethod: map['paymentMethod'] as String?,
      providerPhoneNumber: map['providerPhoneNumber'] as String?,
    );
  }

  @override
  Future<void> rescheduleServiceRequest({
    required String id,
    required String scheduledDate,
    required List<String> availabilitySlotIds,
  }) async {
    await remoteDataSource.rescheduleServiceRequest(
      id: id,
      scheduledDate: scheduledDate,
      availabilitySlotIds: availabilitySlotIds,
    );
  }

  @override
  Future<void> cancelServiceRequest({
    required String id,
    required String reason,
  }) async {
    await remoteDataSource.cancelServiceRequest(
      id: id,
      reason: reason,
    );
  }

  @override
  Future<OrderTrackingData> getOrderTracking({
    required String id,
  }) async {
    final map = await remoteDataSource.getOrderTracking(id: id);
    if (map['data'] != null) {
      return OrderTrackingData.fromJson(map['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to load order tracking data');
  }

  @override
  Future<void> submitReview({
    required String serviceRequestId,
    required String targetType,
    required int rating,
    required String comment,
    required List<String> tags,
    required List<String> photos,
  }) async {
    await remoteDataSource.submitReview(
      serviceRequestId: serviceRequestId,
      targetType: targetType,
      rating: rating,
      comment: comment,
      tags: tags,
      photos: photos,
    );
  }
}
