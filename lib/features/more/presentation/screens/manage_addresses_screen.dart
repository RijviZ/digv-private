import 'package:digv/I10n/app_localizations.dart';
import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/features/address/domain/entities/address.dart';
import 'package:digv/features/address/presentation/providers/address_provider.dart';
import 'package:digv/features/more/presentation/widgets/outline_add_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class ManageAddressesScreen extends ConsumerWidget {
  const ManageAddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final addressesAsync = ref.watch(addressListProvider);

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
                theme.colorScheme.onSurface,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: Text(
            l10n.manage_addresses,
            style: AppTextStyles.titleLight.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w400,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              addressesAsync.when(
                data: (addresses) {
                  if (addresses.isEmpty) {
                    return Center(
                      child: Text(
                        'No saved addresses',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: addresses.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final address = addresses[index];
                      final isDefault = address.isDefault ?? false;
                      final label = address.label ?? '';
                      return _AddressCard(
                        addressObj: address,
                        icon: label.toLowerCase() == 'home'
                            ? 'assets/images/house.svg'
                            : 'assets/images/briefcase.svg',
                        title: label,
                        isDefault: isDefault,
                        iconBg: isDefault 
                            ? (Theme.of(context).brightness == Brightness.dark ? AppColors.inputBgSecondaryDark : AppColors.unread)
                            : (Theme.of(context).brightness == Brightness.dark ? AppColors.inputBgSecondaryDark : AppColors.inputBgSecondary),
                        iconColor: isDefault 
                            ? theme.colorScheme.primary 
                            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        address: address.addressLine ?? '',
                        showSetDefault: !isDefault,
                        isSelected: isDefault,
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text(
                    'Failed to load addresses',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              OutlineAddButton(
                label: l10n.add_new_address,
                onTap: () => context.push('/add_address'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressCard extends ConsumerWidget {
  final Address addressObj;
  final String icon;
  final String title;
  final bool isDefault;
  final Color iconBg;
  final Color iconColor;
  final String address;
  final bool showSetDefault;
  final bool isSelected;

  const _AddressCard({
    required this.addressObj,
    required this.icon,
    required this.title,
    required this.isDefault,
    required this.iconBg,
    required this.iconColor,
    required this.address,
    required this.showSetDefault,
    required this.isSelected,
  });

  Future<void> _onDelete(BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          'Delete Address',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: Text(
          'Are you sure you want to delete this address?',
          style: TextStyle(color: theme.colorScheme.secondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(addressListProvider.notifier).deleteAddress(addressObj.userLocationId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address deleted successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete address: $e')),
          );
        }
      }
    }
  }

  Future<void> _onSetDefault(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(addressListProvider.notifier).updateAddress(
        addressObj.userLocationId,
        {'isDefault': true},
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Default address updated')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update default address: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
                          color: isDarkMode ? AppColors.inputBgSecondaryDark : AppColors.unread,
                          border: Border.all(
                            color: isDarkMode ? theme.dividerColor : AppColors.inputBorderSecondary,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          l10n.default_badge,
                          style: AppTextStyles.captionSmall.copyWith(
                            color: isDarkMode ? theme.colorScheme.primary : AppColors.blue,
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
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                if (showSetDefault) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _onSetDefault(context, ref),
                    child: Text(
                      'Set as default',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isDarkMode ? theme.colorScheme.onSurface : AppColors.blue,
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
                onTap: () => context.push('/add_address', extra: addressObj),
                child: Container(
                  width: 30,
                  height: 30,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/images/edit.svg',
                    height: 14,
                    width: 14,
                    colorFilter: ColorFilter.mode(
                      theme.colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              if (!isDefault) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _onDelete(context, ref),
                  child: Container(
                    width: 30,
                    height: 30,
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: isDarkMode ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: isDarkMode ? 0.3 : 0.2),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      'assets/images/delete.svg',
                      height: 14,
                      width: 14,
                      colorFilter: const ColorFilter.mode(
                        AppColors.error,
                        BlendMode.srcIn,
                      ),
                    ),
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

