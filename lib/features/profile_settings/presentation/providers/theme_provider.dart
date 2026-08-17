import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/secure_storage_provider.dart';

class ThemeNotifier extends Notifier<bool> {
  @override
  bool build() {
    _loadTheme();
    return false;
  }

  Future<void> _loadTheme() async {
    try {
      final storage = ref.read(secureStorageProvider);
      final savedTheme = await storage.read(key: 'app_theme_mode');
      if (savedTheme != null) {
        state = savedTheme == 'DARK';
      }
    } catch (_) {}
  }

  Future<void> setDarkMode(bool isDark) async {
    state = isDark;
    try {
      final storage = ref.read(secureStorageProvider);
      await storage.write(key: 'app_theme_mode', value: isDark ? 'DARK' : 'LIGHT');
    } catch (_) {}
  }

  Future<void> toggle() async {
    await setDarkMode(!state);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, bool>(() {
  return ThemeNotifier();
});
