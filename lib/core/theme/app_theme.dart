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
        error: AppColors.error,
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
        primary: Color(0xFF2563EB),
        onPrimary: Colors.white,
        secondary: Color(0xFF9CA3AF),
        onSecondary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.bgDark,
        onSurface: Colors.white,
      ),
      dividerColor: AppColors.inputBorderDark,
    );
  }
}
