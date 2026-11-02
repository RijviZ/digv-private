import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/core/widgets/app_top_bar.dart';
import 'package:digv/features/home_discovery/presentation/providers/service_categories_provider.dart';
import 'package:digv/features/search/domain/entities/search_result.dart';
import 'package:digv/features/search/presentation/providers/search_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class _ServiceListItem {
  final String serviceItemId;
  final String name;
  final String categoryId;
  final String categoryName;
  final String? serviceTypeName;
  final String? description;
  final String basePrice;
  final String? customPrice;
  final String? startingPrice;
  final String? imageUrl;
  final int? durationMinutes;
  final double? rating;
  final int totalBookings;
  final int availableProvidersCount;

  _ServiceListItem({
    required this.serviceItemId,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    this.serviceTypeName,
    this.description,
    required this.basePrice,
    this.customPrice,
    this.startingPrice,
    this.imageUrl,
    this.durationMinutes,
    this.rating,
    this.totalBookings = 0,
    this.availableProvidersCount = 0,
  });

  String get displayPrice {
    final customNum = double.tryParse(customPrice ?? '') ?? 0.0;
    if (customNum > 0) {
      if (customNum == customNum.roundToDouble()) {
        return customNum.toInt().toString();
      }
      return customNum.toStringAsFixed(2);
    }
    final baseNum = double.tryParse(basePrice) ?? 0.0;
    if (baseNum > 0) {
      if (baseNum == baseNum.roundToDouble()) {
        return baseNum.toInt().toString();
      }
      return baseNum.toStringAsFixed(2);
    }
    final startNum = double.tryParse(startingPrice ?? '');
    final price = (startNum != null && startNum > 0) ? startNum : baseNum;
    if (price == price.roundToDouble()) {
      return price.toInt().toString();
    }
    return price.toStringAsFixed(2);
  }
}

class ServicesListScreen extends ConsumerStatefulWidget {
  final String? initialCategoryId;
  final String? initialQuery;

  const ServicesListScreen({
    super.key,
    this.initialCategoryId,
    this.initialQuery,
  });

