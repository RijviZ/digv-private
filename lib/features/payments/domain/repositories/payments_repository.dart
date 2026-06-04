abstract class PaymentsRepository {
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
