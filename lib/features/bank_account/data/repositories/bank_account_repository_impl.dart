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
}
