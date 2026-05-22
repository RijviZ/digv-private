import 'package:digv/features/notifications/domain/entities/notification_settings.dart';

abstract class NotificationSettingsRepository {
  Future<NotificationSettings> getSettings();
  Future<NotificationSettings> updateSettings(Map<String, dynamic> settings);
}
