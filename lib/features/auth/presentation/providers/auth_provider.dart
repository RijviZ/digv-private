import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/network/file_upload_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../address/domain/entities/address.dart';
import '../../../address/presentation/providers/address_provider.dart';
import '../../../bank_account/presentation/providers/bank_account_provider.dart';
import '../../../notifications/presentation/providers/notification_settings_provider.dart';

import '../../domain/entities/user_stats.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, void>(() {
  return AuthNotifier();
});

final profileProvider = FutureProvider<User>((ref) async {
  return ref.watch(authRepositoryProvider).getProfile();
});

final locationHistoryProvider = FutureProvider<List<Address>>((ref) async {
  return ref.watch(authRepositoryProvider).getLocationHistory();
});

final userStatsProvider = FutureProvider<UserStats>((ref) async {
  return ref.watch(authRepositoryProvider).getUserStats();
});

final selectedLocationProvider = StateProvider<Address?>((ref) {
  final profile = ref.watch(profileProvider).value;
  return profile?.latestLocation;
});

class AuthNotifier extends AsyncNotifier<void> {
  late final AuthRepository _repository;
  late final FileUploadService _fileService;

  @override
  FutureOr<void> build() {
    _repository = ref.watch(authRepositoryProvider);
    _fileService = ref.watch(fileUploadServiceProvider);
  }

  Future<Map<String, dynamic>> sendOtp({
    required String phoneNumber,
    required String countryCode,
    required String role,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.sendOtp(
        phoneNumber: phoneNumber,
        countryCode: countryCode,
        role: role,
      );
      state = const AsyncValue.data(null);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.verifyOtp(
        phoneNumber: phoneNumber,
        otp: otp,
      );
      state = const AsyncValue.data(null);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<User> getProfile() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.getProfile();
      state = const AsyncValue.data(null);
      return user;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<User> updateProfile(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.updateProfile(data);
      state = const AsyncValue.data(null);
      ref.invalidate(profileProvider);
      return user;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateLocation(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateLocation(data);
      state = const AsyncValue.data(null);
      ref.invalidate(profileProvider);
      ref.invalidate(locationHistoryProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<String> uploadAvatar(String filePath) async {
    state = const AsyncValue.loading();
    try {
      final url = await _fileService.uploadFile(filePath);
      state = const AsyncValue.data(null);
      return url;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _repository.logout();
      state = const AsyncValue.data(null);
      ref.invalidate(profileProvider);
      ref.invalidate(userStatsProvider);
      ref.invalidate(addressListProvider);
      ref.invalidate(bankAccountsProvider);
      ref.invalidate(notificationSettingsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
