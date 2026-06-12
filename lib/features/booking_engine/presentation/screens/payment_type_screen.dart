import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:digv/features/booking_engine/presentation/providers/booking_provider.dart';
import 'package:digv/features/search/domain/entities/search_result.dart';
import 'package:digv/features/booking_engine/domain/technician.dart';
import 'package:digv/features/booking_engine/domain/date_item.dart';
import 'package:digv/features/address/domain/entities/address.dart';
import 'package:digv/features/orders/domain/models/order_item.dart';

import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../domain/payment_type.dart';
import '../widgets/payment_method_chip.dart';
import '../widgets/payment_section.dart';

class PaymentTypeScreen extends ConsumerStatefulWidget {
  final int amount;
  final int quantity;
  final int serviceCharge;
  final int fee;
  final Map<String, dynamic> bookingDetails;

  const PaymentTypeScreen({
    super.key,
    required this.amount,
    required this.quantity,
    required this.serviceCharge,
    required this.fee,
    required this.bookingDetails,
  });

  @override
  ConsumerState<PaymentTypeScreen> createState() => _PaymentTypeScreenState();
}

class _PaymentTypeScreenState extends ConsumerState<PaymentTypeScreen> {
  PaymentMode _mode = PaymentMode.prepaid;
  PrepaidMethod _prepaidMethod = PrepaidMethod.upi;
  PostpaidMethod _postpaidMethod = PostpaidMethod.card;

  bool _isBooking = false;

  String _formatScheduledDate(DateItem dateItem) {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final monthIdx = months.indexOf(dateItem.month) + 1;
    final year = now.year;
    final mm = monthIdx.toString().padLeft(2, '0');
    final dd = dateItem.date.toString().padLeft(2, '0');
    return '$year-$mm-$dd';
  }

