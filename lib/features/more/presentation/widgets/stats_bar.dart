import 'package:digv/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class StatsBar extends StatelessWidget {
  const StatsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            const _StatCell(value: '4', label: 'Bookings'),
            VerticalDivider(width: 1, color: theme.dividerColor),
            const _StatCell(value: '4.9', label: 'Avg Rating'),
            VerticalDivider(width: 1, color: theme.dividerColor),
            const _StatCell(value: '₹997', label: 'Spent'),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: AppTextStyles.title.copyWith(
                color: theme.colorScheme.primary,
                fontFamily: AppTextStyles.fontFamilyPoppins,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.captionSmall.copyWith(
                color: theme.colorScheme.secondary,
                fontFamily: AppTextStyles.fontFamilyPoppins,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
