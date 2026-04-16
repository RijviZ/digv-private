import 'package:digv/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class PostpaidWarningBanner extends StatelessWidget {
  const PostpaidWarningBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF7ED),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFF97316),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Postpaid Order',
                  style: AppTextStyles.captionMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFC2410C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Payment of ₹500 will be collected after service completion. Please keep cash or UPI ready.',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: const Color(0xFFC2410C),
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
