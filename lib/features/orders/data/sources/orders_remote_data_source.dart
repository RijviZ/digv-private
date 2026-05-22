import 'package:dio/dio.dart';

abstract class OrdersRemoteDataSource {
  Future<List<Map<String, dynamic>>> getServiceRequests({String? status, int page = 1, int limit = 100});
  Future<Map<String, dynamic>> rescheduleServiceRequest({
    required String id,
    required String scheduledDate,
    required List<String> availabilitySlotIds,
  });
  Future<Map<String, dynamic>> cancelServiceRequest({
    required String id,
    required String reason,
  });
  Future<Map<String, dynamic>> getOrderTracking({
    required String id,
  });
  Future<Map<String, dynamic>> submitReview({
    required String serviceRequestId,
    required String targetType,
    required int rating,
    required String comment,
    required List<String> tags,
    required List<String> photos,
  });
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final Dio _dio;

  OrdersRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<Map<String, dynamic>>> getServiceRequests({String? status, int page = 1, int limit = 100}) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (status != null) {
      queryParameters['status'] = status;
    }

    final response = await _dio.get('/users/serviceRequests', queryParameters: queryParameters);
    
    // Parse response
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      final items = data['data']['items'] as List?;
      if (items != null) {
        return items.cast<Map<String, dynamic>>();
      }
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> rescheduleServiceRequest({
    required String id,
    required String scheduledDate,
    required List<String> availabilitySlotIds,
  }) async {
    final response = await _dio.patch(
      '/users/serviceRequests/$id/reschedule',
      data: {
        'scheduledDate': scheduledDate,
        'availabilitySlotIds': availabilitySlotIds,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> cancelServiceRequest({
    required String id,
    required String reason,
  }) async {
    final response = await _dio.patch(
      '/users/serviceRequests/$id/cancel',
      data: {
        'reason': reason,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getOrderTracking({
    required String id,
  }) async {
    final response = await _dio.get('/service-requests/$id/tracking');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> submitReview({
    required String serviceRequestId,
    required String targetType,
    required int rating,
    required String comment,
    required List<String> tags,
    required List<String> photos,
  }) async {
    final response = await _dio.post(
      '/reviews',
      data: {
        'serviceRequestId': serviceRequestId,
        'targetType': targetType,
        'rating': rating,
        'comment': comment,
        'tags': tags,
        'photos': photos,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
