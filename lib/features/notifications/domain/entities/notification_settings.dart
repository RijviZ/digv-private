class NotificationSettings {
  final bool pushEnabled;
  final bool inAppEnabled;
  final List<String> mutedTypes;
  final List<NotificationSettingItem> settings;

  const NotificationSettings({
    required this.pushEnabled,
    required this.inAppEnabled,
    required this.mutedTypes,
    required this.settings,
  });

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? inAppEnabled,
    List<String>? mutedTypes,
    List<NotificationSettingItem>? settings,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      inAppEnabled: inAppEnabled ?? this.inAppEnabled,
      mutedTypes: mutedTypes ?? this.mutedTypes,
      settings: settings ?? this.settings,
    );
  }
}

class NotificationSettingItem {
  final String key;
  final String title;
  final String description;
  final List<String> types;
  final bool enabled;

  const NotificationSettingItem({
    required this.key,
    required this.title,
    required this.description,
    required this.types,
    required this.enabled,
  });

  NotificationSettingItem copyWith({
    String? key,
    String? title,
    String? description,
    List<String>? types,
    bool? enabled,
  }) {
    return NotificationSettingItem(
      key: key ?? this.key,
      title: title ?? this.title,
      description: description ?? this.description,
      types: types ?? this.types,
      enabled: enabled ?? this.enabled,
    );
  }
}
