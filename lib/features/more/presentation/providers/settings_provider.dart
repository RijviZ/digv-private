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
    final isDark = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    try {
      final repository = ref.read(settingsRepositoryProvider);
      final remoteSettings = await repository.getSettings();
      return remoteSettings;
    } catch (_) {
      return AppSettings(
        userId: '',
        userSettingsId: 'local_settings',
        appLanguage: locale.languageCode.toUpperCase(),
        themeMode: isDark ? 'DARK' : 'LIGHT',
      );
    }
  }

  Future<void> updateLanguage(String languageCode) async {
    final code = languageCode.toLowerCase();
    await ref.read(localeProvider.notifier).setLocale(Locale(code));

    if (state.hasValue) {
      state = AsyncValue.data(state.value!.copyWith(appLanguage: languageCode.toUpperCase()));
    } else {
      state = AsyncValue.data(AppSettings(
        userId: '',
        userSettingsId: 'local_settings',
        appLanguage: languageCode.toUpperCase(),
        themeMode: ref.read(themeProvider) ? 'DARK' : 'LIGHT',
      ));
    }

    try {
      final repository = ref.read(settingsRepositoryProvider);
      await repository.updateSettings(appLanguage: languageCode.toUpperCase());
    } catch (_) {}
  }

  Future<void> updateTheme(String themeMode) async {
    final isDark = themeMode.toUpperCase() == 'DARK';
    await ref.read(themeProvider.notifier).setDarkMode(isDark);

    if (state.hasValue) {
      state = AsyncValue.data(state.value!.copyWith(themeMode: themeMode.toUpperCase()));
    } else {
      state = AsyncValue.data(AppSettings(
        userId: '',
        userSettingsId: 'local_settings',
        appLanguage: ref.read(localeProvider).languageCode.toUpperCase(),
        themeMode: themeMode.toUpperCase(),
      ));
    }

    try {
      final repository = ref.read(settingsRepositoryProvider);
      await repository.updateSettings(themeMode: themeMode.toUpperCase());
    } catch (_) {}
  }
}
