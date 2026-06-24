
import '../../../address/domain/entities/address.dart';
import '../entities/user.dart';
import '../entities/user_stats.dart';

abstract class AuthRepository {
  Future<Map<String, dynamic>> sendOtp({
    required String phoneNumber,
    required String countryCode,
    required String userType,
  });

  Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String otp,
    String? deviceToken,
    String? platform,
    String? appVersion,
  });

  Future<User> getProfile();

  Future<User> updateProfile(Map<String, dynamic> data);

  Future<void> updateLocation(Map<String, dynamic> data);
  Future<List<Address>> getLocationHistory();
  Future<UserStats> getUserStats();
  Future<void> logout();
}
