import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SnackBarUtils {
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    String cleanMessage = message
        .replaceFirst('Exception: ', '')
        .replaceFirst('ApiException: ', '')
        .trim();

    if (cleanMessage.isEmpty || cleanMessage == 'E' || cleanMessage.length <= 1) {
      cleanMessage = 'An error occurred. Please try again.';
    }

    final lower = cleanMessage.toLowerCase();
    if (lower.contains('email') &&
        (lower.contains('duplicate') ||
            lower.contains('already exists') ||
            lower.contains('already in use') ||
            lower.contains('already registered') ||
            lower.contains('unique constraint'))) {
      cleanMessage = 'This email is already in use by another account. Please try a different email.';
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          cleanMessage,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.redAccent.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
