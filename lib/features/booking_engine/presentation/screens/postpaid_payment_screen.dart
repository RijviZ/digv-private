import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/core/widgets/app_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../widgets/payment_method_chip.dart';

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

class PostpaidPaymentScreen extends StatefulWidget {
  const PostpaidPaymentScreen({super.key});

  @override
  State<PostpaidPaymentScreen> createState() => _PostpaidPaymentScreenState();
}

class _PostpaidPaymentScreenState extends State<PostpaidPaymentScreen> {
  _PayTab _selectedTab = _PayTab.upi;
  bool _isProcessing = false;
  final TextEditingController _upiCtrl = TextEditingController();

  static const int _amount = 525;

  @override
  void dispose() {
    _upiCtrl.dispose();
    super.dispose();
  }

  void _onPay() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.push('/postpaid_payment_success');
    }
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
                  'AC Regular Service by Arjun Kumar',
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
                    '$_amount',
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
                Row(
                  children: [
                    PaymentMethodChip(
                      icon: SvgPicture.asset(_PayTab.upi.svgPath),
                      label: 'UPI',
                      selected: _selectedTab == _PayTab.upi,
                      onTap: () =>
                          setState(() => _selectedTab = _PayTab.upi),
                    ),
                    const SizedBox(width: 8),
                    PaymentMethodChip(
                      icon: SvgPicture.asset(_PayTab.card.svgPath),
                      label: 'Card',
                      selected: _selectedTab == _PayTab.card,
                      onTap: () =>
                          setState(() => _selectedTab = _PayTab.card),
                    ),
                    const SizedBox(width: 8),
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
                    '$_amount',
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
                        'Pay ₹$_amount',
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
