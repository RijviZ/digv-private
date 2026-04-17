import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/features/booking_engine/domain/models/order_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TechnicianCard extends StatelessWidget {
  final PaymentType paymentType;
  final VoidCallback onChat;
  final VoidCallback onTogglePayment;

  const TechnicianCard({super.key, required this.paymentType, required this.onChat, required this.onTogglePayment});

  @override
  Widget build(BuildContext context) {
    final isPrepaid = paymentType == PaymentType.prepaid;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder),
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
                  color: const Color(0xFFE5E7EB),
                  border: Border.all(color: const Color(0xFFD1D5DB), width: 1.5),
                ),
                child: const Icon(Icons.person, color: Color(0xFF9CA3AF), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Arjun Kumar',
                      style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        SvgPicture.asset('assets/images/star.svg', height: 13, width: 13),
                        const SizedBox(width: 2),
                        Text(
                          '4.9',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          ' (312)',
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
                    GestureDetector(
                      onTap: onTogglePayment,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isPrepaid ? const Color(0xFFEFF6FF) : const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isPrepaid ? const Color(0xFFBFDBFE) : const Color(0xFFFED7AA),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: isPrepaid ? const Color(0xFF3B82F6) : const Color(0xFFF97316),
                              size: 11,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              isPrepaid ? 'Pre Paid' : 'Post Paid',
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isPrepaid ? const Color(0xFF3B82F6) : const Color(0xFFF97316),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Action icons
              IconAction(icon: 'assets/images/message.svg', fillColor: Colors.white, onTap: onChat, borderColor: AppColors.inputBorder,),
              const SizedBox(width: 8),
              IconAction(icon: 'assets/images/phone.svg', onTap: () {}, fillColor: AppColors.successSecondaryBg),
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
