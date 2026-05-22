import 'package:digv/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class StatsBar extends StatelessWidget {
  final String bookings;
  final String avgRating;
  final String spent;

  const StatsBar({
    super.key,
    this.bookings = '4',
    this.avgRating = '4.9',
    this.spent = '₹997',
  });

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
            _StatCell(value: bookings, label: 'Bookings'),
            VerticalDivider(width: 1, color: theme.dividerColor),
            _StatCell(value: avgRating, label: 'Avg Rating'),
            VerticalDivider(width: 1, color: theme.dividerColor),
            _StatCell(value: spent, label: 'Spent'),
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
