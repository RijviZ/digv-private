import '../models/order_item.dart';
import '../models/order_tracking_data.dart';

abstract class OrdersRepository {
  Future<List<OrderItem>> getServiceRequests({String? status});
  Future<void> rescheduleServiceRequest({
    required String id,
    required String scheduledDate,
    required List<String> availabilitySlotIds,
  });
  Future<void> cancelServiceRequest({
    required String id,
    required String reason,
  });
  Future<OrderTrackingData> getOrderTracking({
    required String id,
  });
  Future<void> submitReview({
    required String serviceRequestId,
    required String targetType,
    required int rating,
    required String comment,
    required List<String> tags,
    required List<String> photos,
  });
  Future<Map<String, dynamic>?> getGivenReviewByServiceRequestId({required String serviceRequestId});
  Future<void> updateReview({
    required String id,
    required int rating,
    required String comment,
    required List<String> tags,
    required List<String> photos,
  });
}
