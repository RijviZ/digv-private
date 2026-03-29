import 'package:flutter/material.dart';

import 'package:flutter_riverpod/legacy.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en'));

  void setLocale(Locale locale) {
    state = locale;
  }

  void setEnglish() => state = const Locale('en');

  void setHindi() => state = const Locale('hi');

  void setBangla() => state = const Locale('bn');
}
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(),
);
