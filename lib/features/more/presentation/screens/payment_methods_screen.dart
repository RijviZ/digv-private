import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/features/more/presentation/widgets/outline_add_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: SvgPicture.asset('assets/images/CaretLeft.svg', colorFilter: ColorFilter.mode(theme.colorScheme.onSurface, BlendMode.srcIn),height: 18,width: 18,),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: Text(
            'Payment Methods',
            style: AppTextStyles.titleLight.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w400,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saved Cards',
                style: AppTextStyles.titleLight.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              const _CardTile(
                brandColor: Color(0xFF1A1F71),
                brandLabel: 'VISA',
                maskedNumber: '•••• •••• •••• 4587',
                expiry: 'Expires 08/27',
                isDefault: true,
              ),
              const SizedBox(height: 10),

              const _CardTile(
                brandColor: Color(0xFFEB001B),
                brandLabel: 'MASTER\nCARD',
                maskedNumber: '•••• •••• •••• 1234',
                expiry: 'Expires 03/26',
                isDefault: false,
              ),
              const SizedBox(height: 20),

              OutlineAddButton(label: 'Add New Card', onTap: () {}),

              const SizedBox(height: 16),

              Text(
                'UPI IDs',
                style: AppTextStyles.titleLight.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              const _UpiTile(
                emoji: '🪙',
                name: 'Google Pay',
                upiId: 'rahul@okaxis',
              ),
              const SizedBox(height: 20),

              OutlineAddButton(label: 'Link UPI ID', onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  final Color brandColor;
  final String brandLabel;
  final String maskedNumber;
  final String expiry;
  final bool isDefault;

  const _CardTile({
    required this.brandColor,
    required this.brandLabel,
    required this.maskedNumber,
    required this.expiry,
    required this.isDefault,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDefault ? theme.colorScheme.primary : theme.dividerColor,
          width: isDefault ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 28,
            decoration: BoxDecoration(
              color: brandColor,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              brandLabel,
              style: TextStyle(
                color: Colors.white,
                fontSize: brandLabel == 'VISA' ? 11 : 7,
                fontFamily: AppTextStyles.fontFamilyPoppins,
                fontWeight: FontWeight.w900,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  maskedNumber,
                  style: AppTextStyles.bodyMediumBold.copyWith(
                    color: AppColors.textDark,
                    fontFamily: AppTextStyles.fontFamilyPoppins,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  expiry,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: theme.colorScheme.secondary,
                    fontFamily: AppTextStyles.fontFamilyPoppins,
                  ),
                ),
              ],
            ),
          ),

          // Default badge or delete button
          if (isDefault)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.unread,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Default',
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.blueDeep,
                  fontFamily: AppTextStyles.fontFamilyPoppins,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            Container(
              width: 30,
              height: 30,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorBg,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset('assets/images/delete.svg',height: 14,width: 14,),
            ),
        ],
      ),
    );
  }
}

class _UpiTile extends StatelessWidget {
  final String emoji;
  final String name;
  final String upiId;

  const _UpiTile({
    required this.emoji,
    required this.name,
    required this.upiId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor, width: 1.08),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.h6.copyWith(
                    color: AppColors.textDark,
                    fontFamily: AppTextStyles.fontFamilyPoppins,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  upiId,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: theme.colorScheme.secondary,
                    fontFamily: AppTextStyles.fontFamilyPoppins,
                  ),
                ),
              ],
            ),
          ),
          SvgPicture.asset('assets/images/checkmark.svg',height: 18,width: 18,),
        ],
      ),
    );
  }
}

