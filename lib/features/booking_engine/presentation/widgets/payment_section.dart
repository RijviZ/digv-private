import 'package:digv/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class PaymentSection extends StatelessWidget {
  final bool isActive;
  final String headerLabel;
  final String headerSub;
  final Widget child;

  const PaymentSection({
    super.key,
    required this.isActive,
    required this.headerLabel,
    required this.headerSub,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.inputBgSecondary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headerLabel,
                      style:  AppTextStyles.captionSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: Theme.of(context).colorScheme.primary
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(headerSub, style:  AppTextStyles.caption.copyWith( color: Theme.of(context).colorScheme.secondary)),
                  ],
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}
