import 'dart:convert';
import 'package:digv/features/payment_method/data/models/payment_method_model.dart';
import 'package:digv/features/payment_method/data/repositories/payment_method_repository_impl.dart';
import 'package:digv/features/payment_method/data/sources/payment_method_remote_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/storage/secure_storage_provider.dart';
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
  static const String _storageKey = 'saved_payment_methods';

  @override
  Future<List<PaymentMethod>> build() async {
    List<PaymentMethod> localCards = [];
    try {
      final storage = ref.read(secureStorageProvider);
      final rawJson = await storage.read(key: _storageKey);
      if (rawJson != null && rawJson.isNotEmpty) {
        final decoded = jsonDecode(rawJson) as List<dynamic>;
        localCards = decoded
            .whereType<Map<String, dynamic>>()
            .map((json) => PaymentMethodModel.fromJson(json))
            .toList();
      }
    } catch (_) {}

    try {
      final remoteMethods = await ref.watch(paymentMethodRepositoryProvider).getPaymentMethods();
      if (remoteMethods.isNotEmpty) {
        final existingIds = remoteMethods.map((r) => r.userPaymentMethodId).toSet();
        final combined = [
          ...remoteMethods,
          ...localCards.where((l) => l.userPaymentMethodId != null && !existingIds.contains(l.userPaymentMethodId)),
        ];
        await _persist(combined);
        return combined;
      }
    } catch (_) {}

    return localCards;
  }

  Future<void> _persist(List<PaymentMethod> list) async {
    try {
      final storage = ref.read(secureStorageProvider);
      final encoded = jsonEncode(list.map((m) {
        if (m is PaymentMethodModel) return m.toJson();
        return PaymentMethodModel(
          userPaymentMethodId: m.userPaymentMethodId,
          cardHolderName: m.cardHolderName,
          cardBrand: m.cardBrand,
          cardLast4: m.cardLast4,
          expiryMonth: m.expiryMonth,
          expiryYear: m.expiryYear,
          isDefault: m.isDefault,
          isActive: m.isActive,
          createdAt: m.createdAt,
          updatedAt: m.updatedAt,
        ).toJson();
      }).toList());
      await storage.write(key: _storageKey, value: encoded);
    } catch (_) {}
  }

  Future<void> addPaymentMethod(PaymentMethod method) async {
    final previousList = state.value ?? [];
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(paymentMethodRepositoryProvider);
      final newMethod = await repository.addPaymentMethod(method);

      List<PaymentMethod> updatedList;
      if (newMethod.isDefault) {
        updatedList = [
          ...previousList.map((m) => PaymentMethod(
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
              )),
          newMethod,
        ];
      } else {
        if (previousList.isEmpty) {
          final defaultMethod = PaymentMethod(
            userPaymentMethodId: newMethod.userPaymentMethodId,
            cardHolderName: newMethod.cardHolderName,
            cardBrand: newMethod.cardBrand,
            cardLast4: newMethod.cardLast4,
            expiryMonth: newMethod.expiryMonth,
            expiryYear: newMethod.expiryYear,
            isDefault: true,
            isActive: newMethod.isActive,
            createdAt: newMethod.createdAt,
            updatedAt: newMethod.updatedAt,
          );
          updatedList = [defaultMethod];
        } else {
          updatedList = [...previousList, newMethod];
        }
      }

      state = AsyncValue.data(updatedList);
      await _persist(updatedList);
    } catch (_) {
      final fallbackCard = PaymentMethod(
        userPaymentMethodId: 'card_${DateTime.now().millisecondsSinceEpoch}',
        cardHolderName: method.cardHolderName,
        cardBrand: method.cardBrand,
        cardLast4: method.cardLast4,
        expiryMonth: method.expiryMonth,
        expiryYear: method.expiryYear,
        isDefault: previousList.isEmpty || method.isDefault,
      );
      final updatedList = [
        if (fallbackCard.isDefault)
          ...previousList.map((m) => PaymentMethod(
                userPaymentMethodId: m.userPaymentMethodId,
                cardHolderName: m.cardHolderName,
                cardBrand: m.cardBrand,
                cardLast4: m.cardLast4,
                expiryMonth: m.expiryMonth,
                expiryYear: m.expiryYear,
                isDefault: false,
              ))
        else
          ...previousList,
        fallbackCard,
      ];
      state = AsyncValue.data(updatedList);
      await _persist(updatedList);
    }
  }

  Future<void> updatePaymentMethod(String id, PaymentMethod method) async {
    final previousList = state.value ?? [];
    try {
      final repository = ref.read(paymentMethodRepositoryProvider);
      final updatedMethod = await repository.updatePaymentMethod(id, method);
      final newList = previousList.map((m) {
        return m.userPaymentMethodId == id ? updatedMethod : m;
      }).toList();
      state = AsyncValue.data(newList);
      await _persist(newList);
    } catch (_) {
      final newList = previousList.map((m) {
        return m.userPaymentMethodId == id ? method : m;
      }).toList();
      state = AsyncValue.data(newList);
      await _persist(newList);
    }
  }

  Future<void> deletePaymentMethod(String id) async {
    final previousList = state.value ?? [];
    final wasDefault = previousList.any((m) => m.userPaymentMethodId == id && m.isDefault);
    final updatedList = previousList.where((m) => m.userPaymentMethodId != id).toList();

    if (wasDefault && updatedList.isNotEmpty) {
      final first = updatedList.first;
      updatedList[0] = PaymentMethod(
        userPaymentMethodId: first.userPaymentMethodId,
        cardHolderName: first.cardHolderName,
        cardBrand: first.cardBrand,
        cardLast4: first.cardLast4,
        expiryMonth: first.expiryMonth,
        expiryYear: first.expiryYear,
        isDefault: true,
        isActive: first.isActive,
        createdAt: first.createdAt,
        updatedAt: first.updatedAt,
      );
    }

    state = AsyncValue.data(updatedList);
    await _persist(updatedList);

    try {
      final repository = ref.read(paymentMethodRepositoryProvider);
      await repository.deletePaymentMethod(id);
    } catch (_) {}
  }

  Future<void> setDefaultPaymentMethod(String id) async {
    final currentList = state.value ?? [];
    final updatedList = currentList.map((m) {
      return PaymentMethod(
        userPaymentMethodId: m.userPaymentMethodId,
        cardHolderName: m.cardHolderName,
        cardBrand: m.cardBrand,
        cardLast4: m.cardLast4,
        expiryMonth: m.expiryMonth,
        expiryYear: m.expiryYear,
        isDefault: m.userPaymentMethodId == id,
        isActive: m.isActive,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
      );
    }).toList();

    state = AsyncValue.data(updatedList);
    await _persist(updatedList);

    try {
      final repository = ref.read(paymentMethodRepositoryProvider);
      await repository.setDefaultPaymentMethod(id);
    } catch (_) {}
  }
}

final paymentMethodsProvider =
    AsyncNotifierProvider<PaymentMethodsNotifier, List<PaymentMethod>>(() {
  return PaymentMethodsNotifier();
});
