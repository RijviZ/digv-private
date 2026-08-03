import 'package:digv/I10n/app_localizations.dart';
import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/features/booking_engine/domain/models/order_status.dart';
import 'package:digv/features/orders/domain/models/order_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TechnicianCard extends StatelessWidget {
  final PaymentType paymentType;
  final OrderItem? order;
  final VoidCallback onChat;
  final VoidCallback? onCall;
  final VoidCallback onTogglePayment;

  const TechnicianCard({
    super.key,
    required this.paymentType,
    this.order,
    required this.onChat,
    this.onCall,
    required this.onTogglePayment,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPrepaid = order != null
        ? !(order!.paymentStatus == 'UNPAID' || order!.price.toLowerCase().contains('postpaid'))
        : paymentType == PaymentType.prepaid;

    final name = order?.technicianName ?? 'Arjun Kumar';
    final imageUrl = order?.technicianImageUrl;
    final rating = order?.rating ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
                  image: imageUrl != null && imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: imageUrl == null || imageUrl.isEmpty
                    ? Icon(Icons.person, color: Theme.of(context).colorScheme.secondary, size: 24)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.h6.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        SvgPicture.asset('assets/images/star.svg', height: 13, width: 13),
                        const SizedBox(width: 2),
                        Text(
                          rating.toStringAsFixed(1),
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          ' (${order?.reviews ?? 312})',
                          style: AppTextStyles.caption.copyWith(color: Theme.of(context).colorScheme.secondary),
                        ),
                        Text(
                          ' · AC & Plumbing',
                          style: AppTextStyles.caption.copyWith(color: Theme.of(context).colorScheme.secondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Payment type badge
                    if(!isPrepaid)Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFFED7AA),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset('assets/images/lock.svg', height: 12, width: 12, colorFilter: const ColorFilter.mode(Color(0xFFC2410C), BlendMode.srcIn)),
                          const SizedBox(width: 3),
                          Text(
                            l10n.postpaid_order,
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFC2410C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Action icons
              IconAction(icon: 'assets/images/message.svg', fillColor: Theme.of(context).colorScheme.surface, onTap: onChat, borderColor: Theme.of(context).dividerColor,),
              const SizedBox(width: 8),
              IconAction(icon: 'assets/images/phone.svg', onTap: onCall ?? () {}, fillColor: AppColors.successSecondaryBg),
            ],
          ),
        ],
      ),
    );
  }
}

class IconAction extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  final Color? fillColor;
  final Color? borderColor;

  const IconAction({super.key, required this.icon, required this.onTap, this.fillColor, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: fillColor ?? const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
          border: borderColor != null ? Border.all(color: borderColor!) : null,
        ),
        child: Padding(padding: const EdgeInsets.all(11.0), child: SvgPicture.asset(icon, height: 18, width: 18)),
      ),
    );
  }
}
