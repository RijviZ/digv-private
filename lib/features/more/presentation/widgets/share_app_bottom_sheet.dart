import 'package:digv/I10n/app_localizations.dart';
import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/core/utils/snackbar_utils.dart';
import 'package:digv/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ShareAppBottomSheet extends ConsumerWidget {
  const ShareAppBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ShareAppBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(profileProvider);

    return profileAsync.when(
      data: (user) {
        final referralCode = user.userOwnReferralCode ?? 'HOMESERV50';
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildDragHandle(theme),
                  const SizedBox(height: 24),
                  _buildHeader(context, theme),
                  const SizedBox(height: 24),
                  _buildReferralCodeSection(context, referralCode, theme),
                  const SizedBox(height: 16),
                  _buildReferralLinkSection(context, referralCode, theme),
                  const SizedBox(height: 24),
                  _buildHowItWorksSection(theme, context),
                  const SizedBox(height: 24),
                  _buildShareButton(context, referralCode, theme),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Container(
        height: 200,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Container(
        height: 200,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: const Center(child: Text('Failed to load profile')),
      ),
    );
  }

  Widget _buildDragHandle(ThemeData theme) {
    return Container(
      width: 48,
      height: 4,
      decoration: BoxDecoration(
        color: theme.dividerColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.blueDeep,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SvgPicture.asset(
            'assets/images/Gift.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Color(0xFFFBBF24), BlendMode.srcIn),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.share_app_title,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 18,
                  fontFamily: AppTextStyles.fontFamily,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Invite friends to HomeServ',
                style: TextStyle(
                  color: theme.colorScheme.secondary,
                  fontSize: 14,
                  fontFamily: AppTextStyles.fontFamily,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.dividerColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              'assets/images/close.svg',
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(theme.colorScheme.primary, BlendMode.srcIn),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferralCodeSection(BuildContext context, String referralCode, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final spacedCode = referralCode.split('').join(' ');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            l10n.your_referral_code,
            style: TextStyle(
              color: theme.colorScheme.secondary,
              fontSize: 11,
              fontFamily: AppTextStyles.fontFamilyPoppins,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.80,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark ? AppColors.inputBgSecondaryDark : AppColors.inputBgSecondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    spacedCode,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 22,
                      fontFamily: AppTextStyles.fontFamily,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 62,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: referralCode));
                      SnackBarUtils.showSuccess(context, 'Referral code copied!');
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/images/copy.svg',
                            width: 16,
                            height: 16,
                            colorFilter: ColorFilter.mode(theme.colorScheme.onPrimary, BlendMode.srcIn),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.copy_link,
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 12,
                              fontFamily: AppTextStyles.fontFamily,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReferralLinkSection(BuildContext context, String referralCode, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final link = 'https://homeserv.app/join?ref=$referralCode';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              link,
              style: TextStyle(
                color: theme.colorScheme.secondary,
                fontSize: 13,
                fontFamily: AppTextStyles.fontFamily,
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: link));
              SnackBarUtils.showSuccess(context, 'Referral link copied!');
            },
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/copy.svg',
                  width: 14,
                  height: 14,
                  colorFilter: ColorFilter.mode(theme.colorScheme.secondary, BlendMode.srcIn),
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.copy_link,
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
                    fontSize: 13,
                    fontFamily: AppTextStyles.fontFamily,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection(ThemeData theme, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.how_it_works,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 14,
              fontFamily: AppTextStyles.fontFamily,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _buildHowItWorksStep(
            svgPath: 'assets/images/share.svg',
            iconColor: AppColors.blueLight,
            iconBgColor: AppColors.unread,
            text: l10n.share_code_step,
            theme: theme,
          ),
          const SizedBox(height: 16),
          _buildHowItWorksStep(
            svgPath: 'assets/images/people.svg',
            iconColor: const Color(0xFF7C3AED),
            iconBgColor: const Color(0xFFEDE9FE),
            text: l10n.friend_download_step,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksStep({
    required String svgPath,
    required Color iconColor,
    required Color iconBgColor,
    required String text,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SvgPicture.asset(
            svgPath,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              text,
              style: TextStyle(
                color: theme.colorScheme.secondary,
                fontSize: 13,
                fontFamily: AppTextStyles.fontFamily,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShareButton(BuildContext context, String referralCode, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          final inviteText = 'Hey! Use my referral code $referralCode to get amazing services on HomeServ. Download the app now: https://homeserv.app/join?ref=$referralCode';
          Clipboard.setData(ClipboardData(text: inviteText));
          SnackBarUtils.showSuccess(context, 'Invite message copied to clipboard!');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/share.svg',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(theme.colorScheme.onPrimary, BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.share_invite_now,
              style: TextStyle(
                fontSize: 16,
                fontFamily: AppTextStyles.fontFamily,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
