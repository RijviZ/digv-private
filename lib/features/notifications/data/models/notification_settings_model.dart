import '../../domain/entities/notification_settings.dart';

class NotificationSettingsModel extends NotificationSettings {
  const NotificationSettingsModel({
    required super.pushEnabled,
    required super.inAppEnabled,
    required super.mutedTypes,
    required super.settings,
  });

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      pushEnabled: json['pushEnabled'] as bool? ?? true,
      inAppEnabled: json['inAppEnabled'] as bool? ?? true,
      mutedTypes: (json['mutedTypes'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      settings: (json['settings'] as List<dynamic>?)
              ?.map((e) => NotificationSettingItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushEnabled': pushEnabled,
      'inAppEnabled': inAppEnabled,
      'mutedTypes': mutedTypes,
      'settings': settings.map((e) => (e as NotificationSettingItemModel).toJson()).toList(),
    };
  }
}

class NotificationSettingItemModel extends NotificationSettingItem {
  const NotificationSettingItemModel({
    required super.key,
    required super.title,
    required super.description,
    required super.types,
    required super.enabled,
  });

  factory NotificationSettingItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingItemModel(
      key: json['key'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      types: (json['types'] as List<dynamic>).map((e) => e as String).toList(),
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'title': title,
      'description': description,
      'types': types,
      'enabled': enabled,
    };
  }
}
