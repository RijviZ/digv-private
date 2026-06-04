import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../models/notification_settings_model.dart';

final notificationSettingsRemoteDataSourceProvider = Provider<NotificationSettingsRemoteDataSource>((ref) {
  return NotificationSettingsRemoteDataSource(ref.read(dioProvider));
});

class NotificationSettingsRemoteDataSource {
  final Dio _dio;

  NotificationSettingsRemoteDataSource(this._dio);

  Future<NotificationSettingsModel> getSettings() async {
    try {
      final response = await _dio.get('/notifications/settings');
      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return NotificationSettingsModel.fromJson(data);
      } else {
        throw Exception('Failed to fetch notification settings');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<NotificationSettingsModel> updateSettings(Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch('/notifications/preferences', data: data);
      if (response.statusCode == 200) {
        final responseData = response.data['data'] as Map<String, dynamic>;
        return NotificationSettingsModel.fromJson(responseData);
      } else {
        throw Exception('Failed to update notification settings');
      }
    } catch (e) {
      rethrow;
    }
  }
}
