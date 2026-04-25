import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PostpaidWarningBanner extends StatelessWidget {
  const PostpaidWarningBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.alertBg,
        border: Border.all(color: AppColors.alertBorder),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset('assets/images/Warning.svg'),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Postpaid Order',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.alertText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Payment of ₹500 will be collected after service completion. Please keep cash or UPI ready.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.alertText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
