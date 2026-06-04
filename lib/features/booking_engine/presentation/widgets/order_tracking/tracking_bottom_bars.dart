import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class BottomBarSingle extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool dark;

  const BottomBarSingle({
    super.key,
    required this.label,
    required this.onTap,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme
            .of(context)
            .colorScheme
            .surface,
        border: const Border(top: BorderSide(color: AppColors.dropDownBorder)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: onTap == null
                ? AppColors.dropDownBorder
                : Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.button,
          ),
        ),
      ),
    );
  }
}

class BottomBarDual extends StatelessWidget {
  final String primary;
  final VoidCallback onPrimary;
  final String secondary;
  final VoidCallback? onSecondary;

  const BottomBarDual({
    super.key,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme
            .of(context)
            .colorScheme
            .surface,
        border: const Border(top: BorderSide(color: AppColors.dropDownBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onPrimary,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                primary,
                style: AppTextStyles.button,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onSecondary,
              style: ElevatedButton.styleFrom(
                backgroundColor: onSecondary == null
                    ? AppColors.dropDownBorder
                    : Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                secondary,
                style: AppTextStyles.button,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
