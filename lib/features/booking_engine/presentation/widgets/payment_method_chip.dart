import 'package:digv/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class PaymentMethodChip extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const PaymentMethodChip({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.primary : AppColors.dropDownBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  !selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                  BlendMode.srcIn,
                ),
                child: icon,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.captionMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: !selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
