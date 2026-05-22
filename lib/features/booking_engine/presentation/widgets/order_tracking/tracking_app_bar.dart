import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TrackingAppBar extends StatelessWidget {
  final String statusLabel;

  const TrackingAppBar({
    super.key,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: SvgPicture.asset(
              'assets/images/CaretLeft.svg',
              height: 18,
              width: 18,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Order Tracking',
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  'ORD-7845 • $statusLabel',
                  style: AppTextStyles.captionMedium.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
        ],
      ),
    );
  }
}
