import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/core/widgets/app_top_bar.dart';
import 'package:digv/features/address/domain/entities/address.dart';
import 'package:digv/features/booking_engine/domain/date_item.dart';
import 'package:digv/features/booking_engine/domain/technician.dart';
import 'package:digv/features/booking_engine/presentation/providers/booking_provider.dart';
import 'package:digv/features/search/domain/entities/search_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../widgets/payment_method_chip.dart';
import '../../../payments/presentation/providers/payments_provider.dart';

enum _PayTab { upi, card, netBanking }

extension _PayTabX on _PayTab {
  String get label {
    switch (this) {
      case _PayTab.upi:
        return 'UPI';
      case _PayTab.card:
        return 'Card';
      case _PayTab.netBanking:
        return 'Net Banking';
    }
  }

  String get footerLabel {
    switch (this) {
      case _PayTab.upi:
        return 'Paying via UPI';
      case _PayTab.card:
        return 'Paying via Card';
      case _PayTab.netBanking:
        return 'Paying via Net Banking';
    }
  }

  String get svgPath {
    switch (this) {
      case _PayTab.upi:
        return 'assets/images/smart-phone-01.svg';
      case _PayTab.card:
        return 'assets/images/credit-card.svg';
      case _PayTab.netBanking:
        return 'assets/images/bank.svg';
    }
  }
}

class PostpaidPaymentScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> bookingDetails;

  const PostpaidPaymentScreen({super.key, required this.bookingDetails});

  int get amount => bookingDetails['amount'] as int? ?? 0;

  @override
  ConsumerState<PostpaidPaymentScreen> createState() => _PostpaidPaymentScreenState();
}

class _PostpaidPaymentScreenState extends ConsumerState<PostpaidPaymentScreen> {
  _PayTab _selectedTab = _PayTab.upi;
  bool _isProcessing = false;
  final TextEditingController _upiCtrl = TextEditingController();

  // amount comes from widget

  @override
  void dispose() {
    _upiCtrl.dispose();
    super.dispose();
  }

  String get _serviceTitle {
    final service = widget.bookingDetails['service'] as SearchServiceEntity?;
    if (service != null) return service.title;
    return widget.bookingDetails['serviceName'] as String? ?? 'AC Regular Service';
  }

  String get _technicianName {
    final technician = widget.bookingDetails['technician'] as Technician?;
    if (technician != null) return technician.name;
    return widget.bookingDetails['technicianName'] as String? ?? 'Arjun Kumar';
  }

  String _formatScheduledDate(DateItem dateItem) {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final monthIdx = months.indexOf(dateItem.month) + 1;
    final year = now.year;
    final mm = monthIdx.toString().padLeft(2, '0');
    final dd = dateItem.date.toString().padLeft(2, '0');
    return '$year-$mm-$dd';
  }

