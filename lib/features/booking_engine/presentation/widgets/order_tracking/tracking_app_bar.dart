import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/I10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TrackingAppBar extends StatelessWidget {
  final String statusLabel;
  final String orderId;

  const TrackingAppBar({
    super.key,
    required this.statusLabel,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.primary,
                BlendMode.srcIn,
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  l10n.order_tracking,
                  style: AppTextStyles.title.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  '$orderId • $statusLabel',
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
