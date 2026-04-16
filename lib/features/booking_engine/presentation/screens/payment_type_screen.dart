import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../domain/payment_type.dart';
import '../widgets/payment_method_chip.dart';
import '../widgets/payment_section.dart';

class PaymentTypeScreen extends StatefulWidget {
  const PaymentTypeScreen({super.key});

  @override
  State<PaymentTypeScreen> createState() => _PaymentTypeScreenState();
}

class _PaymentTypeScreenState extends State<PaymentTypeScreen> {
  PaymentMode _mode = PaymentMode.prepaid;
  PrepaidMethod _prepaidMethod = PrepaidMethod.upi;
  PostpaidMethod _postpaidMethod = PostpaidMethod.card;

  static const int _amount = 525;

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
                  Row(
                    children: [
                      SvgPicture.asset('assets/images/lock.svg', width: 24, height: 24),
                      const SizedBox(width: 8),
                      Text(
                        _summaryLabel,
                        style: AppTextStyles.button.copyWith(color: Theme.of(context).colorScheme.secondary),
                      ),
                    ],
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
                        '$_amount',
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
              AppPrimaryButton(
                text: 'Confirm & Pay',
                onTap: () {
                  context.push('/payment_gateway');
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
              '1 unit × ₹500 + ₹25 fee',
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
              '$_amount',
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
