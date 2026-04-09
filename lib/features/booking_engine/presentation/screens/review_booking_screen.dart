import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../domain/section_card.dart';

class ReviewBookingScreen extends StatefulWidget {
  const ReviewBookingScreen({super.key});

  @override
  State<ReviewBookingScreen> createState() => _ReviewBookingScreenState();
}

class _ReviewBookingScreenState extends State<ReviewBookingScreen> {
  int _quantity = 1;
  int _selectedAddress = 0;
  bool _agreedToTerms = false;

  static const int _pricePerUnit = 500;

  int get _totalPrice => _pricePerUnit * _quantity;

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
                    _buildServiceDetailsCard(),
                    const SizedBox(height: 14),
                    _buildAddressCard(),
                    const SizedBox(height: 16),
                    _buildTermsRow(),
                    const SizedBox(height: 12),
                    _buildSafePaymentRow(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(top: BorderSide(color: AppColors.dropDownBorder)),
          ),
          child: AppPrimaryButton(
            text: 'Proceed to Payment',
            onTap: _agreedToTerms
                ? () {
                    context.push('/review_and_pay');
                  }
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildServiceDetailsCard() {
    return SectionCard(
      label: 'SERVICE DETAILS',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AC Regular Service',
            style: AppTextStyles.titleLight.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text('Split AC', style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.secondary)),
          const SizedBox(height: 12),
          _buildTechnicianRow(),
          const SizedBox(height: 14),
          _buildScheduleRow(),
          const SizedBox(height: 14),

          // Divider
          const Divider(color: Color(0xFFEEEEEE), thickness: 1, height: 1),
          const SizedBox(height: 14),

          // Quantity row
          _buildQuantityRow(),
        ],
      ),
    );
  }

  Widget _buildTechnicianRow() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.inputBgSecondary,
        borderRadius: BorderRadius.circular(8),
        border: const Border(bottom: BorderSide(color: AppColors.inputBorder)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF90A4AE)),
            child: ClipOval(
              child: CustomPaint(
                painter: _AvatarPainter(),
                child: const Center(
                  child: Text(
                    'AK',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Name + stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Arjun Kumar',
                  style: AppTextStyles.captionMedium.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    SizedBox(height: 10, width: 10, child: SvgPicture.asset('assets/images/star.svg')),
                    const SizedBox(width: 2),
                    Text(
                      '4.9',
                      style: AppTextStyles.caption.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '(312)',
                      style: AppTextStyles.caption.copyWith(color: Theme.of(context).colorScheme.secondary),
                    ),
                    const SizedBox(width: 6),
                    Text('·', style: AppTextStyles.caption.copyWith(color: Theme.of(context).colorScheme.secondary)),
                    const SizedBox(width: 6),
                    SvgPicture.asset('assets/images/briefcase.svg', height: 10, width: 10),
                    const SizedBox(width: 3),
                    Text(
                      '5 yrs',
                      style: AppTextStyles.caption.copyWith(color: Theme.of(context).colorScheme.secondary),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            textBaseline: TextBaseline.alphabetic,
            children: [
              SvgPicture.asset('assets/images/rupee.svg', height: 13, width: 13),
              const SizedBox(width: 2),
              Text('500', style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.blue)),
              const SizedBox(width: 1),
              Text(
                '/visit',
                style: AppTextStyles.captionSmall.copyWith(color: Theme.of(context).colorScheme.secondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleRow() {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/images/CalendarBlank.svg',
          height: 14,
          width: 14,
          colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.secondary, BlendMode.srcIn),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Schedule', style: AppTextStyles.caption.copyWith(color: Theme.of(context).colorScheme.secondary)),
            const SizedBox(height: 1),
            Text(
              'Today · 10:00 AM',
              style: AppTextStyles.captionMedium.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantityRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quantity (units)',
                style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.secondary),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  SvgPicture.asset('assets/images/rupee.svg', height: 11, width: 11),
                  const SizedBox(width: 4),
                  Text('500', style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.blue)),
                  const SizedBox(width: 4),
                  Text(
                    ' × $_quantity = ',
                    style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.secondary),
                  ),
                  const SizedBox(width: 4),
                  SvgPicture.asset('assets/images/rupee.svg', height: 11, width: 11),
                  const SizedBox(width: 4),
                  Text(
                    '$_totalPrice',
                    style: AppTextStyles.bodyMediumBold.copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Stepper
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: AppColors.dropDownBorder),
          ),
          child: Row(
            children: [
              _stepperBtn(
                text: '-',
                onTap: () {
                  if (_quantity > 1) {
                    setState(() => _quantity--);
                  }
                },
              ),
              SizedBox(
                width: 60,
                height: 40,
                child: Center(
                  child: Text(
                    '$_quantity',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
              _stepperBtn(text: '+', onTap: () => setState(() => _quantity++)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepperBtn({required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.inputBgSecondary,
          borderRadius: BorderRadius.horizontal(
            left: text == '-' ? Radius.circular(2) : Radius.zero,
            right: text == '+' ? Radius.circular(2) : Radius.zero,
          ),
        ),
        child: Text(text, style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.primary)),
      ),
    );
  }

  Widget _buildAddressCard() {
    return SectionCard(
      label: 'SELECT ADDRESS',
      child: Column(
        children: [
          const SizedBox(height: 4),
          _buildAddressOption(
            index: 0,
            icon: 'assets/images/house.svg',
            title: 'Home',
            subtitle: 'Jl. Ngagelrejo No.34, Khulna — 9000',
          ),
          const SizedBox(height: 10),
          _buildAddressOption(
            index: 1,
            icon: 'assets/images/briefcase.svg',
            title: 'Office',
            subtitle: 'Road 5, Satmasjid Road, Khulna — 9100',
          ),
          const SizedBox(height: 10),
          _buildAddNewAddress(),
        ],
      ),
    );
  }

  Widget _buildAddressOption({
    required int index,
    required String icon,
    required String title,
    required String subtitle,
  }) {
    final selected = _selectedAddress == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedAddress = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppColors.dropDownBorder : AppColors.inputBorder),
        ),
        child: Row(
          children: [
            // Icon box
            _iconBox(icon: icon, selected: selected),
            const SizedBox(width: 12),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.captionMedium.copyWith(
                      color: selected ? AppColors.onDark : Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(subtitle, style: AppTextStyles.caption.copyWith(color: Theme.of(context).colorScheme.secondary)),
                ],
              ),
            ),

            // Radio dot
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.onDark : Theme.of(context).colorScheme.surface,
                border: Border.all(color: selected ? AppColors.onDark : Theme.of(context).dividerColor, width: 1),
              ),
              child: selected
                  ? Center(
                      child: CircleAvatar(
                        radius: 4,
                        backgroundColor: selected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surface,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBox({required String icon, required bool selected}) {
    return Container(
      width: 34,
      height: 34,
      padding: EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: selected ? AppColors.inputBorder : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
      ),
      child: SvgPicture.asset(
        icon,
        height: 16,
        width: 16,
        colorFilter: ColorFilter.mode(
          selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  Widget _buildAddNewAddress() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Row(
          children: [
            _iconBox(icon: 'assets/images/plus.svg', selected: false),
            const SizedBox(width: 12),
            Text(
              'Add new address',
              style: AppTextStyles.captionMedium.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsRow() {
    return GestureDetector(
      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: _agreedToTerms ? Theme.of(context).colorScheme.primary : null,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: _agreedToTerms ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
              ),
            ),
            child: _agreedToTerms ? Icon(Icons.check, size: 13, color: Theme.of(context).colorScheme.surface) : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.captionMedium.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: AppTextStyles.captionMedium.copyWith(color: AppColors.blueDeep, fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: ' and authorise 100% advance payment for this booking.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafePaymentRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          'assets/images/shield.svg',
          height: 13,
          width: 13,
          colorFilter: ColorFilter.mode(AppColors.blueDeep, BlendMode.srcIn),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            '100% Advance Safe Payment · All technicians background verified',
            style: AppTextStyles.caption.copyWith(color: Theme.of(context).colorScheme.secondary),
          ),
        ),
      ],
    );
  }
}

class _AvatarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.18);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.9),
        width: size.width * 0.72,
        height: size.height * 0.5,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
