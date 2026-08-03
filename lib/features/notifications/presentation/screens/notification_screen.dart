import 'package:digv/I10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/features/orders/domain/models/order_item.dart';
import 'package:digv/features/orders/presentation/providers/orders_provider.dart';

import '../../domain/entities/notification_entity.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final unreadCountAsync = ref.watch(unreadCountProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(context, unreadCountAsync, ref),
      body: notificationsAsync.when(
        data: (data) {
          if (data.items.isEmpty) {
            return _buildEmptyState(context);
          }

          final newNotifications = data.items.where((n) => !n.isRead).toList();
          final earlierNotifications = data.items.where((n) => n.isRead).toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(notificationsProvider);
              ref.invalidate(unreadCountProvider);
              await ref.read(notificationsProvider.future);
              await ref.read(unreadCountProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              children: [
                if (newNotifications.isNotEmpty) ...[
                  _buildSectionHeader('New', context),
                  const SizedBox(height: 12),
                  ...newNotifications.asMap().entries.map((entry) {
                    final index = entry.key;
                    final notification = entry.value;
                    return _buildNotificationItem(
                      notification.icon ?? _getIconForType(notification.type),
                      notification.title,
                      notification.body,
                      _getTimeAgo(notification.createdAt),
                      true,
                      !notification.isRead,
                      context,
                      isLast: index == newNotifications.length - 1,
                      onTap: () => _handleNotificationTap(context, ref, notification),
                    );
                  }),
                  const SizedBox(height: 32),
                ],
                if (earlierNotifications.isNotEmpty) ...[
                  _buildSectionHeader('Earlier', context),
                  const SizedBox(height: 12),
                  ...earlierNotifications.asMap().entries.map((entry) {
                    final index = entry.key;
                    final notification = entry.value;
                    return _buildNotificationItem(
                      notification.icon ?? _getIconForType(notification.type),
                      notification.title,
                      notification.body,
                      _getTimeAgo(notification.createdAt),
                      false,
                      !notification.isRead,
                      context,
                      isLast: index == earlierNotifications.length - 1,
                      onTap: () => _handleNotificationTap(context, ref, notification),
                    );
                  }),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading notifications', style: AppTextStyles.bodyLarge),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(notificationsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/images/BellSimple.svg', width: 64, height: 64, colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.secondary.withOpacity(0.5), BlendMode.srcIn)),
          const SizedBox(height: 16),
          Text(
            l10n.no_notifications,
            style: AppTextStyles.h3.copyWith(color: Theme.of(context).colorScheme.secondary),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AsyncValue<int> asyncCount, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final unreadCount = asyncCount.when(
      data: (count) => count,
      loading: () => 0,
      error: (_, __) => 0,
    );

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      surfaceTintColor: Theme.of(context).colorScheme.surface,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: SvgPicture.asset(
          'assets/images/CaretLeft.svg',
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.primary,
            BlendMode.srcIn,
          ),
        ),
      ),
      title: Column(
        children: [
          Text(
            l10n.notifications_title,
            style: AppTextStyles.titleLight.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          if (unreadCount >= 0)
            Text(
              '$unreadCount unread',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: unreadCount > 0
              ? () async {
                  final repository = ref.read(notificationRepositoryProvider);
                  await repository.markAllAsRead();
                  ref.invalidate(notificationsProvider);
                  ref.invalidate(unreadCountProvider);
                }
              : null,
          child: Text(
            l10n.read_all,
            style: AppTextStyles.bodyMedium.copyWith(
              color: unreadCount > 0 ? Theme.of(context).colorScheme.primary : Theme.of(context).disabledColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayTitle = title.toLowerCase() == 'new' ? l10n.new_section : title;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        displayTitle,
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
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isNew
        ? (isDark ? AppColors.inputBgSecondaryDark : AppColors.unread)
        : Theme.of(context).colorScheme.surface;
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: isNew && !isLast
              ? Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.inputBorderDark : AppColors.inputBorderSecondary,
                  ),
                )
              : Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withAlpha(50))),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  color: isNew ? AppColors.inputBorderSecondary : Theme.of(context).dividerColor,
                ),
              ),
              padding: const EdgeInsets.all(14),
              child: icon.startsWith('http')
                  ? SvgPicture.network(
                      icon,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.onSurface,
                        BlendMode.srcIn,
                      ),
                    )
                  : SvgPicture.asset(
                      icon,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.onSurface,
                        BlendMode.srcIn,
                      ),
                    ),
            ),
            const SizedBox(width: 16),
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
                      const SizedBox(width: 16),
                      Text(
                        time,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      if (hasUnreadDot) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const ShapeDecoration(
                            color: Color(0xFF1D4ED8),
                            shape: OvalBorder(),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    maxLines: 2,
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
      ),
    );
  }

  String _getIconForType(String type) {
    switch (type) {
      case 'SERVICE_REQUEST_CREATED':
      case 'SERVICE_REQUEST_ACCEPTED':
      case 'SERVICE_REQUEST_COMPLETED':
        return 'assets/images/car.svg';
      case 'OTP_GENERATED':
        return 'assets/images/lock-key.svg';
      case 'PROMO_CODE_RECEIVED':
        return 'assets/images/Gift.svg';
      case 'REFERRAL_SUCCESS':
        return 'assets/images/dollar.svg';
      default:
        return 'assets/images/BellSimple.svg';
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays >= 1) {
      return '${difference.inDays} d ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} h ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} m ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _handleNotificationTap(BuildContext context, WidgetRef ref, NotificationEntity notification) async {
    // 1. Mark as read if unread
    if (!notification.isRead) {
      try {
        final repository = ref.read(notificationRepositoryProvider);
        await repository.markAsRead(notification.notificationId);
        ref.invalidate(notificationsProvider);
        ref.invalidate(unreadCountProvider);
      } catch (e) {
        debugPrint('Error marking notification as read: $e');
      }
    }

    // 2. Extract serviceRequestId and/or serviceRequestNumber (SBR123456)
    String? serviceRequestId = notification.data?['serviceRequestId'] as String?;
    String? serviceRequestNumber = notification.data?['serviceRequestNumber'] as String?;
    
    // Also try parsing tracking ID from title/body if not in data (e.g. SBR723695)
    if (serviceRequestNumber == null) {
      final sbrRegex = RegExp(r'\bSBR\d+\b');
      final match = sbrRegex.firstMatch(notification.title) ?? sbrRegex.firstMatch(notification.body);
      if (match != null) {
        serviceRequestNumber = match.group(0);
      }
    }

    if (serviceRequestId == null && notification.clickAction != null) {
      final uriParts = notification.clickAction!.split('/');
      if (uriParts.isNotEmpty) {
        final lastPart = uriParts.last;
        if (lastPart.length >= 32) {
          serviceRequestId = lastPart;
        }
      }
    }

    if (serviceRequestId == null && serviceRequestNumber == null) {
      return;
    }

    // Show progress dialog
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final ordersRepo = ref.read(ordersRepositoryProvider);
      // Fetch all service requests to find the match
      final orders = await ordersRepo.getServiceRequests();
      
      OrderItem? matchedOrder;
      for (final order in orders) {
        if (serviceRequestId != null && order.id == serviceRequestId) {
          matchedOrder = order;
          break;
        }
        if (serviceRequestNumber != null && order.orderId == serviceRequestNumber) {
          matchedOrder = order;
          break;
        }
      }

      // Pop the loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (matchedOrder != null) {
        if (context.mounted) {
          context.push('/order_tracking', extra: matchedOrder);
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order not found or access denied')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load order: $e')),
        );
      }
    }
  }
}
