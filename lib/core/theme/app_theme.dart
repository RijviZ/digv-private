import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.onLight,
        onPrimary: AppColors.bg,
        secondary: AppColors.textSecondary,
        onSecondary: Colors.white,
        error: Color(0xFFEF4444),
        onError: Colors.white,
        surface: AppColors.bg,
        onSurface: AppColors.onLight,
      ),
      dividerColor: AppColors.inputBorder,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.onDark,
        onPrimary: AppColors.bgDark,
        secondary: AppColors.textSecondary,
        onSecondary: Colors.white,
        error: Color(0xFFEF4444),
        onError: Colors.white,
        surface: AppColors.bgDark,
        onSurface: AppColors.onDark,
      ),
      dividerColor: AppColors.inputBorderDark,
    );
  }
}
