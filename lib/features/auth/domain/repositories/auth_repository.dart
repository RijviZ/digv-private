
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Map<String, dynamic>> sendOtp({
    required String phoneNumber,
    required String countryCode,
    required String role,
  });

  Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String otp,
  });

  Future<User> getProfile();

  Future<User> updateProfile(Map<String, dynamic> data);

  Future<void> updateLocation(Map<String, dynamic> data);
}
