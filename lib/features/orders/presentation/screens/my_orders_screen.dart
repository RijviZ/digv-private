import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/features/orders/domain/models/order_item.dart';
import 'package:digv/features/orders/presentation/providers/orders_provider.dart';
import 'package:digv/features/orders/presentation/widgets/reschedule_bottom_sheet.dart';
import 'package:digv/features/orders/presentation/widgets/cancel_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class MyOrdersScreen extends ConsumerStatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  ConsumerState<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends ConsumerState<MyOrdersScreen> {
  OrderTab _selectedTab = OrderTab.active;

  Future<void> _makeCall(String phoneNumber) async {
    final Uri launchUri = Uri.parse('tel:${phoneNumber.replaceAll(' ', '')}');
    try {
      await launchUrl(
        launchUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Could not launch phone call: $e');
    }
  }

  String _tabLabel(OrderTab tab) {
    switch (tab) {
      case OrderTab.active:
        return 'Active';
      case OrderTab.past:
        return 'Past';
      case OrderTab.cancelled:
        return 'Cancelled';
      case OrderTab.upcoming:
        return 'Upcoming';
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          SafeArea(bottom: false, child: _buildTopBar()),
          _buildTabBar(),
          Expanded(
            child: _buildOrderList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Text(
        'My Orders',
        style: AppTextStyles.h3.copyWith(
          color: AppColors.onLight,
          height: 1.40,
        ),
      ),
    );
  }

  String? _tabToStatus(OrderTab tab) {
    switch (tab) {
      case OrderTab.active:
        return 'ACTIVE';
      case OrderTab.upcoming:
        return 'UPCOMING';
      case OrderTab.past:
        return 'PAST';
      case OrderTab.cancelled:
        return 'CANCELLED';
    }
  }

  Widget _buildTabBar() {
    final activeAsync = ref.watch(ordersProvider('ACTIVE'));
    final upcomingAsync = ref.watch(ordersProvider('UPCOMING'));
    final pastAsync = ref.watch(ordersProvider('PAST'));
    final cancelledAsync = ref.watch(ordersProvider('CANCELLED'));

    final counts = {
      OrderTab.active: activeAsync.value?.length ?? 0,
      OrderTab.upcoming: upcomingAsync.value?.length ?? 0,
      OrderTab.past: pastAsync.value?.length ?? 0,
      OrderTab.cancelled: cancelledAsync.value?.length ?? 0,
    };

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: Theme.of(context).dividerColor),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: OrderTab.values.map((tab) {
             final isSelected = tab == _selectedTab;
            final count = counts[tab] ?? 0;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedTab = tab);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: isSelected ? 2 : 1,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                child: Text(
                  '${_tabLabel(tab)} ($count)',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOrderList() {
    final statusStr = _tabToStatus(_selectedTab);
    final ordersAsync = ref.watch(ordersProvider(statusStr));

    return ordersAsync.when(
      data: (orders) {
        final Widget childWidget;
        
        if (orders.isEmpty) {
          childWidget = SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              height: 400,
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/images/order.svg',
                    width: 56,
                    height: 56,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No ${_tabLabel(_selectedTab).toLowerCase()} orders',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          childWidget = ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildOrderCard(orders[index]);
            },
          );
        }

        return RefreshIndicator(
          color: Theme.of(context).primaryColor,
          backgroundColor: Colors.white,
          onRefresh: () => ref.read(ordersProvider(statusStr).notifier).refresh(),
          child: childWidget,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => RefreshIndicator(
        color: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        onRefresh: () => ref.read(ordersProvider(statusStr).notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: 400,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Failed to load orders: $error', style: const TextStyle(color: AppColors.error)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.read(ordersProvider(statusStr).notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderItem order) {
    final OrderBadgeStatus badgeStatus;
    switch (_selectedTab) {
      case OrderTab.active:
        badgeStatus = OrderBadgeStatus.active;
        break;
      case OrderTab.upcoming:
        badgeStatus = OrderBadgeStatus.upcoming;
        break;
      case OrderTab.past:
        badgeStatus = OrderBadgeStatus.completed;
        break;
      case OrderTab.cancelled:
        badgeStatus = OrderBadgeStatus.cancelled;
        break;
    }

    final orderWithTabStatus = OrderItem(
      id: order.id,
      providerId: order.providerId,
      serviceName: order.serviceName,
      orderId: order.orderId,
      status: badgeStatus,
      scheduledTime: order.scheduledTime,
      location: order.location,
      technicianName: order.technicianName,
      technicianImageUrl: order.technicianImageUrl,
      price: order.price,
      rating: order.rating,
      cancelReason: order.cancelReason,
      paymentStatus: order.paymentStatus,
      paymentMethod: order.paymentMethod,
      providerPhoneNumber: order.providerPhoneNumber,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: AppColors.dropDownBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(orderWithTabStatus),
          const SizedBox(height: 12),
          _buildCardMeta(orderWithTabStatus),
          const SizedBox(height: 12),
          _buildCardTechnicianRow(orderWithTabStatus),
          const SizedBox(height: 12),
          if (orderWithTabStatus.rating != null) ...[
            _buildStarRating(orderWithTabStatus.rating!),
            const SizedBox(height: 12),
          ],
          _buildCardActions(orderWithTabStatus),
        ],
      ),
    );
  }

  Widget _buildCardHeader(OrderItem order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.serviceName,
                style: AppTextStyles.bodyMediumBold.copyWith(
                  color: AppColors.textDark,
                  fontFamily: AppTextStyles.fontFamilyPoppins,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                order.orderId,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontFamily: AppTextStyles.fontFamilyPoppins,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildStatusBadge(order.status),
      ],
    );
  }

  Widget _buildStatusBadge(OrderBadgeStatus status) {
    final Color bgColor;
    final Color textColor;
    switch (status) {
      case OrderBadgeStatus.active:
        bgColor = const Color(0xFFDBEAFE);
        textColor = AppColors.blue;
        break;
      case OrderBadgeStatus.upcoming:
        bgColor = const Color(0xFFFEF3C7);
        textColor = AppColors.warningText;
        break;
      case OrderBadgeStatus.completed:
        bgColor = AppColors.successSecondaryBg;
        textColor = AppColors.successText;
        break;
      case OrderBadgeStatus.cancelled:
        bgColor = const Color(0xFFFEE2E2);
        textColor = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: ShapeDecoration(
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.captionSmall.copyWith(
          color: textColor,
          fontFamily: AppTextStyles.fontFamilyPoppins,
        ),
      ),
    );
  }

  Widget _buildCardMeta(OrderItem order) {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/images/CalendarBlank.svg',
          width: 12,
          height: 12,
          colorFilter: const ColorFilter.mode(
            AppColors.textSecondary,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          order.scheduledTime,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontFamily: AppTextStyles.fontFamilyPoppins,
          ),
        ),
        const SizedBox(width: 14),
        SvgPicture.asset(
          'assets/images/pin_g.svg',
          width: 12,
          height: 12,
          colorFilter: const ColorFilter.mode(
            AppColors.textSecondary,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          order.location,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontFamily: AppTextStyles.fontFamilyPoppins,
          ),
        ),
      ],
    );
  }

  Widget _buildCardTechnicianRow(OrderItem order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const ShapeDecoration(
        shape: Border(
          top: BorderSide(width: 1, color: AppColors.inputBorder),
          bottom: BorderSide(width: 1, color: AppColors.inputBorder),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    image: order.technicianImageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(order.technicianImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: AppColors.inputBgSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: order.technicianImageUrl == null
                      ? const Icon(Icons.person,
                          size: 18, color: AppColors.textSecondary)
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  order.technicianName,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppTextStyles.fontFamilyPoppins,
                  ),
                ),
              ],
            ),
            Text(
              order.price,
              style: AppTextStyles.bodyMediumBold.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w800,
                fontFamily: AppTextStyles.fontFamilyPoppins,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      children: [
        ...List.generate(5, (i) {
          return SvgPicture.asset(
            i < rating.floor() ? 'assets/images/star.svg' : 'assets/images/star_edge.svg',
            width: 16,
            height: 16,
            colorFilter: const ColorFilter.mode(
              AppColors.star,
              BlendMode.srcIn,
            ),
          );
        }),
        const SizedBox(width: 8),
        Text(
          'Your rating',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCardActions(OrderItem order) {
    print(order.status);
    switch (order.status) {
      case OrderBadgeStatus.active:
        return _buildActiveActions(order);
      case OrderBadgeStatus.upcoming:
        return _buildUpcomingActions(order);
      case OrderBadgeStatus.completed:
        return _buildPastActions(order);
      case OrderBadgeStatus.cancelled:
        return _buildCancelledActions(order);
    }
  }

  Widget _buildActiveActions(OrderItem order) {
    return Row(
      children: [
        Expanded(
          child: _buildPrimaryButton(
            label: 'Track Order',
            onTap: () => context.push('/order_tracking',
                extra: order),
          ),
        ),
        const SizedBox(width: 8),
        _buildIconButton(
          icon: 'assets/images/phone.svg',
          onTap: () {
            final phone = order.providerPhoneNumber ?? '+919876543216';
            _makeCall(phone);
          },
        ),
      ],
    );
  }

  Widget _buildUpcomingActions(OrderItem order) {
    return Row(
      children: [
        Expanded(
          child: _buildSecondaryButton(
            label: 'Reschedule',
            onTap: () => RescheduleBottomSheet.show(context, order),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildOutlineButton(
            label: 'Cancel',
            onTap: () => CancelBottomSheet.show(context, order),
          ),
        ),
      ],
    );
  }

  Widget _buildPastActions(OrderItem order) {
    return Row(
      children: [
        Expanded(
          child: _buildPrimaryButton(
            label: 'Repeat Order',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 8),
        _buildIconButton(
          icon: 'assets/images/document.svg',
          onTap: () {
            context.push('/postpaid_payment_success', extra: order.id);
          },
        ),
      ],
    );
  }

  Widget _buildCancelledActions(OrderItem order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              'assets/images/cancel.svg',
              width: 14,
              height: 14,
              colorFilter: const ColorFilter.mode(
                AppColors.error,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Reason: ${order.cancelReason ?? 'No reason provided'}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _buildPrimaryButton(
            label: 'Rebook Service',
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: AppColors.onLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.onDark,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: AppColors.onLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.onDark,
          ),
        ),
      ),
    );
  }

  Widget _buildOutlineButton({
    required String label,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: AppColors.dropDownBorder),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.onLight,
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required String icon,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 44,
        decoration: ShapeDecoration(
          color: AppColors.textLight,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: AppColors.inputBorder),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Center(
          child: SvgPicture.asset(
            icon,
            width: 18,
            height: 18,
            colorFilter: const ColorFilter.mode(
              AppColors.onLight,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

}
