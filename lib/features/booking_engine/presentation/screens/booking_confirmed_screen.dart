import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/features/booking_engine/domain/models/order_status.dart';
import 'package:digv/I10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../widgets/booking_detail_item.dart';
import '../widgets/booking_details_card.dart';

class BookingConfirmedScreen extends StatelessWidget {
  final PaymentType paymentType;

  const BookingConfirmedScreen({super.key, required this.paymentType});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Center(child: SvgPicture.asset('assets/images/CheckCircleG.svg', width: 32, height: 32)),
                    ),

                    const SizedBox(height: 16),

                    // Title
                    Text(
                      l10n.booking_confirmed,
                      style: AppTextStyles.h3.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: 0,
                        height: 1.75,
                      ),
                    ),
                    Text(
                      'Arjun Kumar will arrive at the scheduled time.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: 0,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Order ID badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? AppColors.inputBgSecondaryDark : Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Text(
                        'Order ID: ORD-8063',
                        style: AppTextStyles.captionMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Status indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: AppColors.blue, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Technician Confirmed • On the way',
                          style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.secondary),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Details card
                    BookingDetailsCard(
                      items: [
                        BookingDetailItem(
                          icon: 'assets/images/checkmark.svg',
                          iconColor: const Color(0xFF22C55E),
                          label: l10n.service,
                          value: l10n.regular_service,
                        ),
                        BookingDetailItem(
                          icon: 'assets/images/CalendarBlank.svg',
                          iconColor: const Color(0xFF3B82F6),
                          label: l10n.schedule,
                          value: 'Tomorrow · 10:00 AM',
                        ),
                        BookingDetailItem(
                          icon: 'assets/images/pin_g.svg',
                          iconColor: const Color(0xFF6B7280),
                          label: l10n.address,
                          value: 'Home — Jl. Ngagelrejo No.34',
                        ),
                        BookingDetailItem(
                          icon: 'assets/images/card.svg',
                          iconColor: const Color(0xFF6B7280),
                          label: l10n.payment,
                          value: paymentType == PaymentType.prepaid
                              ? '₹199 · ${l10n.upi_paid}'
                              : '₹199 · ${l10n.pay_after_service}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/order_tracking', extra: paymentType);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        elevation: 0,
                      ),
                      child: Text(l10n.track_your_order, style: AppTextStyles.button),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => context.push('/home'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                        side: BorderSide(color: Theme.of(context).dividerColor),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n.go_to_home,
                        style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
