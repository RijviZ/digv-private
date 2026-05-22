import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/network/dio_provider.dart';
import '../../../../core/storage/secure_storage_provider.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';
import '../models/user_model.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  @override
  Future<Map<String, dynamic>> sendOtp({
    required String phoneNumber,
    required String countryCode,
    required String role,
  }) async {
    final response = await remoteDataSource.sendOtp(
      phoneNumber: phoneNumber,
      countryCode: countryCode,
      role: role,
    );
    return {
      'message': response['message'],
      'nextStep': response['data']['nextStep'],
    };
  }

  @override
  Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    final data = await remoteDataSource.verifyOtp(
      phoneNumber: phoneNumber,
      otp: otp,
    );

    final String accessToken = data['accessToken'] as String;
    final userModel = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    final String nextStep = data['nextStep'] as String;

    // Save token
    await secureStorage.write(key: 'accessToken', value: accessToken);

    return {
      'user': userModel,
      'nextStep': nextStep,
    };
  }

  @override
  Future<User> getProfile() async {
    final data = await remoteDataSource.getProfile();
    return UserModel.fromJson(data);
  }

  @override
  Future<User> updateProfile(Map<String, dynamic> updateData) async {
    final data = await remoteDataSource.updateProfile(updateData);
    return UserModel.fromJson(data);
  }

  @override
  Future<void> updateLocation(Map<String, dynamic> data) async {
    await remoteDataSource.updateLocation(data);
  }

  @override
  Future<void> logout() async {
    await secureStorage.delete(key: 'accessToken');
  }
}
