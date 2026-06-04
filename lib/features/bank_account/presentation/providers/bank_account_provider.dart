import 'package:digv/features/bank_account/data/repositories/bank_account_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/bank_account.dart';

final bankAccountsProvider = FutureProvider<List<BankAccount>>((ref) async {
  final repository = ref.watch(bankAccountRepositoryProvider);
  return repository.getBankAccounts();
});
