import '../../domain/entities/app_settings.dart';

class AppSettingsModel extends AppSettings {
  const AppSettingsModel({
    required super.userId,
    required super.userSettingsId,
    required super.appLanguage,
    required super.themeMode,
  });

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      userId: json['userId'] as String,
      userSettingsId: json['userSettingsId'] as String,
      appLanguage: json['appLanguage'] as String,
      themeMode: json['themeMode'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userSettingsId': userSettingsId,
      'appLanguage': appLanguage,
      'themeMode': themeMode,
    };
  }
}
