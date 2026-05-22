import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/dio_provider.dart';
import '../../data/repositories/payments_repository_impl.dart';
import '../../data/sources/payments_remote_data_source.dart';
import '../../domain/repositories/payments_repository.dart';

final paymentsRemoteDataSourceProvider = Provider<PaymentsRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return PaymentsRemoteDataSourceImpl(dio: dio);
});

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  final dataSource = ref.watch(paymentsRemoteDataSourceProvider);
  return PaymentsRepositoryImpl(remoteDataSource: dataSource);
});

final paymentsNotifierProvider = StateNotifierProvider<PaymentsNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  final repository = ref.watch(paymentsRepositoryProvider);
  return PaymentsNotifier(repository: repository);
});

class PaymentsNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final PaymentsRepository _repository;

  PaymentsNotifier({required PaymentsRepository repository})
      : _repository = repository,
        super(const AsyncValue.data({}));

  Future<Map<String, dynamic>> createPendingPayment({
    required String serviceRequestId,
    required String method,
    required String collectionType,
    required String amount,
    required String gatewayReference,
    String? note,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.createPendingPayment(
        serviceRequestId: serviceRequestId,
        method: method,
        collectionType: collectionType,
        amount: amount,
        gatewayReference: gatewayReference,
        note: note,
      );
      state = AsyncValue.data(result);
      return result;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> confirmPayment({
    required String paymentId,
    required String gatewayTransactionId,
    required Map<String, dynamic> gatewayResponse,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.confirmPayment(
        paymentId: paymentId,
        gatewayTransactionId: gatewayTransactionId,
        gatewayResponse: gatewayResponse,
      );
      state = AsyncValue.data(result);
      return result;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}
