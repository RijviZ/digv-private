import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _pushNotifications = true;
  bool _orderUpdates = true;
  bool _offersPromotions = true;
  bool _appAnnouncements = false;
  bool _chatMessages = true;

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
            'Notification Settings',
            style: AppTextStyles.titleLight.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w400,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotifCard(
                iconData: 'assets/images/notification.svg',
                iconBg: AppColors.unread,
                iconColor: AppColors.blueDeep,
                title: 'Push Notifications',
                subtitle: 'Allow DigV to send notifications',
                value: _pushNotifications,
                onChanged: (v) => setState(() => _pushNotifications = v),
                isBold: true,
                theme: theme,
              ),

              const SizedBox(height: 28),

              // ── Notification Types section ──
              Text(
                'Notification Types',
                style: AppTextStyles.h4.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  children: [
                    _NotifRow(
                      iconData: 'assets/images/update.svg',
                      iconBg: AppColors.unread,
                      iconColor: AppColors.blueDeep,
                      title: 'Order Updates',
                      subtitle: 'Booking confirmed, technician on way',
                      value: _orderUpdates,
                      onChanged: (v) => setState(() => _orderUpdates = v),
                      theme: theme,
                    ),
                    _divider(theme),
                    _NotifRow(
                      iconData: 'assets/images/promo.svg',
                      iconBg: AppColors.unread,
                      iconColor: AppColors.blueDeep,
                      title: 'Offers & Promotions',
                      subtitle: 'Discounts, referral bonuses',
                      value: _offersPromotions,
                      onChanged: (v) => setState(() => _offersPromotions = v),
                      theme: theme,
                    ),
                    _divider(theme),
                    _NotifRow(
                      iconData: 'assets/images/announcement.svg',
                      iconBg: AppColors.inputBgSecondary,
                      iconColor: AppColors.textSecondary,
                      title: 'App Announcements',
                      subtitle: 'Updates, maintenance notices',
                      value: _appAnnouncements,
                      onChanged: (v) => setState(() => _appAnnouncements = v),
                      theme: theme,
                    ),
                    _divider(theme),
                    _NotifRow(
                      iconData: 'assets/images/message.svg',
                      iconBg: AppColors.unread,
                      iconColor: AppColors.blueDeep,
                      title: 'Chat Messages',
                      subtitle: 'Messages from technicians',
                      value: _chatMessages,
                      onChanged: (v) => setState(() => _chatMessages = v),
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider(ThemeData theme) => Divider(
        height: 1,
        color: theme.dividerColor,
        indent: 16,
        endIndent: 16,
      );
}

// ── Push notification master card ─────────────────────────────────────────────
class _NotifCard extends StatelessWidget {
  final String iconData;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isBold;
  final ThemeData theme;

  const _NotifCard({
    required this.iconData,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.theme,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset(
              iconData,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h6.copyWith(
                    color: AppColors.textDark,
                    fontFamily: AppTextStyles.fontFamilyPoppins,
                    fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                    height: 1.5,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: theme.colorScheme.secondary,
                    fontFamily: AppTextStyles.fontFamilyPoppins,
                  ),
                ),
              ],
            ),
          ),
          AppToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _NotifRow extends StatelessWidget {
  final String iconData;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final ThemeData theme;

  const _NotifRow({
    required this.iconData,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset(
              iconData,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h6.copyWith(
                    color: AppColors.textDark,
                    fontFamily: AppTextStyles.fontFamilyPoppins,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: theme.colorScheme.secondary,
                    fontFamily: AppTextStyles.fontFamilyPoppins,
                  ),
                ),
              ],
            ),
          ),
          AppToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

// ── Reusable iOS-style toggle ──────────────────────────────────────────────────
class AppToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AppToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 27,
        decoration: BoxDecoration(
          color: value ? AppColors.onLight : AppColors.inputBorder,
          borderRadius: BorderRadius.circular(14),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              width: 21,
              height: 21,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
