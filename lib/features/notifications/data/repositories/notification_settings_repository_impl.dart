import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/notification_settings.dart';
import '../../domain/repositories/notification_settings_repository.dart';
import '../sources/notification_settings_remote_data_source.dart';

final notificationSettingsRepositoryProvider = Provider<NotificationSettingsRepository>((ref) {
  return NotificationSettingsRepositoryImpl(ref.read(notificationSettingsRemoteDataSourceProvider));
});

class NotificationSettingsRepositoryImpl implements NotificationSettingsRepository {
  final NotificationSettingsRemoteDataSource _remoteDataSource;

  NotificationSettingsRepositoryImpl(this._remoteDataSource);

  @override
  Future<NotificationSettings> getSettings() async {
    return await _remoteDataSource.getSettings();
  }

  @override
  Future<NotificationSettings> updateSettings(Map<String, dynamic> settings) async {
    return await _remoteDataSource.updateSettings(settings);
  }
}
