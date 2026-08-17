import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/secure_storage_provider.dart';

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    _loadLocale();
    return const Locale('en');
  }

  Future<void> _loadLocale() async {
    try {
      final storage = ref.read(secureStorageProvider);
      final savedLang = await storage.read(key: 'app_language_code');
      if (savedLang != null && savedLang.isNotEmpty) {
        state = Locale(savedLang.toLowerCase());
      }
    } catch (_) {}
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    try {
      final storage = ref.read(secureStorageProvider);
      await storage.write(key: 'app_language_code', value: locale.languageCode.toLowerCase());
    } catch (_) {}
  }

  void setEnglish() => setLocale(const Locale('en'));
  void setHindi() => setLocale(const Locale('hi'));
  void setBangla() => setLocale(const Locale('bn'));
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(() {
  return LocaleNotifier();
});
