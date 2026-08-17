import 'package:digv/I10n/app_localizations.dart';
import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/features/bank_account/domain/entities/bank_account.dart';
import 'package:digv/features/bank_account/presentation/providers/bank_account_provider.dart';
import 'package:digv/features/bank_account/presentation/widgets/add_bank_account_bottom_sheet.dart';
import 'package:digv/features/more/presentation/widgets/outline_add_button.dart';
import 'package:digv/features/payment_method/domain/entities/saved_upi.dart';
import 'package:digv/features/payment_method/presentation/providers/payment_method_provider.dart';
import 'package:digv/features/payment_method/presentation/providers/upi_provider.dart';
import 'package:digv/features/payment_method/presentation/widgets/add_card_bottom_sheet.dart';
import 'package:digv/features/payment_method/presentation/widgets/link_upi_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bankAccountsAsync = ref.watch(bankAccountsProvider);
    final paymentMethodsAsync = ref.watch(paymentMethodsProvider);
    final upiList = ref.watch(upiListProvider);

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
              colorFilter: ColorFilter.mode(
                  theme.colorScheme.onSurface, BlendMode.srcIn),
              height: 18,
              width: 18,
            ),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: Text(
            l10n.saved_cards,
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
                l10n.saved_cards,
                style: AppTextStyles.titleLight.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              paymentMethodsAsync.when(
                data: (methods) {
                  if (methods.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        l10n.no_saved_cards,
                        style: TextStyle(color: theme.colorScheme.secondary),
                      ),
                    );
                  }
                  return Column(
                    children: methods.map((method) {
                      Color brandColor = const Color(0xFF1A1F71);
                      if (method.cardBrand.toUpperCase().contains('MASTER')) {
                        brandColor = const Color(0xFFEB001B);
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _CardTile(
                          brandColor: brandColor,
                          brandLabel: method.cardBrand.toUpperCase() == 'MASTERCARD' ? 'MASTER\nCARD' : method.cardBrand.toUpperCase(),
                          maskedNumber: '•••• •••• •••• ${method.cardLast4}',
                          expiry: 'Expires ${method.expiryMonth.toString().padLeft(2, '0')}/${method.expiryYear.toString().substring(2)}',
                          isDefault: method.isDefault,
                          onDelete: () {
                            if (method.userPaymentMethodId != null) {
                              ref.read(paymentMethodsProvider.notifier).deletePaymentMethod(method.userPaymentMethodId!);
                            }
                          },
                          onSetDefault: () {
                            if (method.userPaymentMethodId != null) {
                              ref.read(paymentMethodsProvider.notifier).setDefaultPaymentMethod(method.userPaymentMethodId!);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, stack) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    l10n.no_saved_cards,
                    style: TextStyle(color: theme.colorScheme.secondary),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              OutlineAddButton(
                label: l10n.add_new_card,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => const AddCardBottomSheet(),
                  );
                },
              ),

              const SizedBox(height: 24),

              Text(
                l10n.upi_ids,
                style: AppTextStyles.titleLight.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              if (upiList.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'No UPI IDs linked',
                    style: TextStyle(color: theme.colorScheme.secondary),
                  ),
                )
              else
                Column(
                  children: upiList.map((upi) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _UpiTile(
                        upi: upi,
                        onSetDefault: () {
                          ref.read(upiListProvider.notifier).setDefaultUpi(upi.id);
                        },
                        onDelete: () {
                          ref.read(upiListProvider.notifier).deleteUpi(upi.id);
                        },
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 10),

              OutlineAddButton(
                label: l10n.link_upi_id,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => const LinkUpiBottomSheet(),
                  );
                },
              ),

              const SizedBox(height: 24),

              Text(
                l10n.bank_accounts,
                style: AppTextStyles.titleLight.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              bankAccountsAsync.when(
                data: (accounts) {
                  if (accounts.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'No bank accounts saved',
                        style: TextStyle(color: theme.colorScheme.secondary),
                      ),
                    );
                  }
                  return Column(
                    children: accounts.map((account) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _BankAccountTile(
                          account: account,
                          onSetDefault: () {
                            ref.read(bankAccountsProvider.notifier).setDefaultBankAccount(account.userBankAccountId);
                          },
                          onDelete: () {
                            ref.read(bankAccountsProvider.notifier).deleteBankAccount(account.userBankAccountId);
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, stack) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'No bank accounts saved',
                    style: TextStyle(color: theme.colorScheme.secondary),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              OutlineAddButton(
                label: l10n.add_bank_account,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => const AddBankAccountBottomSheet(),
                  );
                },
              ),
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
  final VoidCallback? onDelete;
  final VoidCallback? onSetDefault;

  const _CardTile({
    required this.brandColor,
    required this.brandLabel,
    required this.maskedNumber,
    required this.expiry,
    required this.isDefault,
    this.onDelete,
    this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: (!isDefault && onSetDefault != null) ? onSetDefault : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
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
                    color: theme.colorScheme.primary,
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
            GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 30,
                height: 30,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.errorBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/images/delete.svg',
                  height: 14,
                  width: 14,
                ),
              ),
            ),
        ],
      ),
      ));
  }
}

class _UpiTile extends StatelessWidget {
  final SavedUpi upi;
  final VoidCallback? onSetDefault;
  final VoidCallback? onDelete;

  const _UpiTile({
    required this.upi,
    this.onSetDefault,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: (!upi.isDefault && onSetDefault != null) ? onSetDefault : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: upi.isDefault ? theme.colorScheme.primary : theme.dividerColor,
            width: upi.isDefault ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Text(upi.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    upi.name,
                    style: AppTextStyles.h6.copyWith(
                      color: AppColors.textDark,
                      fontFamily: AppTextStyles.fontFamilyPoppins,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    upi.upiId,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: theme.colorScheme.secondary,
                      fontFamily: AppTextStyles.fontFamilyPoppins,
                    ),
                  ),
                ],
              ),
            ),
            if (upi.isDefault)
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
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 30,
                  height: 30,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.errorBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/images/delete.svg',
                    height: 14,
                    width: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BankAccountTile extends StatelessWidget {
  final BankAccount account;
  final VoidCallback? onSetDefault;
  final VoidCallback? onDelete;

  const _BankAccountTile({
    required this.account,
    this.onSetDefault,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String maskedNumber =
        '•••• ${account.accountNumber.length > 4 ? account.accountNumber.substring(account.accountNumber.length - 4) : account.accountNumber}';

    return GestureDetector(
      onTap: (!account.isDefault && onSetDefault != null) ? onSetDefault : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: account.isDefault ? theme.colorScheme.primary : theme.dividerColor,
            width: account.isDefault ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/images/bank.svg',
                height: 24,
                width: 24,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.bankName,
                    style: AppTextStyles.bodyMediumBold.copyWith(
                      color: AppColors.textDark,
                      fontFamily: AppTextStyles.fontFamilyPoppins,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    maskedNumber,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: theme.colorScheme.secondary,
                      fontFamily: AppTextStyles.fontFamilyPoppins,
                    ),
                  ),
                ],
              ),
            ),
            if (account.isDefault)
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
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 30,
                  height: 30,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.errorBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/images/delete.svg',
                    height: 14,
                    width: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


