import 'package:digv/I10n/app_localizations.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../../core/theme/app_colors.dart';

class OtpSheet extends StatefulWidget {
  final VoidCallback onDone;

  const OtpSheet({super.key, required this.onDone});

  @override
  State<OtpSheet> createState() => _OtpSheetState();
}

class _OtpSheetState extends State<OtpSheet> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final inputBg = Theme.of(context).brightness == Brightness.dark
        ? AppColors.inputBgSecondaryDark
        : AppColors.inputBgSecondary;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
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
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.inputBorderSecondary),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/CheckCircle.svg',
                    height: 18,
                    width: 18,
                    colorFilter: const ColorFilter.mode(AppColors.blue, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.service_completed_title,
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${l10n.regular_service} by Arjun Kumar',
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

            const SizedBox(height: 20),
            Text(
              l10n.your_delivery_otp,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 8),

            // OTP boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 60,
                  height: 66,
                  decoration: BoxDecoration(
                    color: inputBg,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _controllers[i],
                    focusNode: _nodes[i],
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintText: '0',
                      hintStyle: AppTextStyles.bodyLarge.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    onChanged: (val) {
                      if (val.isNotEmpty && i < 3) {
                        _nodes[i + 1].requestFocus();
                      }
                    },
                  ),
                );
              }),
            ),

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/clock.svg',
                  height: 12,
                  width: 12,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.secondary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
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
            const SizedBox(height: 20),

            // Warning
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.dangerBg,
                borderRadius: BorderRadius.circular(6),
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      l10n.otp_warning,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.dangerText,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: widget.onDone,
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
      ),
    );
  }
}
