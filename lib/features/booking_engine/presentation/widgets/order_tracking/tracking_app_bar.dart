import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/I10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TrackingAppBar extends StatelessWidget {
  final String statusLabel;
  final String orderId;
  final VoidCallback? onDispute;
  final VoidCallback? onSupport;

  const TrackingAppBar({
    super.key,
    required this.statusLabel,
    required this.orderId,
    this.onDispute,
    this.onSupport,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasMenu = onDispute != null || onSupport != null;

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
          if (hasMenu)
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                size: 22,
                color: Theme.of(context).colorScheme.primary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (val) {
                if (val == 'dispute') onDispute?.call();
                if (val == 'support') onSupport?.call();
              },
              itemBuilder: (context) => [
                if (onDispute != null)
                  PopupMenuItem(
                    value: 'dispute',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.gavel_outlined,
                          size: 18,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Raise Dispute',
                          style: AppTextStyles.captionMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (onSupport != null)
                  PopupMenuItem(
                    value: 'support',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.headset_mic_outlined,
                          size: 18,
                          color: AppColors.blue,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Contact Support',
                          style: AppTextStyles.captionMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            )
          else
            const SizedBox(width: 18),
        ],
      ),
    );
  }
}