  void _onConfirmPostpaid(Map<String, dynamic> updatedDetails) async {
    setState(() => _isBooking = true);
    try {
      final service = updatedDetails['service'] as SearchServiceEntity?;
      final technician = updatedDetails['technician'] as Technician?;
      final date = updatedDetails['date'] as DateItem?;
      final address = updatedDetails['address'] as Address?;
      final timeStr = updatedDetails['time'] as String? ?? '';
      
      final scheduledDateStr = date != null ? _formatScheduledDate(date) : '2026-05-10';
      
      final timeParts = timeStr.split('|');
      final slotId = timeParts.length > 1 ? timeParts[1] : '11111111-1111-4111-8111-111111111111';
      
      final baseAmount = updatedDetails['amount'] as int? ?? 0;
      final quantity = updatedDetails['quantity'] as int? ?? 1;
      final realAmount = baseAmount * quantity;

      final payload = {
        'providerId': technician?.providerId ?? '2f4a8f15-3c10-4d1a-9821-111111111111',
        'providerServiceId': technician?.providerServiceId ?? service?.serviceId ?? '7a8b9c10-1111-4d1a-9821-222222222222',
        'scheduledDate': scheduledDateStr,
        'availabilitySlotIds': [
          slotId
        ],
        'quantity': quantity,
        'description': 'Need service booking for ${service?.title ?? "Regular Service"}.',
        'paymentMethod': updatedDetails['paymentMethod'] as String? ?? 'CASH',
        'collectionType': updatedDetails['collectionType'] as String? ?? 'POSTPAID',
        'gatewayReference': 'MANUAL-REF-001',
        'paymentAmount': realAmount.toDouble().toStringAsFixed(2),
        'addressLabel': address?.label ?? 'Home',
        'addressLine': address?.addressLine ?? 'House 12, Road 5, Dhanmondi',
        'city': address?.city ?? 'Dhaka',
        'state': address?.state ?? 'Dhaka',
        'postalCode': address?.postalCode ?? '1209',
        'serviceLat': address?.lat ?? 23.7465,
        'serviceLng': address?.lng ?? 90.376
      };

      // Make the service request POST call
      final bookingRes = await ref.read(createBookingProvider.notifier).createBooking(payload);

      if (mounted) {
        final createdId = bookingRes['serviceRequestId'] as String? ?? bookingRes['data']?['serviceRequestId'] as String? ?? '';
        
        final scheduledTime = date != null ? '${date.date} ${date.month} · ${timeStr.split('|')[0]}' : 'Tomorrow · 10:00 AM';
        final locationStr = address != null ? '${address.label ?? 'Home'} — ${address.addressLine}' : 'Home';
        final priceStr = '₹${widget.amount}';

        final orderItem = OrderItem(
          id: createdId,
          providerId: technician?.providerId,
          serviceName: service?.title ?? 'Service Request',
          orderId: 'ORD-${createdId.isNotEmpty ? createdId.substring(0, 4).toUpperCase() : '8063'}',
          status: OrderBadgeStatus.active,
          scheduledTime: scheduledTime,
          location: locationStr,
          technicianName: technician?.name ?? 'Arjun Kumar',
          price: '$priceStr · Postpaid',
          technicianImageUrl: technician?.avatarUrl,
        );

        context.go('/booking_requested', extra: orderItem);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'An unexpected error occurred.';
        try {
          final dynamic errorData = (e as dynamic).response?.data;
          if (errorData is Map && errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          } else {
            errorMessage = e.toString();
          }
        } catch (_) {
          errorMessage = e.toString();
        }
        _showErrorDialog(context, errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.errorBg,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/images/XCircle.svg',
                      width: 28,
                      height: 28,
                      colorFilter: const ColorFilter.mode(AppColors.error, BlendMode.srcIn),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Booking Failed',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleLight.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onLight,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.captionMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go('/home');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.onLight,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      'Understood',
                      style: AppTextStyles.button.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // dynamic amount passed from widget

  String get _summaryLabel {
    if (_mode == PaymentMode.prepaid) {
      return 'Prepaid • Pay now via ${_prepaidMethod.label}';
    }
    return 'Postpaid • Pay after via ${_postpaidMethod.label}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AppTopBar(title: 'Payment Type'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _amountCard(),
                    const SizedBox(height: 16),
                    Text(
                      'Select Payment Type',
                      style: AppTextStyles.titleLight.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _prepaidCard(),
                    const SizedBox(height: 12),
                    _postpaidCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(top: BorderSide(color: AppColors.dropDownBorder)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        SvgPicture.asset('assets/images/lock.svg', width: 24, height: 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _summaryLabel,
                            style: AppTextStyles.button.copyWith(color: Theme.of(context).colorScheme.secondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/rupee.svg',
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(AppColors.blueLight, BlendMode.srcIn),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${widget.amount}',
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                          height: 1.5,
                          color: AppColors.blueLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _isBooking
                  ? Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withAlpha(128),
                        borderRadius: BorderRadius.circular(36),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        ),
                      ),
                    )
                  : AppPrimaryButton(
                      text: _mode == PaymentMode.postpaid ? 'Confirm' : 'Confirm & Pay',
                      onTap: () {
                        final updatedDetails = Map<String, dynamic>.from(widget.bookingDetails);
                        updatedDetails['collectionType'] = _mode == PaymentMode.prepaid ? 'PREPAID' : 'POSTPAID';
                        
                        String paymentMethodStr = 'CASH';
                        if (_mode == PaymentMode.prepaid) {
                          switch (_prepaidMethod) {
                            case PrepaidMethod.upi:
                              paymentMethodStr = 'UPI';
                              break;
                            case PrepaidMethod.card:
                              paymentMethodStr = 'CARD';
                              break;
                            case PrepaidMethod.netBanking:
                              paymentMethodStr = 'NET_BANKING';
                              break;
                          }
                        } else {
                          switch (_postpaidMethod) {
                            case PostpaidMethod.card:
                              paymentMethodStr = 'CARD';
                              break;
                            case PostpaidMethod.netBanking:
                              paymentMethodStr = 'NET_BANKING';
                              break;
                            case PostpaidMethod.cash:
                              paymentMethodStr = 'CASH';
                              break;
                          }
                        }
                        updatedDetails['paymentMethod'] = paymentMethodStr;

                        if (_mode == PaymentMode.prepaid) {
                          context.push('/payment_gateway', extra: updatedDetails);
                        } else {
                          _onConfirmPostpaid(updatedDetails);
                        }
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _amountCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.inputBgSecondary,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Theme.of(context).dividerColor),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount to Pay',
              style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            SizedBox(height: 2),
            Text(
              '${widget.quantity} unit${widget.quantity > 1 ? 's' : ''} × ₹${widget.quantity > 0 ? (widget.serviceCharge / widget.quantity).round() : widget.serviceCharge} - ₹${widget.fee} fee',
              style: AppTextStyles.caption.copyWith(color: Theme.of(context).colorScheme.secondary),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          textBaseline: TextBaseline.alphabetic,
          children: [
            SvgPicture.asset(
              'assets/images/rupee.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.primary, BlendMode.srcIn),
            ),
            SizedBox(width: 2),
            Text(
              '${widget.amount}',
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _prepaidCard() {
    final active = _mode == PaymentMode.prepaid;
    return PaymentSection(
      isActive: active,
      headerLabel: 'PREPAID',
      headerSub: 'Pay now • Instant booking',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pay via:',
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 14, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PaymentMethodChip(
                icon: SvgPicture.asset('assets/images/smart-phone-01.svg'),
                label: 'UPI',
                selected: active && _prepaidMethod == PrepaidMethod.upi,
                onTap: () => setState(() {
                  _mode = PaymentMode.prepaid;
                  _prepaidMethod = PrepaidMethod.upi;
                }),
              ),
              PaymentMethodChip(
                icon: SvgPicture.asset('assets/images/credit-card.svg'),
                label: 'Card',
                selected: active && _prepaidMethod == PrepaidMethod.card,
                onTap: () => setState(() {
                  _mode = PaymentMode.prepaid;
                  _prepaidMethod = PrepaidMethod.card;
                }),
              ),
              PaymentMethodChip(
                icon: SvgPicture.asset('assets/images/bank.svg'),
                label: 'Net Banking',
                selected: active && _prepaidMethod == PrepaidMethod.netBanking,
                onTap: () => setState(() {
                  _mode = PaymentMode.prepaid;
                  _prepaidMethod = PrepaidMethod.netBanking;
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _postpaidCard() {
    final active = _mode == PaymentMode.postpaid;
    return PaymentSection(
      isActive: active,
      headerLabel: 'POSTPAID',
      headerSub: 'Pay after service is done:',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pay via:',
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 14, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              PaymentMethodChip(
                icon: SvgPicture.asset('assets/images/credit-card.svg'),
                label: 'Card',
                selected: active && _postpaidMethod == PostpaidMethod.card,
                onTap: () => setState(() {
                  _mode = PaymentMode.postpaid;
                  _postpaidMethod = PostpaidMethod.card;
                }),
              ),
              PaymentMethodChip(
                icon: SvgPicture.asset('assets/images/bank.svg'),
                label: 'Net Banking',
                selected: active && _postpaidMethod == PostpaidMethod.netBanking,
                onTap: () => setState(() {
                  _mode = PaymentMode.postpaid;
                  _postpaidMethod = PostpaidMethod.netBanking;
                }),
              ),
              PaymentMethodChip(
                icon: SvgPicture.asset('assets/images/dollar-circle.svg'),
                label: 'Cash',
                selected: active && _postpaidMethod == PostpaidMethod.cash,
                onTap: () => setState(() {
                  _mode = PaymentMode.postpaid;
                  _postpaidMethod = PostpaidMethod.cash;
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
