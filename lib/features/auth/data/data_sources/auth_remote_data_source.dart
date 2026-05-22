import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => message;
}

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> sendOtp({
    required String phoneNumber,
    required String countryCode,
    required String role,
  });

  Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String otp,
  });

  Future<Map<String, dynamic>> getProfile();

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data);

  Future<Map<String, dynamic>> updateLocation(Map<String, dynamic> data);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  String _extractErrorMessage(dynamic data, String defaultMessage) {
    if (data is Map<String, dynamic>) {
      if (data.containsKey('message')) {
        final msg = data['message'];
        if (msg is List && msg.isNotEmpty) {
          return msg.first.toString();
        } else if (msg is String) {
          return msg;
        }
      }
      if (data.containsKey('error') && data['error'] is Map<String, dynamic>) {
        final errorObj = data['error'] as Map<String, dynamic>;
        if (errorObj.containsKey('message')) {
           return errorObj['message'].toString();
        }
      }
    }
    return defaultMessage;
  }

  @override
  Future<Map<String, dynamic>> sendOtp({
    required String phoneNumber,
    required String countryCode,
    required String role,
  }) async {
    try {
      final response = await dio.post(
        '/auth/send-otp',
        data: {
          "phoneNumber": phoneNumber,
          "countryCode": countryCode,
          "role": role,
        },
      );
      
      if (response.data['success'] == true) {
        return response.data;
      } else {
        throw ApiException(response.data['message'] ?? 'Failed to send OTP');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
         throw ApiException(_extractErrorMessage(e.response?.data, 'Failed to send OTP'));
      }
      throw ApiException(e.message ?? 'An unknown error occurred');
    }
  }

  @override
  Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final response = await dio.post(
        '/auth/verify-otp',
        data: {
          "phoneNumber": phoneNumber,
          "otp": otp,
        },
      );
      
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw ApiException(response.data['message'] ?? 'Failed to verify OTP');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
         throw ApiException(_extractErrorMessage(e.response?.data, 'Failed to verify OTP'));
      }
      throw ApiException(e.message ?? 'An unknown error occurred');
    }
  }

  @override
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await dio.get('/users');
      
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw ApiException(response.data['message'] ?? 'Failed to fetch profile');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
         throw ApiException(_extractErrorMessage(e.response?.data, 'Failed to fetch profile'));
      }
      throw ApiException(e.message ?? 'An unknown error occurred');
    }
  }

  @override
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await dio.patch(
        '/users/profile',
        data: data,
      );
      
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw ApiException(response.data['message'] ?? 'Failed to update profile');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
         throw ApiException(_extractErrorMessage(e.response?.data, 'Failed to update profile'));
      }
      throw ApiException(e.message ?? 'An unknown error occurred');
    }
  }

  @override
  Future<Map<String, dynamic>> updateLocation(Map<String, dynamic> data) async {
    try {
      final response = await dio.patch(
        '/users/location',
        data: data,
      );
      
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw ApiException(response.data['message'] ?? 'Failed to update location');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
         throw ApiException(_extractErrorMessage(e.response?.data, 'Failed to update location'));
      }
      throw ApiException(e.message ?? 'An unknown error occurred');
    }
  }
}
