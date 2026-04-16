import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/core/widgets/app_primary_button.dart';
import 'package:digv/features/booking_engine/domain/models/order_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../widgets/booking_detail_item.dart';
import '../widgets/booking_details_card.dart';

class BookingRequestedScreen extends StatelessWidget {
  const BookingRequestedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon circle
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.dropDownBorder),
                      ),
                      child: Center(
                        child: Container(
                          width: 32,
                          height: 32,
                          
                          child: SvgPicture.asset(
                            'assets/images/ClockRed.svg',
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Title 
                     Text(
                      'Booking Requested!',
                      style: AppTextStyles.h3.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: 0,
                        height: 1.75,
                      ),
                    ),
                     Text(
                      'Arjun Kumar is reviewing your booking request.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: 0,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.inputBorder)),

                      child:  Text(
                        'Order ID: ORD-8063',
                        style: AppTextStyles.captionMedium.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Details card
                    const BookingDetailsCard(
                      items: [
                        BookingDetailItem(
                          icon: 'assets/images/checkmark.svg',
                          iconColor: Color(0xFF22C55E),
                          label: 'Service',
                          value: 'Regular Service',
                        ),
                        BookingDetailItem(
                          icon: 'assets/images/CalendarBlank.svg',
                          iconColor: Color(0xFF3B82F6),
                          label: 'Schedule',
                          value: 'Tomorrow · 10:00 AM',
                        ),
                        BookingDetailItem(
                          icon: 'assets/images/pin_g.svg',
                          iconColor: Color(0xFF6B7280),
                          label: 'Address',
                          value: 'Home — Jl. Ngagelrejo No.34',
                        ),
                        BookingDetailItem(
                          icon: 'assets/images/card.svg',
                          iconColor: Color(0xFF6B7280),
                          label: 'Payment',
                          value: '₹199 · UPI Paid',
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AppPrimaryButton(
                  text: 'Cancel Booking',
                  onTap: () {
                    context.push('/booking_confirmed', extra: PaymentType.prepaid);
                  },
                ),
            ),
          ],
        ),
      ),
    );
  }
}