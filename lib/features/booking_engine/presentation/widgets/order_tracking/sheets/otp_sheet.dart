import 'package:digv/I10n/app_localizations.dart';
import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/core/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OtpSheet extends StatelessWidget {
  final VoidCallback onDone;
  final String? serviceName;
  final String? technicianName;
  final String otp;

  const OtpSheet({
    super.key,
    required this.onDone,
    this.serviceName,
    this.technicianName,
    this.otp = '123456',
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputBg = isDark
        ? AppColors.inputBgSecondaryDark
        : AppColors.inputBgSecondary;

    // Ensure 6 digits (padded or trimmed), defaulting to '123456'
    final cleanOtp = (otp.isEmpty ? '123456' : otp).padRight(6, '0').substring(0, 6);
    final digits = cleanOtp.split('');

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          const SizedBox(height: 20),

          // Service completed banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.unread,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.inputBorderSecondary),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/CheckCircle.svg',
                  height: 20,
                  width: 20,
                  colorFilter: const ColorFilter.mode(AppColors.blue, BlendMode.srcIn),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.service_completed_title,
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${serviceName ?? l10n.regular_service} by ${technicianName ?? "Arjun Kumar"}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text(
            l10n.your_delivery_otp,
            style: AppTextStyles.bodyMediumBold.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          // OTP Digits display (read-only boxes showing server OTP)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: digits.map((digit) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 46,
                height: 58,
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  digit,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.primary,
                    fontFamily: AppTextStyles.fontFamily,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 14),

          // Tap to copy button
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: cleanOtp));
              SnackBarUtils.showSuccess(context, 'OTP copied: $cleanOtp');
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.copy_rounded,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Copy OTP Code',
                    style: AppTextStyles.captionMedium.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Share Notice
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/clock.svg',
                height: 14,
                width: 14,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.secondary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  l10n.share_otp_notice,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Warning
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.dangerBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.dangerBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  'assets/images/ShieldStar.svg',
                  height: 18,
                  width: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.otp_warning,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.dangerText,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Confirm / Done Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
                l10n.confirm_otp,
                style: AppTextStyles.button.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
