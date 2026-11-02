import 'package:digv/I10n/app_localizations.dart';
import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/features/disputes/domain/entities/dispute_entity.dart';
import 'package:digv/features/disputes/presentation/providers/disputes_provider.dart';
import 'package:digv/features/disputes/presentation/widgets/dispute_card.dart';
import 'package:digv/features/disputes/presentation/widgets/dispute_order_details_bottom_sheet.dart';
import 'package:digv/features/home_discovery/domain/entities/service_category_entity.dart';
import 'package:digv/features/home_discovery/presentation/providers/service_categories_provider.dart';
import 'package:digv/features/orders/domain/models/order_item.dart';
import 'package:digv/features/orders/presentation/providers/orders_provider.dart';
import 'package:digv/features/orders/presentation/widgets/cancel_bottom_sheet.dart';
import 'package:digv/features/orders/presentation/widgets/reschedule_bottom_sheet.dart';
import 'package:digv/features/search/data/repositories/search_repository_impl.dart';
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
  String? _selectedDisputeStatus;
  String? _rebookingOrderId;

  Future<void> _handleRebook(OrderItem order) async {
    if (_rebookingOrderId != null) return;
    setState(() => _rebookingOrderId = order.id);

    try {
      final orderQty = order.quantity > 0 ? order.quantity : 1;

      // 1. If order already has a valid serviceItemId, navigate immediately
      if (order.serviceItemId != null && order.serviceItemId!.isNotEmpty) {
        if (mounted) {
          context.push('/service_details', extra: (order.serviceItemId!, orderQty));
        }
        return;
      }

      // 2. Fetch service request details from backend
      Map<String, dynamic>? detail;
      try {
        final ordersRepo = ref.read(ordersRepositoryProvider);
        detail = await ordersRepo.getServiceRequestById(id: order.id);
      } catch (e) {
        debugPrint('Could not fetch service request detail: $e');
      }

      if (detail != null) {
        final resolvedItemId = detail['serviceItemId'] as String? ??
            detail['serviceItem']?['serviceItemId'] as String? ??
            detail['serviceItem']?['id'] as String? ??
            detail['service']?['serviceItemId'] as String? ??
            detail['service']?['id'] as String? ??
            detail['providerService']?['serviceItemId'] as String? ??
            detail['providerService']?['serviceId'] as String?;
        if (resolvedItemId != null && resolvedItemId.isNotEmpty) {
          if (mounted) {
            context.push('/service_details', extra: (resolvedItemId, orderQty));
          }
          return;
        }
      }

      final searchRepo = ref.read(searchRepositoryProvider);

      // 3. Load all available categories and items
      List<ServiceCategoryEntity> categories = [];
      try {
        categories = await ref.read(serviceCategoriesProvider.future);
      } catch (e) {
        debugPrint('Could not load categories: $e');
      }

      final allCategoryItems = <(ServiceCategoryEntity, CategoryItemEntity)>[];
      for (final cat in categories) {
        for (final item in cat.directItems) {
          allCategoryItems.add((cat, item));
        }
        for (final type in cat.serviceTypes) {
          for (final item in type.items) {
            allCategoryItems.add((cat, item));
          }
        }
      }

      // 4. PRIORITY 1: Match by exact category name AND service item name
      final targetCategoryName = order.categoryName ?? detail?['categoryName'] as String?;
      final targetItemName = (order.serviceName.isNotEmpty && order.serviceName != 'Service Request')
          ? order.serviceName
          : (detail?['serviceItemName'] as String? ?? '');

      if (targetItemName.isNotEmpty) {
        final targetLower = targetItemName.toLowerCase().trim();

        // 4a. Match category AND item name
        if (targetCategoryName != null && targetCategoryName.isNotEmpty) {
          final catLower = targetCategoryName.toLowerCase().trim();
          for (final (cat, item) in allCategoryItems) {
            if (cat.name.toLowerCase().trim() == catLower) {
              final itemNameLower = item.name.toLowerCase().trim();
              if (itemNameLower == targetLower ||
                  itemNameLower.contains(targetLower) ||
                  targetLower.contains(itemNameLower)) {
                if (mounted) {
                  context.push('/service_details', extra: (item.serviceItemId, orderQty));
                  return;
                }
              }
            }
          }
        }

        // 4b. Match exact item name across any category
        for (final (_, item) in allCategoryItems) {
          final itemNameLower = item.name.toLowerCase().trim();
          if (itemNameLower == targetLower) {
            if (mounted) {
              context.push('/service_details', extra: (item.serviceItemId, orderQty));
              return;
            }
          }
        }

        // 4c. Match partial item name across any category
        for (final (_, item) in allCategoryItems) {
          final itemNameLower = item.name.toLowerCase().trim();
          if (itemNameLower.contains(targetLower) || targetLower.contains(itemNameLower)) {
            if (mounted) {
              context.push('/service_details', extra: (item.serviceItemId, orderQty));
              return;
            }
          }
        }
      }

      // 5. Test if order.providerServiceId itself is a valid serviceItemId
      final providerServiceId = order.providerServiceId ??
          detail?['providerServiceId'] as String?;
      if (providerServiceId != null && providerServiceId.isNotEmpty) {
        for (final (_, item) in allCategoryItems) {
          if (item.serviceItemId == providerServiceId) {
            if (mounted) {
              context.push('/service_details', extra: (item.serviceItemId, orderQty));
              return;
            }
          }
        }

        try {
          await searchRepo.getServiceDetails(providerServiceId);
          if (mounted) {
            context.push('/service_details', extra: (providerServiceId, orderQty));
            return;
          }
        } catch (_) {}
      }

      // 6. Build list of candidate search keywords and phrases
      final candidateTerms = <String>[];
      if (order.serviceName.isNotEmpty && order.serviceName != 'Service Request') {
        candidateTerms.add(order.serviceName);
        for (final w in order.serviceName.split(' ')) {
          if (w.trim().length >= 2 && !candidateTerms.contains(w.trim())) {
            candidateTerms.add(w.trim());
          }
        }
      }

      final detailTitle = detail?['serviceTitle'] as String? ??
          detail?['serviceName'] as String? ??
          detail?['title'] as String? ??
          detail?['name'] as String? ??
          detail?['providerService']?['name'] as String? ??
          detail?['providerService']?['serviceName'] as String? ??
          detail?['providerService']?['serviceTitle'] as String?;
      if (detailTitle != null && detailTitle.isNotEmpty && !candidateTerms.contains(detailTitle)) {
        candidateTerms.add(detailTitle);
        for (final w in detailTitle.split(' ')) {
          if (w.trim().length >= 2 && !candidateTerms.contains(w.trim())) {
            candidateTerms.add(w.trim());
          }
        }
      }

      final desc = order.description ?? detail?['description'] as String?;
      if (desc != null && desc.isNotEmpty) {
        final m1 = RegExp(r'Need service booking for (.*?)\.?', caseSensitive: false).firstMatch(desc);
        if (m1 != null && m1.group(1)?.trim().isNotEmpty == true) {
          candidateTerms.add(m1.group(1)!.trim());
        }
        final m2 = RegExp(r'Need (.*?) for (.*?)\.?', caseSensitive: false).firstMatch(desc);
        if (m2 != null && m2.group(1)?.trim().isNotEmpty == true) {
          candidateTerms.add(m2.group(1)!.trim());
        }
        final m3 = RegExp(r'Need (.*?)\.?', caseSensitive: false).firstMatch(desc);
        if (m3 != null && m3.group(1)?.trim().isNotEmpty == true) {
          candidateTerms.add(m3.group(1)!.trim());
        }
        // Extract significant words from description
        for (final w in desc.replaceAll(RegExp(r'[^\w\s]'), '').split(' ')) {
          final clean = w.trim();
          if (clean.length >= 2 &&
              !['need', 'for', 'the', 'and', 'with', 'service', 'servicing', 'booking'].contains(clean.toLowerCase()) &&
              !candidateTerms.contains(clean)) {
            candidateTerms.add(clean);
          }
        }
      }

      // 7. Try globalSearch with candidate terms
      for (final term in candidateTerms) {
        try {
          final res = await searchRepo.globalSearch(q: term, limit: 5);
          if (res.services.isNotEmpty) {
            final matching = res.services.firstWhere(
              (s) =>
                  s.serviceItemName.toLowerCase().contains(term.toLowerCase()) ||
                  term.toLowerCase().contains(s.serviceItemName.toLowerCase()),
              orElse: () => res.services.first,
            );
            if (mounted) {
              context.push('/service_details', extra: (matching.serviceItemId, orderQty));
              return;
            }
          }
        } catch (_) {}
      }

      // 8. Match by category name
      for (final cat in categories) {
        final catLower = cat.name.toLowerCase().trim();
        for (final term in candidateTerms) {
          final termLower = term.toLowerCase().trim();
          if (catLower == termLower || catLower.contains(termLower) || termLower.contains(catLower)) {
            final itemsForCat = allCategoryItems.where((pair) => pair.$1.categoryId == cat.categoryId).map((pair) => pair.$2).toList();
            if (itemsForCat.isNotEmpty) {
              final targetPrice = order.unitPrice ?? double.tryParse(order.price.replaceAll(RegExp(r'[^\d.]'), ''));
              CategoryItemEntity selectedItem = itemsForCat.first;
              if (targetPrice != null) {
                final priceMatched = itemsForCat.where((i) {
                  final p = double.tryParse(i.basePrice);
                  return p != null && (p - targetPrice).abs() < 50;
                }).toList();
                if (priceMatched.isNotEmpty) {
                  selectedItem = priceMatched.first;
                }
              }
              if (mounted) {
                context.push('/service_details', extra: (selectedItem.serviceItemId, orderQty));
                return;
              }
            }
          }
        }
      }

      // 9. Match by provider association
      final providerId = order.providerId ?? detail?['providerId'] as String?;
      if (providerId != null && providerId.isNotEmpty) {
        for (final (_, item) in allCategoryItems) {
          try {
            final providers = await searchRepo.getServiceProviders(item.serviceItemId);
            if (providers.any((p) => p.providerId == providerId || (providerServiceId != null && p.providerServiceId == providerServiceId))) {
              if (mounted) {
                context.push('/service_details', extra: (item.serviceItemId, orderQty));
                return;
              }
            }
          } catch (_) {}
        }
      }

      // 10. Match by order unit price or total price against all category items
      final targetPrice = order.unitPrice ?? double.tryParse(order.price.replaceAll(RegExp(r'[^\d.]'), ''));
      if (targetPrice != null && allCategoryItems.isNotEmpty) {
        final priceMatched = allCategoryItems.where((pair) {
          final p = double.tryParse(pair.$2.basePrice);
          return p != null && (p - targetPrice).abs() < 50;
        }).toList();
        if (priceMatched.isNotEmpty) {
          if (mounted) {
            context.push('/service_details', extra: (priceMatched.first.$2.serviceItemId, orderQty));
            return;
          }
        }
      }

      // 11. Ultimate fallback
      if (allCategoryItems.isNotEmpty) {
        if (mounted) {
          context.push('/service_details', extra: (allCategoryItems.first.$2.serviceItemId, orderQty));
          return;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to load service details. Please check your internet connection.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _rebookingOrderId = null);
      }
    }
  }

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

  String _tabLabel(OrderTab tab, BuildContext context) {
    switch (tab) {
      case OrderTab.active:
        return 'Active';
      case OrderTab.upcoming:
        return 'Upcoming';
      case OrderTab.past:
        return 'Completed';
      case OrderTab.disputes:
        return 'Disputes';
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
          SafeArea(bottom: false, child: _buildTopBar(context)),
          _buildTabBar(),
          Expanded(
            child: _selectedTab == OrderTab.disputes
                ? _buildDisputesView()
                : _buildOrderList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Text(
        l10n.my_orders_title,
        style: AppTextStyles.h3.copyWith(
          color: theme.colorScheme.onSurface,
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
      case OrderTab.disputes:
        return null;
    }
  }

  Widget _buildTabBar() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                          ? (isDarkMode ? Colors.white : Theme.of(context).colorScheme.primary)
                          : Colors.transparent,
                    ),
                  ),
                ),
                child: Text(
                  _tabLabel(tab, context),
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isSelected
                        ? (isDarkMode ? Colors.white : Theme.of(context).colorScheme.primary)
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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
                    'No ${_tabLabel(_selectedTab, context).toLowerCase()} orders',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
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
            separatorBuilder: (_, _) => const SizedBox(height: 12),
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

  Widget _buildDisputesView() {
    final disputesAsync =
        ref.watch(myDisputesFilteredProvider(_selectedDisputeStatus));

    return Column(
      children: [
        _buildDisputesFilterChips(),
        Expanded(
          child: disputesAsync.when(
            data: (disputes) {
              if (disputes.isEmpty) {
                return RefreshIndicator(
                  color: Theme.of(context).primaryColor,
                  backgroundColor: Colors.white,
                  onRefresh: () async {
                    ref.invalidate(
                        myDisputesFilteredProvider(_selectedDisputeStatus));
                    ref.invalidate(myDisputesProvider);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      height: 380,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.gavel_outlined,
                            size: 54,
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No disputes found',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'You don\'t have any disputes in this category',
                            style: AppTextStyles.captionMedium.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                color: Theme.of(context).primaryColor,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  ref.invalidate(
                      myDisputesFilteredProvider(_selectedDisputeStatus));
                  ref.invalidate(myDisputesProvider);
                },
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: disputes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return DisputeCard(dispute: disputes[index]);
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => RefreshIndicator(
              color: Theme.of(context).primaryColor,
              backgroundColor: Colors.white,
              onRefresh: () async {
                ref.invalidate(
                    myDisputesFilteredProvider(_selectedDisputeStatus));
                ref.invalidate(myDisputesProvider);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: 380,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Failed to load disputes: $err',
                        style: const TextStyle(color: AppColors.error),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          ref.invalidate(
                              myDisputesFilteredProvider(_selectedDisputeStatus));
                          ref.invalidate(myDisputesProvider);
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisputesFilterChips() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const filterOptions = [
      (null, 'All'),
      ('OPENED', 'Opened'),
      ('UNDER_REVIEW', 'Under Review'),
      ('RESOLVED', 'Resolved'),
      ('REJECTED', 'Rejected'),
    ];

    return Container(
      height: 36,
      margin: const EdgeInsets.only(top: 14, bottom: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filterOptions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = filterOptions[index];
          final isSelected = _selectedDisputeStatus == item.$1;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDisputeStatus = item.$1);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? Colors.white : Colors.black)
                    : (isDark ? Colors.white10 : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? (isDark ? Colors.white : Colors.black)
                      : (isDark ? Colors.white24 : Colors.grey.shade300),
                  width: 1.0,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                item.$2,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? (isDark ? Colors.black : Colors.white)
                      : (isDark ? Colors.white70 : Colors.black87),
                  fontFamily: AppTextStyles.fontFamily,
                ),
              ),
            ),
          );
        },
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
      case OrderTab.disputes:
        badgeStatus = OrderBadgeStatus.active;
        break;
    }

    final disputesMap = ref.watch(disputesMapProvider);
    final dispute = disputesMap[order.id] ?? disputesMap[order.orderId];

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
      reviews: order.reviews,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Theme.of(context).dividerColor),
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
          if (dispute != null) ...[
            _buildDisputedOrderButton(dispute, orderWithTabStatus),
          ] else ...[
            _buildCardActions(orderWithTabStatus),
          ],
        ],
      ),
    );
  }

  Widget _buildDisputedOrderButton(DisputeEntity dispute, OrderItem order) {
    const orangeColor = Color(0xFFD9531E);
    return InkWell(
      onTap: () {
        DisputeOrderDetailsBottomSheet.show(
          context,
          dispute: dispute,
          order: order,
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        height: 44,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1.5, color: orangeColor),
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.gavel_rounded,
              color: orangeColor,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Disputed #${dispute.displayDisputeNo} (${dispute.status.label.toUpperCase()})',
              style: const TextStyle(
                color: orangeColor,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                fontFamily: AppTextStyles.fontFamily,
              ),
            ),
          ],
        ),
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
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFamily: AppTextStyles.fontFamilyPoppins,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                order.orderId,
                style: AppTextStyles.labelMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppTextStyles.fontFamilyPoppins,
                  ),
                ),
              ],
            ),
            Text(
              order.price,
              style: AppTextStyles.bodyMediumBold.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
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
            label: AppLocalizations.of(context)!.track_order_btn,
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
            isLoading: _rebookingOrderId == order.id,
            onTap: () => _handleRebook(order),
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
              child: _CancelledReasonText(order: order),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _buildPrimaryButton(
            label: 'Rebook Service',
            isLoading: _rebookingOrderId == order.id,
            onTap: () => _handleRebook(order),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: AppColors.onLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.onDark),
                  ),
                ),
              )
            : Text(
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

class _CancelledReasonText extends ConsumerWidget {
  final OrderItem order;

  const _CancelledReasonText({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reason = order.cancelReason?.trim();
    if (reason != null && reason.isNotEmpty) {
      return Text(
        'Reason: $reason',
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.error,
        ),
      );
    }

    // Fallback: look up in tracking logs if cancelReason was not in order item
    final trackingAsync = ref.watch(orderTrackingProvider(order.id));

    return trackingAsync.when(
      data: (trackingData) {
        String? foundReason;
        for (final log in trackingData.logs.reversed) {
          final action = log.action.toUpperCase();
          final newStatus = log.newStatus?.toUpperCase() ?? '';
          if ((action.contains('CANCEL') ||
                  action.contains('REJECT') ||
                  newStatus == 'CANCELLED' ||
                  newStatus == 'REJECTED') &&
              log.note.trim().isNotEmpty) {
            foundReason = log.note.trim();
            break;
          }
        }

        return Text(
          'Reason: ${foundReason ?? 'No reason provided'}',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.error,
          ),
        );
      },
      loading: () => Text(
        'Reason: Loading...',
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.error,
        ),
      ),
      error: (_, _) => Text(
        'Reason: No reason provided',
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.error,
        ),
      ),
    );
  }
}

