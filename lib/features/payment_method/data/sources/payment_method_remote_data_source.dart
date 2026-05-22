import 'package:dio/dio.dart';
import '../models/payment_method_model.dart';

abstract class PaymentMethodRemoteDataSource {
  Future<PaymentMethodModel> addPaymentMethod(PaymentMethodModel paymentMethod);
  Future<List<PaymentMethodModel>> getPaymentMethods();
  Future<PaymentMethodModel> updatePaymentMethod(String id, PaymentMethodModel paymentMethod);
  Future<void> deletePaymentMethod(String id);
  Future<PaymentMethodModel> setDefaultPaymentMethod(String id);
}

class PaymentMethodRemoteDataSourceImpl implements PaymentMethodRemoteDataSource {
  final Dio dio;

  PaymentMethodRemoteDataSourceImpl({required this.dio});

  @override
  Future<PaymentMethodModel> addPaymentMethod(PaymentMethodModel paymentMethod) async {
    final response = await dio.post(
      '/users/payment-methods',
      data: paymentMethod.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return PaymentMethodModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to add payment method');
    }
  }

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final response = await dio.get('/users/payment-methods');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => PaymentMethodModel.fromJson(json)).toList();
    } else {
      throw Exception(response.data['message'] ?? 'Failed to get payment methods');
    }
  }

  @override
  Future<PaymentMethodModel> updatePaymentMethod(String id, PaymentMethodModel paymentMethod) async {
    final response = await dio.patch(
      '/users/payment-methods/$id',
      data: paymentMethod.toJson(),
    );

    if (response.statusCode == 200) {
      return PaymentMethodModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to update payment method');
    }
  }

  @override
  Future<void> deletePaymentMethod(String id) async {
    final response = await dio.delete('/users/payment-methods/$id');

    if (response.statusCode != 200) {
      throw Exception(response.data['message'] ?? 'Failed to delete payment method');
    }
  }

  @override
  Future<PaymentMethodModel> setDefaultPaymentMethod(String id) async {
    final response = await dio.patch('/users/payment-methods/$id/default');

    if (response.statusCode == 200) {
      return PaymentMethodModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to set default payment method');
    }
  }
}
