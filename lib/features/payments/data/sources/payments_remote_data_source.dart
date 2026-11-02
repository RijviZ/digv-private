import 'package:dio/dio.dart';

abstract class PaymentsRemoteDataSource {
  Future<Map<String, dynamic>> createPendingPayment({
    required String serviceRequestId,
    required String method,
    required String collectionType,
    required String gatewayReference,
    String? note,
  });

  Future<Map<String, dynamic>> confirmPayment({
    required String paymentId,
    required Map<String, dynamic> gatewayResponse,
    String? gatewayTransactionId,
  });

  Future<List<Map<String, dynamic>>> getMyRefunds();
}

class PaymentsRemoteDataSourceImpl implements PaymentsRemoteDataSource {
  final Dio _dio;

  PaymentsRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<Map<String, dynamic>> createPendingPayment({
    required String serviceRequestId,
    required String method,
    required String collectionType,
    required String gatewayReference,
    String? note,
  }) async {
    final response = await _dio.post(
      '/users/payment/service-request',
      data: {
        'serviceRequestId': serviceRequestId,
        'method': method,
        'collectionType': collectionType,
        'gatewayReference': gatewayReference,
        if (note != null && note.isNotEmpty) 'note': note,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> confirmPayment({
    required String paymentId,
    required Map<String, dynamic> gatewayResponse,
    String? gatewayTransactionId,
  }) async {
    final response = await _dio.post(
      '/payments/$paymentId/confirm',
      data: {
        'gatewayResponse': gatewayResponse,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> getMyRefunds() async {
    final response = await _dio.get('/refunds/my');
    final data = response.data;
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    } else if (data is Map<String, dynamic>) {
      if (data['data'] is List) {
        return (data['data'] as List).whereType<Map<String, dynamic>>().toList();
      } else if (data['data'] is Map && data['data']['items'] is List) {
        return (data['data']['items'] as List).whereType<Map<String, dynamic>>().toList();
      }
    }
    return [];
  }
}
