import 'package:dio/dio.dart';

abstract class PaymentsRemoteDataSource {
  Future<Map<String, dynamic>> createPendingPayment({
    required String serviceRequestId,
    required String method,
    required String collectionType,
    required String amount,
    required String gatewayReference,
    String? note,
  });

  Future<Map<String, dynamic>> confirmPayment({
    required String paymentId,
    required String gatewayTransactionId,
    required Map<String, dynamic> gatewayResponse,
  });
}

class PaymentsRemoteDataSourceImpl implements PaymentsRemoteDataSource {
  final Dio _dio;

  PaymentsRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<Map<String, dynamic>> createPendingPayment({
    required String serviceRequestId,
    required String method,
    required String collectionType,
    required String amount,
    required String gatewayReference,
    String? note,
  }) async {
    final response = await _dio.post(
      '/users/payment/service-request',
      data: {
        'serviceRequestId': serviceRequestId,
        'method': method,
        'collectionType': collectionType,
        'amount': amount,
        'gatewayReference': gatewayReference,
        'note': note ?? '',
      },
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> confirmPayment({
    required String paymentId,
    required String gatewayTransactionId,
    required Map<String, dynamic> gatewayResponse,
  }) async {
    final response = await _dio.post(
      '/payments/$paymentId/confirm',
      data: {
        'gatewayResponse': gatewayResponse,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
