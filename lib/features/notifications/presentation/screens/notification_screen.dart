import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(context),
      body: ListView(
        padding: EdgeInsetsGeometry.symmetric(vertical: 24),
        children: [
          _buildSectionHeader('New', context),
          SizedBox(height: 12),
          _buildNotificationItem(
            'assets/images/car.svg',
            'Technician On the Way',
            'Arjun Kumar is heading to your location',
            '2 min ago',
            true,
            true,
            context,
          ),
          _buildNotificationItem(
            'assets/images/lock-key.svg',
            'Service Completion OTP',
            'Enter OTP 4829 to confirm service completion',
            '2 min ago',
            true,
            true,
            context,
            isLast: true
          ),
          SizedBox(height: 32),
          _buildSectionHeader('Earlier', context),
          SizedBox(height: 12),
          _buildNotificationItem(
            'assets/images/Gift.svg',
            'First Service 10% OFF',
            'Use code FIRSTIO on your next booking',
            '',
            false,
            false,
            context,
          ),
          _buildNotificationItem(
            'assets/images/Gift.svg',
            'Second Service 15% OFF',
            'Use code SECONDIO to enjoy savings on your next appointment...',
            '',
            false,
            false,
            context,
          ),
          _buildNotificationItem(
            'assets/images/dollar.svg',
            'Refer & Earn 100',
            'Refer your friends and earn rewards',
            '',
            false,
            false,
            context,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      surfaceTintColor: Theme.of(context).colorScheme.surface,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => context.pop,
        icon: SvgPicture.asset('assets/images/CaretLeft.svg'),
      ),
      title: Column(
        children: [
          Text(
            'Notifications',
            style: AppTextStyles.titleLight.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            '2 unread',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {},
          child: Text(
            'Read All',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
      child: Text(
        title,
        style: AppTextStyles.h3.copyWith(
          color: Theme.of(context).colorScheme.primary,
          height: 1.40,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    String icon,
    String title,
    String subtitle,
    String time,
    bool isNew,
    bool hasUnreadDot,
    BuildContext context, {
    bool isLast = false,
  }) {
    final backgroundColor = isNew
        ? AppColors.unread
        : Theme.of(context).colorScheme.surface;
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: isNew & !isLast
            ? Border(bottom: BorderSide(color: AppColors.inputBorderSecondary))
            : null,
      ),
      padding: EdgeInsetsGeometry.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isNew
                    ? AppColors.inputBorderSecondary
                    : Theme.of(context).dividerColor,
              ),
            ),
            padding: EdgeInsetsGeometry.all(14),
            child: SvgPicture.asset(icon),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodyLarge),
                    ),
                    SizedBox(width: 16),
                    Text(
                      time,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),

                    if (hasUnreadDot) ...[
                      SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: ShapeDecoration(
                          color: const Color(0xFF1D4ED8),
                          shape: OvalBorder(),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.captionMedium.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
