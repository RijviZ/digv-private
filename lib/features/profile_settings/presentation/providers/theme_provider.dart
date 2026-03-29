import 'package:flutter_riverpod/legacy.dart';

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false);

  void toggle() {
    state = !state;
  }

  void setDarkMode(bool isDark) {
    state = isDark;
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>(
  (ref) => ThemeNotifier(),
);
