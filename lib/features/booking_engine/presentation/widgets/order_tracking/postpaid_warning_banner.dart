import 'package:digv/I10n/app_localizations.dart';
import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PostpaidWarningBanner extends StatelessWidget {
  final String price;

  const PostpaidWarningBanner({
    super.key,
    this.price = '₹500',
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2215) : AppColors.alertBg,
        border: Border.all(
          color: isDark ? const Color(0xFF5C4624) : AppColors.alertBorder,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'assets/images/Warning.svg',
            colorFilter: ColorFilter.mode(
              isDark ? const Color(0xFFF59E0B) : AppColors.alertText,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.postpaid_order,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFFFBBF24) : AppColors.alertText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.postpaid_banner_desc,
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? const Color(0xFFFCD34D) : AppColors.alertText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
