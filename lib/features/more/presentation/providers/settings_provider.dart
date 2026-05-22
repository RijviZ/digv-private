import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/app_settings.dart';

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(() {
  return SettingsNotifier();
});

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  FutureOr<AppSettings> build() async {
    return _fetchSettings();
  }

  Future<AppSettings> _fetchSettings() async {
    final repository = ref.read(settingsRepositoryProvider);
    return await repository.getSettings();
  }

  Future<void> updateLanguage(String languageCode) async {
    final previousState = state;
    
    // Optimistic update
    if (state.hasValue) {
      state = AsyncValue.data(state.value!.copyWith(appLanguage: languageCode));
    }

    final result = await AsyncValue.guard(() async {
      final repository = ref.read(settingsRepositoryProvider);
      return await repository.updateSettings(appLanguage: languageCode);
    });

    if (result.hasError) {
      state = previousState;
      // You might want to show a snackbar here
    } else {
      state = result;
    }
  }

  Future<void> updateTheme(String themeMode) async {
    final previousState = state;

    // Optimistic update
    if (state.hasValue) {
      state = AsyncValue.data(state.value!.copyWith(themeMode: themeMode));
    }

    final result = await AsyncValue.guard(() async {
      final repository = ref.read(settingsRepositoryProvider);
      return await repository.updateSettings(themeMode: themeMode);
    });

    if (result.hasError) {
      state = previousState;
    } else {
      state = result;
    }
  }
}
