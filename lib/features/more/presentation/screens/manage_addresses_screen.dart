import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/features/more/presentation/widgets/outline_add_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ManageAddressesScreen extends StatelessWidget {
  const ManageAddressesScreen({super.key});

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
            icon: SvgPicture.asset(
              'assets/images/CaretLeft.svg',
              height: 18,
              width: 18,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.secondary,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: Text(
            'Manage Addresses',
            style: AppTextStyles.titleLight.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w400,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 20),

              const _AddressCard(
                icon: 'assets/images/house.svg',
                title: 'Home',
                isDefault: true,
                iconBg: AppColors.unread,
                iconColor: AppColors.blueDeep,
                address: 'Jl. Ngagelrejo No.34, Khulna',
                showSetDefault: false,
                isSelected: true,
              ),
              const SizedBox(height: 12),

              _AddressCard(
                icon: 'assets/images/briefcase.svg',
                title: 'Office',
                isDefault: false,
                iconBg: AppColors.inputBgSecondary,
                iconColor: theme.colorScheme.secondary,
                address: 'Road 5, Sonadanga, Khulna 9000',
                showSetDefault: true,
                isSelected: false,
              ),
              const SizedBox(height: 20),

              OutlineAddButton(
                label: 'Add New Address',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final String icon;
  final String title;
  final bool isDefault;
  final Color iconBg;
  final Color iconColor;
  final String address;
  final bool showSetDefault;
  final bool isSelected;

  const _AddressCard({
    required this.icon,
    required this.title,
    required this.isDefault,
    required this.iconBg,
    required this.iconColor,
    required this.address,
    required this.showSetDefault,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: SvgPicture.asset(
              icon,
              height: 18,
              width: 18,
              colorFilter: ColorFilter.mode(
                iconColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.h6.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.unread,
                          border: Border.all(color: AppColors.inputBorderSecondary),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          'Default',
                          style: AppTextStyles.captionSmall.copyWith(
                            color: AppColors.blue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
                if (showSetDefault) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Set as default',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.blueDeep,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          Row(
            children: [
              GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 30,
                    height: 30,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset('assets/images/edit.svg',height: 14,width: 14,),
                  ),
                ),
              if (!isDefault) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 30,
                    height: 30,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.errorBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.errorBorder),
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset('assets/images/delete.svg',height: 14,width: 14,),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