  void _onPay() async {
    setState(() => _isProcessing = true);
    try {
      if (widget.bookingDetails['isRemainingPayment'] == true) {
        // Real Postpaid remaining due payment flow!
        final serviceRequestId = widget.bookingDetails['serviceRequestId'] as String;
        final amountValue = widget.bookingDetails['amount'] as int? ?? 500;
        
        String method = 'WALLET';
        if (_selectedTab == _PayTab.card) {
          method = 'CARD';
        } else if (_selectedTab == _PayTab.netBanking) {
          method = 'NET_BANKING';
        } else if (_selectedTab == _PayTab.upi) {
          method = 'UPI';
        }

        String gatewayRef = 'MANUAL-REF-001';
        if (_selectedTab == _PayTab.card) {
          gatewayRef = 'CARD-REF-001';
        } else if (_selectedTab == _PayTab.netBanking) {
          gatewayRef = 'BANK-REF-001';
        } else if (_selectedTab == _PayTab.upi) {
          gatewayRef = 'UPI-REF-${_upiCtrl.text.isEmpty ? "GUEST" : _upiCtrl.text.toUpperCase()}';
        }

        // 1. Create a pending payment
        final paymentRes = await ref.read(paymentsNotifierProvider.notifier).createPendingPayment(
          serviceRequestId: serviceRequestId,
          method: method,
          collectionType: 'POSTPAID',
          amount: amountValue.toDouble().toStringAsFixed(2),
          gatewayReference: gatewayRef,
          note: 'Remaining postpaid payment',
        );

        final paymentId = paymentRes['paymentId'] as String? ?? paymentRes['data']?['paymentId'] as String? ?? '';
        if (paymentId.isEmpty) {
          throw Exception('Failed to get payment ID from server.');
        }

        if (mounted) {
          context.push('/postpaid_payment_success', extra: serviceRequestId);
        }
      } else {
        // Existing initial booking creation flow
        final service = widget.bookingDetails['service'] as SearchServiceEntity?;
        final technician = widget.bookingDetails['technician'] as Technician?;
        final date = widget.bookingDetails['date'] as DateItem?;
        final address = widget.bookingDetails['address'] as Address?;
        final timeStr = widget.bookingDetails['time'] as String? ?? '';
        
        final scheduledDateStr = date != null ? _formatScheduledDate(date) : '2026-05-10';
        
        final timeParts = timeStr.split('|');
        final slotId = timeParts.length > 1 ? timeParts[1] : '11111111-1111-4111-8111-111111111111';
        
        String gatewayRef = 'MANUAL-REF-001';
        if (_selectedTab == _PayTab.card) {
          gatewayRef = 'CARD-REF-001';
        } else if (_selectedTab == _PayTab.netBanking) {
          gatewayRef = 'BANK-REF-001';
        } else if (_selectedTab == _PayTab.upi) {
          gatewayRef = 'UPI-REF-${_upiCtrl.text.isEmpty ? "GUEST" : _upiCtrl.text.toUpperCase()}';
        }

        final baseAmount = widget.bookingDetails['amount'] as int? ?? 0;
        final quantity = widget.bookingDetails['quantity'] as int? ?? 1;
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
          'paymentMethod': widget.bookingDetails['paymentMethod'] as String? ?? 'CASH',
          'collectionType': widget.bookingDetails['collectionType'] as String? ?? 'POSTPAID',
          'gatewayReference': gatewayRef,
          'paymentAmount': realAmount.toDouble().toStringAsFixed(2),
          'addressLabel': address?.label ?? 'Home',
          'addressLine': address?.addressLine ?? 'House 12, Road 5, Dhanmondi',
          'city': address?.city ?? 'Dhaka',
          'state': address?.state ?? 'Dhaka',
          'postalCode': address?.postalCode ?? '1209',
          'serviceLat': address?.lat ?? 23.7465,
          'serviceLng': address?.lng ?? 90.376
        };

        // 2. Make the service request POST call
        final bookingRes = await ref.read(createBookingProvider.notifier).createBooking(payload);

        if (mounted) {
          final createdId = bookingRes['serviceRequestId'] as String? ?? bookingRes['data']?['serviceRequestId'] as String? ?? '';
          context.push('/postpaid_payment_success', extra: createdId);
        }
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
        setState(() => _isProcessing = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const AppTopBar(
              title: 'Pay for Service',
              subtitle: 'Postpaid • Service Completed',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _serviceCompletedBanner(),
                    const SizedBox(height: 20),
                    _amountDueCard(),
                    const SizedBox(height: 20),
                    _paymentMethodSection(),
                    const SizedBox(height: 20),
                    _securePaymentLabel(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(child: _bottomBar()),
    );
  }

  Widget _serviceCompletedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppColors.successBg,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: AppColors.successBorder),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: SvgPicture.asset(
              'assets/images/checkmark-circle.svg',
              width: 18,
              height: 18,
              colorFilter: const ColorFilter.mode(
                AppColors.successText,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service Completed!',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.successText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_serviceTitle by $_technicianName',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.successText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountDueCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppColors.inputBgSecondary,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: AppColors.inputBorder),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amount Due',
                style: AppTextStyles.captionMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/rupee.svg',
                    height: 16,
                    width: 16,
                    colorFilter: const ColorFilter.mode(
                      AppColors.onLight,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${widget.amount}',
                    style: const TextStyle(
                      color: AppColors.onLight,
                      fontSize: 24,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w900,
                      height: 1.50,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: AppColors.successBg,
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  width: 1,
                  color: AppColors.successBorder,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/images/lock.svg',
                  height: 12,
                  width: 12,
                  colorFilter: const ColorFilter.mode(
                    AppColors.successText,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'SSL Secured',
                  style: TextStyle(
                    color: AppColors.successText,
                    fontSize: 11,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    height: 1.50,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            'Select Payment Method',
            style: AppTextStyles.titleLight.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.onLight,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: AppColors.inputBgSecondary,
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 1,
                color: AppColors.inputBorder,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: AppColors.bg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pay via:',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onLight,
                    height: 1.50,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    PaymentMethodChip(
                      icon: SvgPicture.asset(_PayTab.upi.svgPath),
                      label: 'UPI',
                      selected: _selectedTab == _PayTab.upi,
                      onTap: () =>
                          setState(() => _selectedTab = _PayTab.upi),
                    ),
                    PaymentMethodChip(
                      icon: SvgPicture.asset(_PayTab.card.svgPath),
                      label: 'Card',
                      selected: _selectedTab == _PayTab.card,
                      onTap: () =>
                          setState(() => _selectedTab = _PayTab.card),
                    ),
                    PaymentMethodChip(
                      icon: SvgPicture.asset(_PayTab.netBanking.svgPath),
                      label: 'Net Banking',
                      selected: _selectedTab == _PayTab.netBanking,
                      onTap: () => setState(
                          () => _selectedTab = _PayTab.netBanking),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _upiIdInput(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _upiIdInput() {
    return Container(
      width: double.infinity,
      height: 47,
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: AppColors.bg,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: AppColors.dropDownBorder,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/images/smart-phone-01.svg',
            height: 16,
            width: 16,
            colorFilter: const ColorFilter.mode(
              AppColors.textSecondary,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _upiCtrl,
              style: AppTextStyles.bodyMedium.copyWith(
                fontFamily: 'Poppins',
                color: AppColors.onLight,
              ),
              decoration: InputDecoration(
                hintText: 'Or enter UPI ID (yourname @upi)',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  fontFamily: 'Poppins',
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _securePaymentLabel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/images/lock.svg',
          height: 13,
          width: 13,
          colorFilter: const ColorFilter.mode(
            AppColors.textSecondary,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Secure payment · 256-bit SSL encrypted',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
        ),
      ],
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(
          top: BorderSide(width: 1, color: AppColors.dropDownBorder),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/lock.svg',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _selectedTab.footerLabel,
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/rupee.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      AppColors.blueLight,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${widget.amount}',
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                      height: 1.4,
                      color: AppColors.blueLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _isProcessing ? null : _onPay,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: _isProcessing
                    ? AppColors.textSecondary
                    : AppColors.onLight,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Center(
                child: _isProcessing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Processing...',
                            style: AppTextStyles.button.copyWith(
                              color: AppColors.bg,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Pay ₹${widget.amount}',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.bg,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