  @override
  ConsumerState<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends ConsumerState<ServicesListScreen> {
  late final TextEditingController _searchController;
  late String _selectedCategoryId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId ?? 'ALL';
    _searchQuery = widget.initialQuery ?? '';
    _searchController = TextEditingController(text: _searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(serviceCategoriesProvider);
    final searchAsync = ref.watch(searchResultsProvider(const SearchFilters()));

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AppTopBar(title: 'All Services'),
            _buildSearchBox(context, isDark),
            _buildCategoryTabs(categoriesAsync, isDark),
            const SizedBox(height: 8),
            Expanded(
              child: categoriesAsync.when(
                data: (categories) {
                  final searchMap = searchAsync.maybeWhen(
                    data: (searchResponse) => {
                      for (final s in searchResponse.services) s.serviceItemId: s,
                    },
                    orElse: () => <String, SearchServiceItemEntity>{},
                  );

                  final allItems = <_ServiceListItem>[];
                  final seenIds = <String>{};

                  for (final cat in categories.where((c) => c.isActive)) {
                    for (final item in cat.directItems.where((i) => i.isActive)) {
                      if (seenIds.add(item.serviceItemId)) {
                        final searchItem = searchMap[item.serviceItemId];
                        allItems.add(
                          _ServiceListItem(
                            serviceItemId: item.serviceItemId,
                            name: item.name,
                            categoryId: cat.categoryId,
                            categoryName: cat.name,
                            description: item.description,
                            basePrice: item.basePrice,
                            customPrice: item.customPrice ?? searchItem?.customPrice,
                            startingPrice: item.startingPrice,
                            imageUrl: item.imageUrl,
                            durationMinutes: item.durationMinutes,
                            rating: searchItem?.rating ?? item.rating,
                            totalBookings: searchItem != null && searchItem.totalBookings > 0
                                ? searchItem.totalBookings
                                : (item.totalBookings ?? 0),
                            availableProvidersCount: searchItem?.availableProvidersCount ?? 0,
                          ),
                        );
                      }
                    }

                    for (final type in cat.serviceTypes.where((t) => t.isActive)) {
                      for (final item in type.items.where((i) => i.isActive)) {
                        if (seenIds.add(item.serviceItemId)) {
                          final searchItem = searchMap[item.serviceItemId];
                          allItems.add(
                            _ServiceListItem(
                              serviceItemId: item.serviceItemId,
                              name: item.name,
                              categoryId: cat.categoryId,
                              categoryName: cat.name,
                              serviceTypeName: type.name,
                              description: item.description,
                              basePrice: item.basePrice,
                              customPrice: item.customPrice ?? searchItem?.customPrice,
                              startingPrice: item.startingPrice,
                              imageUrl: item.imageUrl,
                              durationMinutes: item.durationMinutes,
                              rating: searchItem?.rating ?? item.rating,
                              totalBookings: searchItem != null && searchItem.totalBookings > 0
                                  ? searchItem.totalBookings
                                  : (item.totalBookings ?? 0),
                              availableProvidersCount: searchItem?.availableProvidersCount ?? 0,
                            ),
                          );
                        }
                      }
                    }
                  }

                  // Also append any search items not already included
                  searchAsync.whenData((searchResponse) {
                    for (final s in searchResponse.services) {
                      if (seenIds.add(s.serviceItemId)) {
                        allItems.add(
                          _ServiceListItem(
                            serviceItemId: s.serviceItemId,
                            name: s.serviceItemName,
                            categoryId: s.serviceCategoryId ?? '',
                            categoryName: s.serviceCategoryName ?? '',
                            serviceTypeName: s.serviceTypeName,
                            description: s.serviceItemDescription,
                            basePrice: s.basePrice,
                            customPrice: s.customPrice,
                            startingPrice: s.startingPrice,
                            imageUrl: s.serviceItemImageUrl,
                            durationMinutes: s.durationMinutes,
                            rating: s.rating,
                            totalBookings: s.totalBookings,
                            availableProvidersCount: s.availableProvidersCount,
                          ),
                        );
                      }
                    }
                  });

                  // Filter by Category
                  var filtered = allItems;
                  if (_selectedCategoryId != 'ALL') {
                    filtered = filtered
                        .where((item) => item.categoryId == _selectedCategoryId)
                        .toList();
                  }

                  // Filter by Search Query
                  if (_searchQuery.trim().isNotEmpty) {
                    final queryLower = _searchQuery.trim().toLowerCase();
                    filtered = filtered.where((item) {
                      final nameMatch = item.name.toLowerCase().contains(queryLower);
                      final catMatch = item.categoryName.toLowerCase().contains(queryLower);
                      final typeMatch = item.serviceTypeName?.toLowerCase().contains(queryLower) ?? false;
                      final descMatch = item.description?.toLowerCase().contains(queryLower) ?? false;
                      return nameMatch || catMatch || typeMatch || descMatch;
                    }).toList();
                  }

                  if (filtered.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildServiceCard(context, filtered[index], isDark);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('Failed to load services: $e'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox(BuildContext context, bool isDark) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.inputBgSecondaryDark : AppColors.inputBgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.inputBorderDark : AppColors.inputBorder,
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search services...',
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.secondary,
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(
    AsyncValue<List<dynamic>> categoriesAsync,
    bool isDark,
  ) {
    return categoriesAsync.maybeWhen(
      data: (categories) {
        final activeCategories = categories.where((c) => c.isActive).toList();
        if (activeCategories.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: activeCategories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                final isSelected = _selectedCategoryId == 'ALL';
                return _buildFilterChip(
                  label: 'All',
                  isSelected: isSelected,
                  isDark: isDark,
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = 'ALL';
                    });
                  },
                );
              }

              final cat = activeCategories[index - 1];
              final isSelected = _selectedCategoryId == cat.categoryId;

              return _buildFilterChip(
                label: cat.name,
                isSelected: isSelected,
                isDark: isDark,
                onTap: () {
                  setState(() {
                    _selectedCategoryId = cat.categoryId;
                  });
                },
              );
            },
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    _ServiceListItem item,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        context.push('/service_details', extra: item.serviceItemId);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 90,
                height: 90,
                child: (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                    ? Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/images/Container.png',
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        'assets/images/Container.png',
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category tag
                  Text(
                    item.serviceTypeName != null && item.serviceTypeName!.isNotEmpty
                        ? '${item.categoryName} · ${item.serviceTypeName}'
                        : item.categoryName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Name
                  Text(
                    item.name,
                    style: AppTextStyles.bodyMediumBold.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Ratings & bookings
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        item.rating != null ? item.rating!.toStringAsFixed(1) : '0.0',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '· ${item.totalBookings} bookings',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      if (item.durationMinutes != null) ...[
                        Text(
                          ' · ${item.durationMinutes}m',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Price and Book Now button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'from ₹ ${item.displayPrice}',
                        style: AppTextStyles.bodyMediumBold.copyWith(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.push('/service_details', extra: item.serviceItemId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56,
            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No services found',
            style: AppTextStyles.h3.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try selecting a different category or adjusting your search.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
