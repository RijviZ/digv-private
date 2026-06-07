import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/features/orders/domain/models/order_item.dart';
import 'package:digv/features/orders/presentation/widgets/cancel_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../widgets/booking_detail_item.dart';
import '../widgets/booking_details_card.dart';

class BookingRequestedScreen extends StatelessWidget {
  final OrderItem? order;

  const BookingRequestedScreen({super.key, this.order});

  @override
  Widget build(BuildContext context) {
    final String name = order?.technicianName ?? 'Arjun Kumar';
    final String orderId = order?.orderId ?? 'ORD-8063';
    final String service = order?.serviceName ?? 'Regular Service';
    final String schedule = order?.scheduledTime ?? 'Tomorrow · 10:00 AM';
    final String location = order?.location ?? 'Home — Jl. Ngagelrejo No.34';
    final String price = order?.price ?? '₹199';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/home');
      },
      child: Scaffold(
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
                          child: SizedBox(
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
                        '$name is reviewing your booking request.',
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

                        child: Text(
                          'Order ID: $orderId',
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
                      BookingDetailsCard(
                        items: [
                          BookingDetailItem(
                            icon: 'assets/images/checkmark.svg',
                            iconColor: const Color(0xFF22C55E),
                            label: 'Service',
                            value: service,
                          ),
                          BookingDetailItem(
                            icon: 'assets/images/CalendarBlank.svg',
                            iconColor: const Color(0xFF3B82F6),
                            label: 'Schedule',
                            value: schedule,
                          ),
                          BookingDetailItem(
                            icon: 'assets/images/pin_g.svg',
                            iconColor: const Color(0xFF6B7280),
                            label: 'Address',
                            value: location,
                          ),
                          BookingDetailItem(
                            icon: 'assets/images/card.svg',
                            iconColor: const Color(0xFF6B7280),
                            label: 'Payment',
                            value: order != null
                                ? (order!.price.contains('Postpaid')
                                    ? order!.price
                                    : '${order!.price} · ${order!.paymentMethod ?? 'UPI'} Paid')
                                : '$price · UPI Paid',
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),

              // Bottom buttons matching booking confirmed screen format
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          final dummyOrder = order ?? OrderItem(
                            id: '9091cadf-1a03-48df-a449-ccc15e133939',
                            providerId: 'fce1b6ae-5fb8-45d4-a353-476e1b7cbd76',
                            serviceName: service,
                            orderId: orderId,
                            status: OrderBadgeStatus.active,
                            scheduledTime: schedule,
                            location: location,
                            technicianName: name,
                            price: price,
                          );
                          CancelBottomSheet.show(
                            context,
                            dummyOrder,
                            onCancelSuccess: () {
                              context.push('/orders');
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          elevation: 0,
                        ),
                        child: Text('Cancel Booking', style: AppTextStyles.button),
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
                          'Go to home',
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
      ),
    );
  }
}