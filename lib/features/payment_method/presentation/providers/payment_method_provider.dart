import 'package:digv/features/payment_method/data/repositories/payment_method_repository_impl.dart';
import 'package:digv/features/payment_method/data/sources/payment_method_remote_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/repositories/payment_method_repository.dart';

final paymentMethodRemoteDataSourceProvider = Provider<PaymentMethodRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return PaymentMethodRemoteDataSourceImpl(dio: dio);
});

final paymentMethodRepositoryProvider = Provider<PaymentMethodRepository>((ref) {
  final dataSource = ref.watch(paymentMethodRemoteDataSourceProvider);
  return PaymentMethodRepositoryImpl(remoteDataSource: dataSource);
});

class PaymentMethodsNotifier extends AsyncNotifier<List<PaymentMethod>> {
  @override
  Future<List<PaymentMethod>> build() async {
    return await ref.watch(paymentMethodRepositoryProvider).getPaymentMethods();
  }

  Future<void> addPaymentMethod(PaymentMethod method) async {
    final previousState = state;
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(paymentMethodRepositoryProvider);
      final newMethod = await repository.addPaymentMethod(method);
      
      // Update state with new method, refresh list if necessary, or just append
      if (previousState.hasValue) {
        state = AsyncValue.data([...previousState.value!, newMethod]);
      } else {
        state = AsyncValue.data([newMethod]);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      // Depending on UI flow, you might want to restore previous state or keep error
      // state = previousState;
      rethrow;
    }
  }

  Future<void> updatePaymentMethod(String id, PaymentMethod method) async {
    final previousState = state;
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(paymentMethodRepositoryProvider);
      final updatedMethod = await repository.updatePaymentMethod(id, method);
      
      if (previousState.hasValue) {
        final newList = previousState.value!.map((m) {
          return m.userPaymentMethodId == id ? updatedMethod : m;
        }).toList();
        state = AsyncValue.data(newList);
      } else {
        state = AsyncValue.data([updatedMethod]);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> deletePaymentMethod(String id) async {
    final previousState = state;
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(paymentMethodRepositoryProvider);
      await repository.deletePaymentMethod(id);
      
      if (previousState.hasValue) {
        final newList = previousState.value!.where((m) => m.userPaymentMethodId != id).toList();
        state = AsyncValue.data(newList);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> setDefaultPaymentMethod(String id) async {
    final previousState = state;
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(paymentMethodRepositoryProvider);
      final updatedMethod = await repository.setDefaultPaymentMethod(id);
      
      if (previousState.hasValue) {
        final newList = previousState.value!.map((m) {
          if (m.userPaymentMethodId == id) {
            return updatedMethod;
          }
          // The backend usually handles setting others to false, but we can optimistically update here
          // We can just rely on the updatedMethod and assume others are no longer default
          return PaymentMethod(
            userPaymentMethodId: m.userPaymentMethodId,
            cardHolderName: m.cardHolderName,
            cardBrand: m.cardBrand,
            cardLast4: m.cardLast4,
            expiryMonth: m.expiryMonth,
            expiryYear: m.expiryYear,
            isDefault: false,
            isActive: m.isActive,
            createdAt: m.createdAt,
            updatedAt: m.updatedAt,
          );
        }).toList();
        state = AsyncValue.data(newList);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

final paymentMethodsProvider =
    AsyncNotifierProvider<PaymentMethodsNotifier, List<PaymentMethod>>(() {
  return PaymentMethodsNotifier();
});
