import '../../domain/repositories/payments_repository.dart';
import '../sources/payments_remote_data_source.dart';

class PaymentsRepositoryImpl implements PaymentsRepository {
  final PaymentsRemoteDataSource remoteDataSource;

  PaymentsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Map<String, dynamic>> createPendingPayment({
    required String serviceRequestId,
    required String method,
    required String collectionType,
    required String amount,
    required String gatewayReference,
    String? note,
  }) async {
    return await remoteDataSource.createPendingPayment(
      serviceRequestId: serviceRequestId,
      method: method,
      collectionType: collectionType,
      amount: amount,
      gatewayReference: gatewayReference,
      note: note,
    );
  }

  @override
  Future<Map<String, dynamic>> confirmPayment({
    required String paymentId,
    required String gatewayTransactionId,
    required Map<String, dynamic> gatewayResponse,
  }) async {
    return await remoteDataSource.confirmPayment(
      paymentId: paymentId,
      gatewayTransactionId: gatewayTransactionId,
      gatewayResponse: gatewayResponse,
    );
  }
}
