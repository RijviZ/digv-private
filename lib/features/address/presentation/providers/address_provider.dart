import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/address_repository_impl.dart';
import '../../domain/entities/address.dart';

final addressListProvider = AsyncNotifierProvider<AddressNotifier, List<Address>>(() {
  return AddressNotifier();
});

class AddressNotifier extends AsyncNotifier<List<Address>> {
  @override
  FutureOr<List<Address>> build() async {
    final repository = ref.watch(addressRepositoryProvider);
    return repository.getAddresses();
  }

  Future<void> addAddress(Map<String, dynamic> data) async {
    final repository = ref.read(addressRepositoryProvider);
    await repository.createAddress(data);
    ref.invalidateSelf();
  }

  Future<void> updateAddress(String addressId, Map<String, dynamic> data) async {
    final repository = ref.read(addressRepositoryProvider);
    await repository.updateAddress(addressId, data);
    ref.invalidateSelf();
  }

  Future<void> deleteAddress(String addressId) async {
    final repository = ref.read(addressRepositoryProvider);
    await repository.deleteAddress(addressId);
    ref.invalidateSelf();
  }

  Future<void> setDefaultAddress(String addressId) async {
    final repository = ref.read(addressRepositoryProvider);
    await repository.setDefaultAddress(addressId);
    ref.invalidateSelf();
  }
}
