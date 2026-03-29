import 'package:digv/core/router/app_router.dart';
import 'package:digv/I10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:digv/features/profile_settings/presentation/providers/theme_provider.dart';
import 'package:digv/features/profile_settings/presentation/providers/locale_provider.dart';
import 'package:digv/core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: DigV()));
}

class DigV extends ConsumerWidget {
  const DigV({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'DigV',
      debugShowCheckedModeBanner: false,
      
      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: locale,
      routerConfig: appRouter,
      supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
      // Localization (Placeholder - assuming routerConfig is handled elsewhere or needed)
      // routerConfig: ... 
    );
  }
}
