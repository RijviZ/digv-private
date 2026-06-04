import '../entities/address.dart';

abstract class AddressRepository {
  Future<List<Address>> getAddresses();
  Future<void> createAddress(Map<String, dynamic> data);
  Future<void> updateAddress(String addressId, Map<String, dynamic> data);
  Future<void> deleteAddress(String addressId);
  Future<void> setDefaultAddress(String addressId);
}
