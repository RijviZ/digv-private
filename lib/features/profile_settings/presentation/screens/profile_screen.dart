import 'package:digv/core/theme/app_theme.dart';
import 'package:digv/features/profile_settings/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final isDarkMode = theme == AppTheme.darkTheme;
    return Scaffold();
  }
}
