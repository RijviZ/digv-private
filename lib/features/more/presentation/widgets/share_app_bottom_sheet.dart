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
    final profileAsync = ref.watch(profileProvider);

    return profileAsync.when(
      data: (user) {
        final referralCode = user.userOwnReferralCode ?? 'HOMESERV50';
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
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
                  _buildDragHandle(),
                  const SizedBox(height: 24),
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildReferralCodeSection(context, referralCode),
                  const SizedBox(height: 16),
                  _buildReferralLinkSection(context, referralCode),
                  const SizedBox(height: 24),
                  _buildHowItWorksSection(),
                  const SizedBox(height: 24),
                  _buildShareButton(context, referralCode),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Container(
        height: 200,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Container(
        height: 200,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: const Center(child: Text('Failed to load profile')),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 48,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.dropDownBorder.withOpacity(0.5),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                'Share App & Earn',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontFamily: AppTextStyles.fontFamily,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Invite friends to HomeServ',
                style: TextStyle(
                  color: AppColors.textSecondary,
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
              color: AppColors.bg,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              'assets/images/close.svg',
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(AppColors.textDark, BlendMode.srcIn),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferralCodeSection(BuildContext context, String referralCode) {
    final spacedCode = referralCode.split('').join(' ');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'YOUR REFERRAL CODE',
            style: TextStyle(
              color: AppColors.textSecondary,
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
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    spacedCode,
                    style: TextStyle(
                      color: AppColors.textDark,
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
                  color: AppColors.onLight,
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
                            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Copy',
                            style: TextStyle(
                              color: Colors.white,
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

  Widget _buildReferralLinkSection(BuildContext context, String referralCode) {
    final link = 'https://homeserv.app/join?ref=$referralCode';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              link,
              style: TextStyle(
                color: AppColors.textSecondary,
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
                  colorFilter: const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
                ),
                const SizedBox(width: 6),
                Text(
                  'Copy link',
                  style: TextStyle(
                    color: AppColors.textSecondary,
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

  Widget _buildHowItWorksSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How It Works',
            style: TextStyle(
              color: AppColors.textDark,
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
            text: 'Share your unique code with friends & family',
          ),
          const SizedBox(height: 16),
          _buildHowItWorksStep(
            svgPath: 'assets/images/people.svg',
            iconColor: const Color(0xFF7C3AED),
            iconBgColor: const Color(0xFFEDE9FE),
            text: 'Friend downloads HomeServ and uses your code',
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
                color: AppColors.textSecondary,
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

  Widget _buildShareButton(BuildContext context, String referralCode) {
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
          backgroundColor: AppColors.onLight,
          foregroundColor: Colors.white,
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
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            Text(
              'Share Invite Now',
              style: TextStyle(
                fontSize: 16,
                fontFamily: AppTextStyles.fontFamily,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
