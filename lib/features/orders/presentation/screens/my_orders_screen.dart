import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/features/orders/domain/models/order_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  OrderTab _selectedTab = OrderTab.active;

  final Map<OrderTab, List<OrderItem>> _ordersByTab = {
    OrderTab.active: [
      const OrderItem(
        id: '1',
        serviceName: 'AC Regular Service',
        orderId: 'ORD-7845',
        status: OrderBadgeStatus.active,
        scheduledTime: 'Today, 3:30 PM',
        location: 'Home',
        technicianName: 'Arjun Kumar',
        technicianImageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/9e/Placeholder_Person.jpg',
        price: '₹199',
      ),
      const OrderItem(
        id: '2',
        serviceName: 'AC Express Service',
        orderId: 'ORD-7846',
        status: OrderBadgeStatus.active,
        scheduledTime: 'Today, 4:15 PM',
        location: 'Work',
        technicianName: 'Meera Singh',
        technicianImageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/9e/Placeholder_Person.jpg',
        price: '₹299',
      ),
      const OrderItem(
        id: '3',
        serviceName: 'AC Premium Service',
        orderId: 'ORD-7847',
        status: OrderBadgeStatus.active,
        scheduledTime: 'Today, 2:00 PM',
        location: 'Gym',
        technicianName: 'Rahul Verma',
        technicianImageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/9e/Placeholder_Person.jpg',
        price: '₹399',
      ),
    ],
    OrderTab.upcoming: [
      const OrderItem(
        id: '4',
        serviceName: 'Full Home Deep Clean',
        orderId: 'ORD-7832',
        status: OrderBadgeStatus.upcoming,
        scheduledTime: 'Tomorrow, 10:00 AM',
        location: 'Home',
        technicianName: 'Karim Ali',
        technicianImageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/9e/Placeholder_Person.jpg',
        price: '₹589',
      ),
      const OrderItem(
        id: '5',
        serviceName: 'Full Home Deep Clean',
        orderId: 'ORD-7832',
        status: OrderBadgeStatus.upcoming,
        scheduledTime: 'Tomorrow, 10:00 AM',
        location: 'Home',
        technicianName: 'Karim Ali',
        technicianImageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/9e/Placeholder_Person.jpg',
        price: '₹589',
      ),
    ],
    OrderTab.past: [
      const OrderItem(
        id: '6',
        serviceName: 'Tap Repair',
        orderId: 'ORD-7807',
        status: OrderBadgeStatus.completed,
        scheduledTime: '20 Feb 2025, 11:00 AM',
        location: 'Home',
        technicianName: 'Suresh Rao',
        technicianImageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/9e/Placeholder_Person.jpg',
        price: '₹199',
        rating: 5,
      ),
      const OrderItem(
        id: '7',
        serviceName: 'Replace Battery',
        orderId: 'ORD-7802',
        status: OrderBadgeStatus.pending,
        scheduledTime: '21 Feb 2025, 02:30 PM',
        location: 'Office',
        technicianName: 'Anita Shah',
        technicianImageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/9e/Placeholder_Person.jpg',
        price: '₹1500',
        rating: 5,
      ),
      const OrderItem(
        id: '8',
        serviceName: 'Screen Replacement',
        orderId: 'ORD-7798',
        status: OrderBadgeStatus.inProgress,
        scheduledTime: '18 Feb 2025, 01:00 PM',
        location: 'Home',
        technicianName: 'Priya Nair',
        technicianImageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/9e/Placeholder_Person.jpg',
        price: '₹799',
        rating: 4,
      ),
      const OrderItem(
        id: '9',
        serviceName: 'Wiring Repair',
        orderId: 'ORD-7790',
        status: OrderBadgeStatus.completed,
        scheduledTime: '15 Feb 2025, 03:00 PM',
        location: 'Office',
        technicianName: 'Vijay Kumar',
        technicianImageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/9e/Placeholder_Person.jpg',
        price: '₹349',
        rating: 4,
      ),
      const OrderItem(
        id: '10',
        serviceName: 'AC Deep Cleaning',
        orderId: 'ORD-7785',
        status: OrderBadgeStatus.completed,
        scheduledTime: '12 Feb 2025, 11:30 AM',
        location: 'Home',
        technicianName: 'Arjun Kumar',
        technicianImageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/9e/Placeholder_Person.jpg',
        price: '₹299',
        rating: 5,
      ),
      const OrderItem(
        id: '11',
        serviceName: 'Drain Cleaning',
        orderId: 'ORD-7776',
        status: OrderBadgeStatus.completed,
        scheduledTime: '10 Feb 2025, 09:00 AM',
        location: 'Home',
        technicianName: 'Meera Singh',
        technicianImageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/9e/Placeholder_Person.jpg',
        price: '₹249',
        rating: 5,
      ),
      const OrderItem(
        id: '12',
        serviceName: 'Fan Installation',
        orderId: 'ORD-7765',
        status: OrderBadgeStatus.completed,
        scheduledTime: '08 Feb 2025, 02:00 PM',
        location: 'Home',
        technicianName: 'Rahul Verma',
        technicianImageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/9e/Placeholder_Person.jpg',
        price: '₹199',
        rating: 4,
      ),
      const OrderItem(
        id: '13',
        serviceName: 'Pipe Repair',
        orderId: 'ORD-7754',
        status: OrderBadgeStatus.completed,
        scheduledTime: '05 Feb 2025, 10:00 AM',
        location: 'Work',
        technicianName: 'Karim Ali',
        technicianImageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/9e/Placeholder_Person.jpg',
        price: '₹299',
        rating: 4,
      ),
      const OrderItem(
        id: '14',
        serviceName: 'Home Cleaning',
        orderId: 'ORD-7743',
        status: OrderBadgeStatus.completed,
        scheduledTime: '02 Feb 2025, 09:30 AM',
        location: 'Home',
        technicianName: 'Anita Shah',
        technicianImageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/9e/Placeholder_Person.jpg',
        price: '₹399',
        rating: 5,
      ),
      const OrderItem(
        id: '15',
        serviceName: 'AC Installation',
        orderId: 'ORD-7730',
        status: OrderBadgeStatus.completed,
        scheduledTime: '28 Jan 2025, 01:00 PM',
        location: 'Home',
        technicianName: 'Suresh Rao',
        technicianImageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/9e/Placeholder_Person.jpg',
        price: '₹899',
        rating: 5,
      ),
    ],
    OrderTab.cancelled: [
      const OrderItem(
        id: '16',
        serviceName: 'Fan Installation',
        orderId: 'ORD-7786',
        status: OrderBadgeStatus.cancelled,
        scheduledTime: '15 Feb 2025, 2:00 PM',
        location: 'Home',
        technicianName: 'Arjun Kumar',
        technicianImageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/9e/Placeholder_Person.jpg',
        price: '₹199',
      ),
    ],
  };

  final Map<OrderTab, int> _tabCounts = {
    OrderTab.active: 3,
    OrderTab.upcoming: 2,
    OrderTab.past: 10,
    OrderTab.cancelled: 1,
  };

  String _tabLabel(OrderTab tab) {
    switch (tab) {
      case OrderTab.active:
        return 'Active';
      case OrderTab.upcoming:
        return 'Upcoming';
      case OrderTab.past:
        return 'Past';
      case OrderTab.cancelled:
        return 'Cancelled';
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

  Widget _buildTabBar() {
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
            final count = _tabCounts[tab] ?? 0;
            return GestureDetector(
              onTap: () => setState(() => _selectedTab = tab),
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
    final orders = _ordersByTab[_selectedTab] ?? [];
    if (orders.isEmpty) {
      return Center(
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
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildOrderCard(orders[index]);
      },
    );
  }

  Widget _buildOrderCard(OrderItem order) {
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
          _buildCardHeader(order),
          const SizedBox(height: 12),
          _buildCardMeta(order),
          const SizedBox(height: 12),
          _buildCardTechnicianRow(order),
          const SizedBox(height: 12),
          if (order.rating != null) ...[
            _buildStarRating(order.rating!),
            const SizedBox(height: 12),
          ],
          _buildCardActions(order),
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
      case OrderBadgeStatus.inProgress:
        bgColor = const Color(0xFFEDE9FE);
        textColor = const Color(0xFF7C3AED);
        break;
      case OrderBadgeStatus.pending:
        bgColor = const Color(0xFFFEF3C7);
        textColor = AppColors.warningText;
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
    switch (order.status) {
      case OrderBadgeStatus.active:
        return _buildActiveActions(order);
      case OrderBadgeStatus.upcoming:
        return _buildUpcomingActions(order);
      case OrderBadgeStatus.completed:
      case OrderBadgeStatus.inProgress:
      case OrderBadgeStatus.pending:
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
          onTap: () {},
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
            onTap: () {},
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildOutlineButton(
            label: 'Cancel',
            onTap: () {},
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
          onTap: () {},
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
            Text(
              'Reason: Technician unavailable',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.error,
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
