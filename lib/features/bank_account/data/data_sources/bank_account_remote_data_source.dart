import 'package:dio/dio.dart';

abstract class BankAccountRemoteDataSource {
  Future<List<Map<String, dynamic>>> getBankAccounts();
}

class BankAccountRemoteDataSourceImpl implements BankAccountRemoteDataSource {
  final Dio dio;

  BankAccountRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Map<String, dynamic>>> getBankAccounts() async {
    try {
      final response = await dio.get('/users/bank-accounts');
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw ApiException(response.data['message'] ?? 'Failed to fetch bank accounts');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          throw ApiException(data['message'].toString());
        }
      }
      throw ApiException(e.message ?? 'An unknown error occurred');
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => message;
}
