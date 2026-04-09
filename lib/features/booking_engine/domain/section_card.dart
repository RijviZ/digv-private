import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SectionCard extends StatelessWidget {
  final String label;
  final Widget child;
  final Color? bg;
  final bool? titleBorder;
  final Color? titleColor;
  final EdgeInsetsGeometry? titlePadding;
  final double? childTopPadding;

  const SectionCard({
    super.key,
    required this.label,
    required this.child,
    this.bg,
    this.titleBorder,
    this.titleColor,
    this.titlePadding,
    this.childTopPadding
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bg ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: titlePadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.inputBgSecondary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              border: titleBorder == null ? Border(bottom: BorderSide(color: AppColors.inputBorder)) : null,
            ),
            child: Text(
              label,
              style: AppTextStyles.captionSmall.copyWith(
                color: titleColor?? Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ),

          // Content
          Padding(padding: EdgeInsets.fromLTRB(16, childTopPadding??16, 16, 16), child: child),
        ],
      ),
    );
  }
}
