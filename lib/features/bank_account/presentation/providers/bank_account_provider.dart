import 'dart:async';
import 'package:digv/features/bank_account/data/repositories/bank_account_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/bank_account.dart';

class BankAccountsNotifier extends AsyncNotifier<List<BankAccount>> {
  @override
  FutureOr<List<BankAccount>> build() async {
    final repository = ref.watch(bankAccountRepositoryProvider);
    return await repository.getBankAccounts();
  }

  Future<void> addBankAccount(BankAccount account) async {
    final previousState = state;
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(bankAccountRepositoryProvider);
      final newAccount = await repository.addBankAccount(account);
      
      if (previousState.hasValue) {
        state = AsyncValue.data([...previousState.value!, newAccount]);
      } else {
        state = AsyncValue.data([newAccount]);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteBankAccount(String id) async {
    final previousState = state;
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(bankAccountRepositoryProvider);
      await repository.deleteBankAccount(id);
      
      if (previousState.hasValue) {
        final newList = previousState.value!.where((a) => a.userBankAccountId != id).toList();
        state = AsyncValue.data(newList);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> setDefaultBankAccount(String id) async {
    final previousState = state;
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(bankAccountRepositoryProvider);
      final updated = await repository.setDefaultBankAccount(id);
      
      if (previousState.hasValue) {
        final newList = previousState.value!.map((a) {
          if (a.userBankAccountId == id) {
            return updated;
          }
          return BankAccount(
            userBankAccountId: a.userBankAccountId,
            userId: a.userId,
            accountHolderName: a.accountHolderName,
            bankName: a.bankName,
            accountNumber: a.accountNumber,
            ifscCode: a.ifscCode,
            branchName: a.branchName,
            accountType: a.accountType,
            isVerified: a.isVerified,
            verifiedAt: a.verifiedAt,
            verifiedByAdminId: a.verifiedByAdminId,
            verificationNote: a.verificationNote,
            verificationResponse: a.verificationResponse,
            isDefault: false,
            isActive: a.isActive,
            createdAt: a.createdAt,
            updatedAt: a.updatedAt,
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

final bankAccountsProvider =
    AsyncNotifierProvider<BankAccountsNotifier, List<BankAccount>>(() {
  return BankAccountsNotifier();
});
