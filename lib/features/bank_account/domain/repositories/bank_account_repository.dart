import '../entities/bank_account.dart';

abstract class BankAccountRepository {
  Future<List<BankAccount>> getBankAccounts();
}
