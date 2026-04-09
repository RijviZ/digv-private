import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../domain/section_card.dart';

class ReviewPayScreen extends StatefulWidget {
  const ReviewPayScreen({super.key});

  @override
  State<ReviewPayScreen> createState() => _ReviewPayScreenState();
}

class _ReviewPayScreenState extends State<ReviewPayScreen> {
  final TextEditingController _promoController = TextEditingController();
  final FocusNode _promoFocus = FocusNode();

  bool _promoApplied = false;
  bool _promoError = false;

  final Map<String, int> _validCodes = {'FIRST10': 10};

  static const int _serviceCharge = 199;
  static const int _platformFee = 10;

  int get _discountPercent => _promoApplied ? (_validCodes[_promoController.text.trim().toUpperCase()] ?? 0) : 0;

  int get _discountAmount => ((_serviceCharge + _platformFee) * _discountPercent / 100).round();

  int get _total => _serviceCharge + _platformFee - _discountAmount;

  void _applyPromo() {
    final code = _promoController.text.trim().toUpperCase();
    if (_validCodes.containsKey(code)) {
      setState(() {
        _promoApplied = true;
        _promoError = false;
      });
      _promoFocus.unfocus();
    } else {
      setState(() {
        _promoApplied = false;
        _promoError = true;
      });
    }
  }

  void _removePromo() {
    setState(() {
      _promoApplied = false;
      _promoError = false;
      _promoController.clear();
    });
  }

  @override
  void dispose() {
    _promoController.dispose();
    _promoFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AppTopBar(title: 'Review Booking'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildServiceSummaryCard(),
                    const SizedBox(height: 20),
                    _buildPromoCard(),
                    const SizedBox(height: 20),
                    _buildPriceBreakdownCard(),
                    const SizedBox(height: 20),
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
          child: AppPrimaryButton(
            text: 'Confirm & Pay',
            onTap: () {
              context.push('/payment_type');
            },
          ),
        ),
      ),
    );
  }

  Widget _buildServiceSummaryCard() {
    return SectionCard(
      label: 'SERVICE SUMMARY',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(
            'Regular Service',
            style: AppTextStyles.titleLight.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Split • 1 unit',
            style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.secondary),
          ),

          const SizedBox(height: 16),
          const Divider(color: AppColors.dropDownBorder, thickness: 1, height: 1),
          const SizedBox(height: 14),
          _buildInfoRow(icon: 'assets/images/person.svg', label: 'Technician', value: 'Karim Ali'),
          const SizedBox(height: 14),
          _buildInfoRow(icon: 'assets/images/CalendarBlank.svg', label: 'Schedule', value: 'Tomorrow · 10:00 AM'),
          const SizedBox(height: 14),
          _buildInfoRow(icon: 'assets/images/pin_g.svg', label: 'Address', value: 'Home — Jl. Ngagelrejo No.34'),
        ],
      ),
    );
  }

  Widget _buildInfoRow({required String icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          child: SizedBox(
            width: 14,
            height: 14,
            child: SvgPicture.asset(
              icon,
              width: 14,
              height: 14,
              colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.secondary, BlendMode.srcIn),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.secondary)),
            Text(value, style: AppTextStyles.captionMedium.copyWith(color: Theme.of(context).colorScheme.primary)),
          ],
        ),
      ],
    );
  }

  Widget _buildPromoCard() {
    return SectionCard(
      label: 'PROMO CODE',
      bg: AppColors.inputBgSecondary,
      titleColor: Theme.of(context).colorScheme.secondary,
      titleBorder: false,
      titlePadding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      childTopPadding: 0,
      child: _promoApplied ? _buildAppliedPromo() : _buildPromoInput(),
    );
  }

  Widget _buildPromoInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: _promoError ? AppColors.error : AppColors.dropDownBorder),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: SvgPicture.asset(
                        'assets/images/promo.svg',
                        width: 14,
                        height: 14,
                        colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.secondary, BlendMode.srcIn),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        child: TextField(
                          controller: _promoController,
                          focusNode: _promoFocus,
                          style: AppTextStyles.captionMedium.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter promo code',
                            hintStyle: AppTextStyles.captionMedium.copyWith(color: AppColors.textGray),
                            filled: true,
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          textCapitalization: TextCapitalization.characters,
                          onSubmitted: (_) => _applyPromo(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _applyPromo,
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
                alignment: Alignment.center,
                child: Text('Apply', style: AppTextStyles.captionMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.surface
                )),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_promoError)
          Text('Invalid promo code. Please try again.', style: AppTextStyles.caption.copyWith(color: AppColors.error))
        else
          RichText(
            text: TextSpan(
              style: AppTextStyles.caption.copyWith(color: Theme.of(context).colorScheme.secondary),
              children: [
                TextSpan(text: 'Try code '),
                TextSpan(
                  text: 'FIRST10',
                  style: AppTextStyles.caption.copyWith(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w700),
                ),
                TextSpan(text: ' for 10% off'),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAppliedPromo() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.successBorder),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/images/promo.svg',
            width: 14,
            height: 14,
            colorFilter: ColorFilter.mode(AppColors.successText, BlendMode.srcIn),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '✓ ${_promoController.text.trim().toUpperCase()} Applied!',
              style: AppTextStyles.captionMedium.copyWith(color: AppColors.successText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdownCard() {
    return SectionCard(
      label: 'PRICE BREAKDOWN',
      bg: AppColors.inputBgSecondary,
      titleColor: Theme.of(context).colorScheme.secondary,
      titleBorder: false,
      titlePadding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      childTopPadding: 0,
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildPriceRow(
            label: 'Service charges',
            value: '₹$_serviceCharge',
            labelStyle: AppTextStyles.captionMedium.copyWith(color: Theme.of(context).colorScheme.secondary),
            valueStyle: AppTextStyles.captionMedium.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildPriceRow(
            label: 'Platform fee (5%)',
            value: '₹$_platformFee',
            labelStyle: AppTextStyles.captionMedium.copyWith(color: Theme.of(context).colorScheme.secondary),
            valueStyle: AppTextStyles.captionMedium.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),

          if (_promoApplied) ...[
            const SizedBox(height: 10),
            _buildPriceRow(
              label: 'Promo discount ($_discountPercent%)',
              value: '–₹$_discountAmount',
              labelStyle: AppTextStyles.captionMedium.copyWith(color: Theme.of(context).colorScheme.secondary),
              valueStyle: AppTextStyles.captionMedium.copyWith(
                color: AppColors.successText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          const SizedBox(height: 8),
          const Divider(color: AppColors.inputBorder, thickness: 1, height: 1),
          const SizedBox(height: 8),
          _buildPriceRow(
            label: 'Total',
            value: '₹$_total',
            labelStyle: AppTextStyles.bodyMediumBold.copyWith(fontWeight: FontWeight.w800),
            valueStyle: AppTextStyles.h4.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow({
    required String label,
    required String value,
    required TextStyle labelStyle,
    required TextStyle valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
    );
  }
}
