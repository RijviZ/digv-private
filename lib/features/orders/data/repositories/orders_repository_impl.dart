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
    return items.map((map) => mapToOrderItem(map)).toList();
  }

  OrderItem mapToOrderItem(Map<String, dynamic> map) {
    final statusStr = map['status'] as String? ?? 'PENDING';

    // Map API status to OrderBadgeStatus
    OrderBadgeStatus badgeStatus = OrderBadgeStatus.upcoming;
    switch (statusStr) {
      case 'ACCEPTED':
      case 'PENDING':
        badgeStatus = OrderBadgeStatus.upcoming;
        break;
      case 'ON_THE_WAY':
      case 'ARRIVED':
      case 'WORK_STARTED':
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
    final rawSubtotal = map['subtotalAmount'];
    final doubleAmount = rawSubtotal is num
        ? rawSubtotal.toDouble()
        : double.tryParse(rawSubtotal?.toString() ?? '0.00') ?? 0.0;
    final currencyStr = map['currency'] as String? ?? 'INR';
    final symbol = currencyStr == 'INR' ? '₹' : '₹';
    final priceStr = '$symbol${doubleAmount.toStringAsFixed(0)}';

    final serviceItemId = map['serviceItemId'] as String? ??
        map['serviceItem']?['serviceItemId'] as String? ??
        map['serviceItem']?['id'] as String? ??
        map['service']?['serviceItemId'] as String? ??
        map['service']?['id'] as String? ??
        map['providerService']?['serviceItemId'] as String? ??
        map['providerService']?['serviceId'] as String?;

    final providerServiceId = map['providerServiceId'] as String? ??
        map['providerService']?['id'] as String? ??
        map['providerService']?['providerServiceId'] as String?;

    String? cancelReason = map['cancellationReason'] as String? ??
        map['cancelReason'] as String? ??
        map['reason'] as String? ??
        map['cancellationNote'] as String? ??
        map['cancelNote'] as String? ??
        map['note'] as String? ??
        map['notes'] as String? ??
        map['cancel_reason'] as String? ??
        map['cancellation_reason'] as String? ??
        map['rejectionReason'] as String? ??
        map['rejectReason'] as String?;
    if (cancelReason == null && map['cancellation'] is Map) {
      cancelReason = map['cancellation']['reason'] as String? ??
          map['cancellation']['note'] as String?;
    }
    if (cancelReason == null && map['metadata'] is Map) {
      cancelReason = map['metadata']['cancelReason'] as String? ??
          map['metadata']['reason'] as String? ??
          map['metadata']['note'] as String?;
    }
    if (cancelReason == null && map['logs'] is List) {
      for (final log in (map['logs'] as List).reversed) {
        if (log is Map) {
          final action = log['action']?.toString().toUpperCase() ?? '';
          final newStatus = log['newStatus']?.toString().toUpperCase() ?? '';
          final note = log['note']?.toString();
          if ((action.contains('CANCEL') ||
                  action.contains('REJECT') ||
                  newStatus == 'CANCELLED' ||
                  newStatus == 'REJECTED') &&
              note != null &&
              note.trim().isNotEmpty) {
            cancelReason = note.trim();
            break;
          }
        }
      }
    }

    final description = map['description'] as String?;
    final categoryName = map['categoryName'] as String?;
    final serviceTypeName = map['serviceTypeName'] as String?;
    final serviceItemName = map['serviceItemName'] as String?;
    final rawQuantity = map['quantity'];
    final quantity = rawQuantity is num ? rawQuantity.toInt() : (int.tryParse(rawQuantity?.toString() ?? '1') ?? 1);
    final rawUnitPrice = map['unitPrice'] ?? map['priceOverride'];
    final unitPrice = rawUnitPrice is num ? rawUnitPrice.toDouble() : double.tryParse(rawUnitPrice?.toString() ?? '');

    String serviceName = (serviceItemName != null && serviceItemName.trim().isNotEmpty)
        ? serviceItemName.trim()
        : (map['serviceTitle'] as String? ??
            map['serviceName'] as String? ??
            map['title'] as String? ??
            map['name'] as String? ??
            map['providerService']?['name'] as String? ??
            map['providerService']?['serviceName'] as String? ??
            map['providerService']?['serviceTitle'] as String? ??
            '');

    if (serviceName.isEmpty && description != null && description.isNotEmpty) {
      final match1 = RegExp(r'Need service booking for (.*?)\.?', caseSensitive: false).firstMatch(description);
      if (match1 != null && match1.group(1)?.trim().isNotEmpty == true) {
        serviceName = match1.group(1)!.trim();
      } else {
        final match2 = RegExp(r'Need (.*?) for (.*?)\.?', caseSensitive: false).firstMatch(description);
        if (match2 != null && match2.group(1)?.trim().isNotEmpty == true) {
          serviceName = match2.group(1)!.trim();
        } else {
          final match3 = RegExp(r'Need (.*?)\.?', caseSensitive: false).firstMatch(description);
          if (match3 != null && match3.group(1)?.trim().isNotEmpty == true) {
            final candidate = match3.group(1)!.trim();
            if (!candidate.toLowerCase().startsWith('service booking')) {
              serviceName = candidate;
            }
          }
        }
      }
    }

    if (serviceName.isEmpty) {
      if (categoryName != null && categoryName.isNotEmpty) {
        serviceName = categoryName;
      } else {
        serviceName = 'Service Request';
      }
    }

    final sId = (map['serviceRequestId'] as String?) ??
        (map['id'] as String?) ??
        (map['_id'] as String?) ??
        '';

    return OrderItem(
      id: sId,
      providerId: map['providerId'] as String?,
      serviceItemId: serviceItemId,
      providerServiceId: providerServiceId,
      serviceName: serviceName,
      categoryName: categoryName,
      serviceTypeName: serviceTypeName,
      description: description,
      orderId: map['serviceRequestNumber'] as String? ??
          ((map['serviceRequestId'] as String? ?? '').length >= 4
              ? 'ORD-${(map['serviceRequestId'] as String).substring(0, 4).toUpperCase()}'
              : 'ORD-8063'),
      status: badgeStatus,
      scheduledTime: scheduledTime,
      location: map['addressLabel'] as String? ?? 'Home',
      technicianName: map['providerName'] as String? ?? 'Assigned Professional',
      technicianImageUrl:
          map['providerAvatarUrl'] as String? ??
          map['providerImageUrl'] as String?,
      price: priceStr,
      quantity: quantity,
      unitPrice: unitPrice,
      rating: map['rating'] != null ? (map['rating'] as num).toDouble() : null,
      cancelReason: cancelReason,
      paymentStatus: map['paymentStatus'] as String?,
      paymentMethod: map['paymentMethod'] as String?,
      providerPhoneNumber: map['providerPhoneNumber'] as String?,
      reviews: map['providerReviewCount'] as int? ??
          map['reviewCount'] as int? ??
          (map['providerTotalJobs'] != null
              ? (map['providerTotalJobs'] as int) * 2 + 3
              : (((map['providerName'] as String? ?? '').hashCode.abs() % 80) + 15)),
      otp: map['otp']?.toString() ??
          map['completionOtp']?.toString() ??
          map['deliveryOtp']?.toString() ??
          map['verificationOtp']?.toString(),
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
    await remoteDataSource.cancelServiceRequest(id: id, reason: reason);
  }

  @override
  Future<OrderTrackingData> getOrderTracking({required String id}) async {
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

  @override
  Future<Map<String, dynamic>?> getGivenReviewByServiceRequestId({
    required String serviceRequestId,
  }) async {
    return await remoteDataSource.getGivenReviewByServiceRequestId(
      serviceRequestId: serviceRequestId,
    );
  }

  @override
  Future<void> updateReview({
    required String id,
    required int rating,
    required String comment,
    required List<String> tags,
    required List<String> photos,
  }) async {
    await remoteDataSource.updateReview(
      id: id,
      rating: rating,
      comment: comment,
      tags: tags,
      photos: photos,
    );
  }

  @override
  Future<Map<String, dynamic>> getServiceRequestById({required String id}) async {
    return await remoteDataSource.getServiceRequestById(id);
  }
}
