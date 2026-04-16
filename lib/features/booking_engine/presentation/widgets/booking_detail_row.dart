import 'package:digv/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'booking_detail_item.dart';

class BookingDetailRow extends StatelessWidget {
  final BookingDetailItem item;

  const BookingDetailRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(item.icon, height: 14, width: 14, colorFilter: ColorFilter.mode(item.iconColor, BlendMode.srcIn),),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.label,
              style: AppTextStyles.labelMedium.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            Text(
              item.value,
              style: AppTextStyles.h6.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
