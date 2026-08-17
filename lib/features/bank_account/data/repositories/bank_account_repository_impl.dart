import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../domain/entities/bank_account.dart';
import '../../domain/repositories/bank_account_repository.dart';
import '../data_sources/bank_account_remote_data_source.dart';
import '../models/bank_account_model.dart';

final bankAccountRemoteDataSourceProvider = Provider<BankAccountRemoteDataSource>((ref) {
  return BankAccountRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

final bankAccountRepositoryProvider = Provider<BankAccountRepository>((ref) {
  return BankAccountRepositoryImpl(
    remoteDataSource: ref.watch(bankAccountRemoteDataSourceProvider),
  );
});

class BankAccountRepositoryImpl implements BankAccountRepository {
  final BankAccountRemoteDataSource remoteDataSource;

  BankAccountRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<BankAccount>> getBankAccounts() async {
    final List<Map<String, dynamic>> data = await remoteDataSource.getBankAccounts();
    return data.map((e) => BankAccountModel.fromJson(e)).toList();
  }

  @override
  Future<BankAccount> addBankAccount(BankAccount account) async {
    final model = account is BankAccountModel ? account : BankAccountModel(
      userBankAccountId: account.userBankAccountId,
      userId: account.userId,
      accountHolderName: account.accountHolderName,
      bankName: account.bankName,
      accountNumber: account.accountNumber,
      ifscCode: account.ifscCode,
      branchName: account.branchName,
      accountType: account.accountType,
      isVerified: account.isVerified,
      verifiedAt: account.verifiedAt,
      verifiedByAdminId: account.verifiedByAdminId,
      verificationNote: account.verificationNote,
      verificationResponse: account.verificationResponse,
      isDefault: account.isDefault,
      isActive: account.isActive,
      createdAt: account.createdAt,
      updatedAt: account.updatedAt,
    );
    final response = await remoteDataSource.addBankAccount(model.toJson());
    return BankAccountModel.fromJson(response);
  }

  @override
  Future<void> deleteBankAccount(String id) async {
    await remoteDataSource.deleteBankAccount(id);
  }

  @override
  Future<BankAccount> setDefaultBankAccount(String id) async {
    final response = await remoteDataSource.setDefaultBankAccount(id);
    return BankAccountModel.fromJson(response);
  }
}
