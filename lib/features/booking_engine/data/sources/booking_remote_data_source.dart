import 'package:dio/dio.dart';

abstract class BookingRemoteDataSource {
  Future<Map<String, dynamic>> createServiceRequest(Map<String, dynamic> payload);
  Future<List<Map<String, dynamic>>> getAvailableSlots(String providerId, String scheduledDate);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final Dio _dio;

  BookingRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<Map<String, dynamic>> createServiceRequest(Map<String, dynamic> payload) async {
    final response = await _dio.post('/users/serviceRequests', data: payload);
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> getAvailableSlots(String providerId, String scheduledDate) async {
    final response = await _dio.get(
      '/users/getProvider/available-slots',
      queryParameters: {
        'providerId': providerId,
        'scheduledDate': scheduledDate,
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      final list = data['data'] as List?;
      if (list != null) {
        return list.cast<Map<String, dynamic>>();
      }
    }
    return [];
  }
}
