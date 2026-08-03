import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:digv/features/profile_settings/presentation/providers/locale_provider.dart';
import 'package:digv/features/profile_settings/presentation/providers/theme_provider.dart';

import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/app_settings.dart';

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(() {
  return SettingsNotifier();
});

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  FutureOr<AppSettings> build() async {
    final settings = await _fetchSettings();
    _syncGlobalState(settings);
    return settings;
  }

  Future<AppSettings> _fetchSettings() async {
    final repository = ref.read(settingsRepositoryProvider);
    return await repository.getSettings();
  }

  void _syncGlobalState(AppSettings settings) {
    ref.read(localeProvider.notifier).setLocale(Locale(settings.appLanguage.toLowerCase()));
    ref.read(themeProvider.notifier).setDarkMode(settings.themeMode == 'DARK');
  }

  Future<void> updateLanguage(String languageCode) async {
    final previousState = state;
    
    // Optimistic update
    ref.read(localeProvider.notifier).setLocale(Locale(languageCode.toLowerCase()));
    if (state.hasValue) {
      state = AsyncValue.data(state.value!.copyWith(appLanguage: languageCode));
    }

    final result = await AsyncValue.guard(() async {
      final repository = ref.read(settingsRepositoryProvider);
      return await repository.updateSettings(appLanguage: languageCode);
    });

    if (result.hasError) {
      state = previousState;
      if (previousState.hasValue) {
        ref.read(localeProvider.notifier).setLocale(Locale(previousState.value!.appLanguage.toLowerCase()));
      }
    } else {
      state = result;
      if (result.hasValue) {
        _syncGlobalState(result.value!);
      }
    }
  }

  Future<void> updateTheme(String themeMode) async {
    final previousState = state;

    // Optimistic update
    ref.read(themeProvider.notifier).setDarkMode(themeMode == 'DARK');
    if (state.hasValue) {
      state = AsyncValue.data(state.value!.copyWith(themeMode: themeMode));
    }

    final result = await AsyncValue.guard(() async {
      final repository = ref.read(settingsRepositoryProvider);
      return await repository.updateSettings(themeMode: themeMode);
    });

    if (result.hasError) {
      state = previousState;
      if (previousState.hasValue) {
        ref.read(themeProvider.notifier).setDarkMode(previousState.value!.themeMode == 'DARK');
      }
    } else {
      state = result;
      if (result.hasValue) {
        _syncGlobalState(result.value!);
      }
    }
  }
}
