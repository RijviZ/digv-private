class AppSettings {
  final String userId;
  final String userSettingsId;
  final String appLanguage;
  final String themeMode;

  const AppSettings({
    required this.userId,
    required this.userSettingsId,
    required this.appLanguage,
    required this.themeMode,
  });

  AppSettings copyWith({
    String? userId,
    String? userSettingsId,
    String? appLanguage,
    String? themeMode,
  }) {
    return AppSettings(
      userId: userId ?? this.userId,
      userSettingsId: userSettingsId ?? this.userSettingsId,
      appLanguage: appLanguage ?? this.appLanguage,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
