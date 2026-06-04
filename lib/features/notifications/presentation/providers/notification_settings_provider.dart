import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/notification_settings.dart';
import '../../data/repositories/notification_settings_repository_impl.dart';

final notificationSettingsProvider = AsyncNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(() {
  return NotificationSettingsNotifier();
});

class NotificationSettingsNotifier extends AsyncNotifier<NotificationSettings> {
  @override
  FutureOr<NotificationSettings> build() async {
    return _fetchSettings();
  }

  Future<NotificationSettings> _fetchSettings() async {
    final repository = ref.read(notificationSettingsRepositoryProvider);
    return await repository.getSettings();
  }

  Future<void> togglePush(bool enabled) async {
    final previousState = state;
    if (state.hasValue) {
      final current = state.value!;
      state = AsyncValue.data(current.copyWith(pushEnabled: enabled));

      final result = await AsyncValue.guard(() async {
        final repository = ref.read(notificationSettingsRepositoryProvider);
        return await repository.updateSettings({
          'pushEnabled': enabled,
          'inAppEnabled': current.inAppEnabled,
          'mutedTypes': current.mutedTypes,
        });
      });

      if (result.hasError) {
        state = previousState;
      } else {
        // Since /notifications/preferences doesn't return 'settings' list, 
        // we merge the result with our current 'settings' list.
        if (result.hasValue) {
          state = AsyncValue.data(result.value!.copyWith(settings: current.settings));
        }
      }
    }
  }

  Future<void> toggleSettingItem(String key, bool enabled) async {
    final previousState = state;
    if (state.hasValue) {
      final current = state.value!;
      
      // Update local settings list
      final updatedSettings = current.settings.map((item) {
        if (item.key == key) {
          return item.copyWith(enabled: enabled);
        }
        return item;
      }).toList();

      // Calculate mutedTypes
      // A type is muted if its corresponding setting is disabled.
      final newMutedTypes = <String>{};
      for (final item in updatedSettings) {
        if (!item.enabled) {
          newMutedTypes.addAll(item.types);
        }
      }

      final newState = current.copyWith(
        settings: updatedSettings,
        mutedTypes: newMutedTypes.toList(),
      );
      state = AsyncValue.data(newState);

      final result = await AsyncValue.guard(() async {
        final repository = ref.read(notificationSettingsRepositoryProvider);
        return await repository.updateSettings({
          'pushEnabled': newState.pushEnabled,
          'inAppEnabled': newState.inAppEnabled,
          'mutedTypes': newState.mutedTypes,
        });
      });

      if (result.hasError) {
        state = previousState;
      } else {
        if (result.hasValue) {
          // Merge to keep settings list (titles, descriptions)
          state = AsyncValue.data(result.value!.copyWith(settings: updatedSettings));
        }
      }
    }
  }
}
