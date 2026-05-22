import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../models/app_settings_model.dart';

final settingsRemoteDataSourceProvider = Provider<SettingsRemoteDataSource>((ref) {
  return SettingsRemoteDataSource(ref.read(dioProvider));
});

class SettingsRemoteDataSource {
  final Dio _dio;

  SettingsRemoteDataSource(this._dio);

  Future<AppSettingsModel> getSettings() async {
    try {
      final response = await _dio.get('/users/settings');
      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return AppSettingsModel.fromJson(data);
      } else {
        throw Exception('Failed to fetch settings');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<AppSettingsModel> updateSettings({String? appLanguage, String? themeMode}) async {
    try {
      final data = <String, dynamic>{};
      if (appLanguage != null) data['appLanguage'] = appLanguage;
      if (themeMode != null) data['themeMode'] = themeMode;

      final response = await _dio.patch('/users/settings', data: data);
      if (response.statusCode == 200) {
        final responseData = response.data['data'] as Map<String, dynamic>;
        return AppSettingsModel.fromJson(responseData);
      } else {
        throw Exception('Failed to update settings');
      }
    } catch (e) {
      rethrow;
    }
  }
}
