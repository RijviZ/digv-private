import 'package:digv/core/network/dio_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';
import '../models/address_model.dart';

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepositoryImpl(dio: ref.watch(dioProvider));
});

class AddressRepositoryImpl implements AddressRepository {
  final Dio dio;

  AddressRepositoryImpl({required this.dio});

  @override
  Future<List<Address>> getAddresses() async {
    try {
      final response = await dio.get('/users/addresses');
      final data = response.data['data'] as List;
      return data.map((e) => AddressModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> createAddress(Map<String, dynamic> data) async {
    try {
      await dio.post('/users/addresses', data: data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateAddress(String addressId, Map<String, dynamic> data) async {
    try {
      await dio.patch('/users/addresses/$addressId', data: data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    try {
      await dio.delete('/users/addresses/$addressId');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> setDefaultAddress(String addressId) async {
    try {
      await dio.patch('/users/addresses/$addressId/default');
    } catch (e) {
      rethrow;
    }
  }
}
