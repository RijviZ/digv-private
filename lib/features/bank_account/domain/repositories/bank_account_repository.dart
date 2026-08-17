import '../entities/bank_account.dart';

abstract class BankAccountRepository {
  Future<List<BankAccount>> getBankAccounts();
  Future<BankAccount> addBankAccount(BankAccount account);
  Future<void> deleteBankAccount(String id);
  Future<BankAccount> setDefaultBankAccount(String id);
}
