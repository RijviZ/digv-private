import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/core/widgets/app_filter_bar.dart';
import 'package:digv/core/widgets/app_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/dio_provider.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../home_discovery/data/models/service_category_model.dart';
import '../../../home_discovery/domain/entities/service_category_entity.dart';
import '../../../home_discovery/presentation/providers/service_categories_provider.dart';
import '../../../search/domain/entities/search_result.dart';
import '../../../search/presentation/providers/search_provider.dart';

class ServiceDetailsScreen extends ConsumerStatefulWidget {
  final String serviceItemId;
  final int initialQuantity;

  const ServiceDetailsScreen({
    super.key,
    required this.serviceItemId,
    this.initialQuantity = 1,
  });

  @override
  ConsumerState<ServiceDetailsScreen> createState() =>
      _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends ConsumerState<ServiceDetailsScreen> {
  late int _quantity;
  late String _currentServiceItemId;
  String? _selectedType;

  // Cached data for smooth transitions when switching types
  ServiceDetailsEntity? _lastLoadedDetails;
  List<String>? _overrideFeatures;
  String? _overridePrice;
  String? _overrideName;
  String? _overrideImage;
  String? _overrideDescription;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity > 0 ? widget.initialQuantity : 1;
    _currentServiceItemId = widget.serviceItemId;
  }

  String _formatPrice(ServiceDetailsEntity details) {
    final isNewItemLoaded = details.serviceItemId == _currentServiceItemId;
    final priceStr = (!isNewItemLoaded && _overridePrice != null)
        ? _overridePrice!
        : details.effectivePrice;

    final unitPrice = double.tryParse(priceStr) ?? 0.0;
    final total = unitPrice * _quantity;
    if (total == total.roundToDouble()) {
      return total.toInt().toString();
    }
    return total.toStringAsFixed(2);
  }

  bool _hasCustomPriceDiscount(ServiceDetailsEntity details) {
    final isNewItemLoaded = details.serviceItemId == _currentServiceItemId;
    if (!isNewItemLoaded && _overridePrice != null) return false;
    final customNum = double.tryParse(details.customPrice ?? '') ?? 0.0;
    final baseNum = double.tryParse(details.basePrice) ?? 0.0;
    return customNum > 0 && baseNum > customNum;
  }

  String _formatOriginalBasePrice(ServiceDetailsEntity details) {
    final baseNum = double.tryParse(details.basePrice) ?? 0.0;
    final total = baseNum * _quantity;
    if (total == total.roundToDouble()) {
      return total.toInt().toString();
    }
    return total.toStringAsFixed(2);
  }

  Future<CategoryItemEntity?> _findItemForType(
    String typeName,
    ServiceDetailsEntity details,
  ) async {
    // 1. Check cached categories from serviceCategoriesProvider
    List<ServiceCategoryEntity> categories =
        ref.read(serviceCategoriesProvider).asData?.value ?? [];

    if (categories.isEmpty) {
      try {
        categories = await ref.read(serviceCategoriesProvider.future);
      } catch (_) {}
    }

    ServiceCategoryEntity? category;
    if (details.serviceCategoryId != null && details.serviceCategoryId!.isNotEmpty) {
      for (final cat in categories) {
        if (cat.categoryId == details.serviceCategoryId) {
          category = cat;
          break;
        }
      }
    }
    if (category == null && details.serviceCategoryName != null && details.serviceCategoryName!.isNotEmpty) {
      final catNameLower = details.serviceCategoryName!.toLowerCase().trim();
      for (final cat in categories) {
        if (cat.name.toLowerCase().trim() == catNameLower) {
          category = cat;
          break;
        }
      }
    }

    // 2. Fallback: fetch category directly from backend if not found in cache
    if ((category == null || category.serviceTypes.isEmpty) &&
        details.serviceCategoryId != null &&
        details.serviceCategoryId!.isNotEmpty) {
      try {
        final dio = ref.read(dioProvider);
        final res = await dio.get('/service-categories/${details.serviceCategoryId}');
        if (res.statusCode == 200 && res.data['data'] != null) {
          category = ServiceCategoryModel.fromJson(res.data['data'] as Map<String, dynamic>);
        }
      } catch (e) {
        debugPrint('Could not fetch category ${details.serviceCategoryId}: $e');
      }
    }

    if (category == null) return null;

    final typeLower = typeName.toLowerCase().trim();
    CategoryTypeEntity? targetType;
    for (final t in category.serviceTypes) {
      if (t.name.toLowerCase().trim() == typeLower) {
        targetType = t;
        break;
      }
    }

    if (targetType == null || targetType.items.isEmpty) {
      return null;
    }

    // Match item by name
    final currentItemLower = details.serviceItemName.toLowerCase().trim();
    for (final item in targetType.items) {
      if (item.name.toLowerCase().trim() == currentItemLower) {
        return item;
      }
    }

    // Partial match
    for (final item in targetType.items) {
      final nameLower = item.name.toLowerCase().trim();
      if (nameLower.contains(currentItemLower) || currentItemLower.contains(nameLower)) {
        return item;
      }
    }

    // Fallback to first item of this type
    return targetType.items.first;
  }

  Future<void> _onServiceTypeSelected(
    String selectedName,
    ServiceDetailsEntity details,
  ) async {
    setState(() {
      _selectedType = selectedName;
    });

    final targetItem = await _findItemForType(selectedName, details);
    if (targetItem != null && mounted) {
      setState(() {
        _currentServiceItemId = targetItem.serviceItemId;
        _overrideFeatures = targetItem.features;
        _overridePrice = targetItem.effectivePrice;
        _overrideName = targetItem.name;
        _overrideImage = targetItem.imageUrl;
        _overrideDescription = targetItem.description;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(
      serviceDetailsProvider(_currentServiceItemId),
    );

    final currentDetails = detailsAsync.asData?.value;
    if (currentDetails != null && currentDetails.serviceItemId == _currentServiceItemId) {
      _lastLoadedDetails = currentDetails;
    }

    final details = currentDetails ?? _lastLoadedDetails;
    if (details != null) {
      return _buildContent(context, details, isLoading: detailsAsync.isLoading);
    }

    return detailsAsync.when(
      data: (d) {
        _lastLoadedDetails = d;
        return _buildContent(context, d);
      },
      loading: () => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const SafeArea(
          child: Column(
            children: [
              AppTopBar(title: 'Service Details'),
              Expanded(child: Center(child: CircularProgressIndicator())),
            ],
          ),
        ),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              const AppTopBar(title: 'Service Details'),
              Expanded(
                child: Center(
                  child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ServiceDetailsEntity details, {
    bool isLoading = false,
  }) {
    final isNewItemLoaded = details.serviceItemId == _currentServiceItemId;
    final displayName = isNewItemLoaded
        ? details.serviceItemName
        : (_overrideName ?? details.serviceItemName);
    final displayDescription = isNewItemLoaded
        ? details.serviceItemDescription
        : (_overrideDescription ?? details.serviceItemDescription);
    final displayImageUrl = isNewItemLoaded
        ? details.serviceItemImageUrl
        : (_overrideImage ?? details.serviceItemImageUrl);
    final displayFeatures = isNewItemLoaded
        ? details.whatsIncluded
        : (_overrideFeatures ?? details.whatsIncluded);

    final categories = ref.watch(serviceCategoriesProvider).asData?.value ?? [];
    ServiceCategoryEntity? currentCategory;
    if (details.serviceCategoryId != null && details.serviceCategoryId!.isNotEmpty) {
      for (final cat in categories) {
        if (cat.categoryId == details.serviceCategoryId) {
          currentCategory = cat;
          break;
        }
      }
    }
    if (currentCategory == null && details.serviceCategoryName != null && details.serviceCategoryName!.isNotEmpty) {
      final catNameLower = details.serviceCategoryName!.toLowerCase().trim();
      for (final cat in categories) {
        if (cat.name.toLowerCase().trim() == catNameLower) {
          currentCategory = cat;
          break;
        }
      }
    }

    final validSelectableTypes = details.selectableTypes.where((t) {
      if (!t.isActive) return false;
      if (currentCategory == null) return true;

      final typeLower = t.name.toLowerCase().trim();
      CategoryTypeEntity? matchedType;
      for (final type in currentCategory.serviceTypes) {
        if (type.serviceTypeId == t.serviceTypeId ||
            type.name.toLowerCase().trim() == typeLower) {
          matchedType = type;
          break;
        }
      }

      if (matchedType != null) {
        // Remove empty types
        if (matchedType.items.isEmpty) return false;

        // Keep current item's service type
        if (matchedType.serviceTypeId == details.serviceTypeId) return true;

        // For other service types, remove them unless they have a matching service variant
        final currentNameLower = details.serviceItemName.toLowerCase().trim();
        return matchedType.items.any((item) {
          final itemNameLower = item.name.toLowerCase().trim();
          return itemNameLower == currentNameLower ||
              itemNameLower.contains(currentNameLower) ||
              currentNameLower.contains(itemNameLower);
        });
      }
      return true;
    }).toList();

    final selectableTypeNames = validSelectableTypes
        .map((t) => t.name)
        .toList();

    SelectableTypeEntity? activeType;
    for (final t in validSelectableTypes) {
      if (t.serviceTypeId == details.serviceTypeId) {
        activeType = t;
        break;
      }
    }
    final activeTypeName = _selectedType ??
        (activeType != null && activeType.name.isNotEmpty
            ? activeType.name
            : (selectableTypeNames.isNotEmpty ? selectableTypeNames.first : ''));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AppTopBar(title: 'Service Details'),
            if (isLoading)
              const LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: Colors.transparent,
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 240,
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        image: DecorationImage(
                          image: displayImageUrl != null && displayImageUrl.isNotEmpty
                              ? NetworkImage(displayImageUrl)
                              : const AssetImage('assets/images/Container.png') as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                        gradient: LinearGradient(
                          begin: const Alignment(0.50, -0.00),
                          end: const Alignment(0.50, 1.00),
                          colors: [
                            Colors.black.withValues(alpha: 0.20),
                            Colors.black,
                          ],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            displayName,
                            style: AppTextStyles.h3.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              height: 1.40,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '₹${_formatPrice(details)}',
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.blue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (_hasCustomPriceDiscount(details)) ...[
                              const SizedBox(width: 6),
                              Text(
                                '₹${_formatOriginalBasePrice(details)}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Theme.of(context).colorScheme.secondary,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        SvgPicture.asset('assets/images/star.svg'),
                        const SizedBox(width: 6),
                        Text(
                          details.rating?.toStringAsFixed(1) ?? '0.0',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '· ${details.totalBookings} bookings · ${details.durationMinutes ?? 0} mins',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      displayDescription ??
                          'Professional service provided by our top-rated technicians.',
                      style: AppTextStyles.captionMedium.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    if (selectableTypeNames.length > 1) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Service Type',
                        style: AppTextStyles.titleLight.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AppFilterBar(
                        items: selectableTypeNames,
                        selectedItem: activeTypeName,
                        onSelected: (item) {
                          if (item != activeTypeName) {
                            _onServiceTypeSelected(item, details);
                          }
                        },
                        padding: EdgeInsets.zero,
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      'What\'s Included',
                      style: AppTextStyles.titleLight.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        height: 1.75,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 7),
                    if (displayFeatures.isNotEmpty)
                      ...displayFeatures.map(
                        (feature) => _includedItem(text: feature),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'Standard service inspection included',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      'Quantity',
                      style: AppTextStyles.titleLight.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildQuantitySelector(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: AppPrimaryButton(
            text: 'Continue to select technician',
            onTap: () {
              context.push(
                '/select_technician',
                extra: (_currentServiceItemId, _quantity),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      height: 40,
      width: 140,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (_quantity > 1) {
                  _quantity--;
                }
              });
            },
            child: Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.inputBgSecondaryDark
                    : AppColors.inputBgSecondary,
              ),
              child: Text(
                '–',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  height: 1.50,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                '$_quantity',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  height: 1.50,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                _quantity++;
              });
            },
            child: Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.inputBgSecondaryDark
                    : AppColors.inputBgSecondary,
              ),
              child: Text(
                '+',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  height: 1.50,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _includedItem({required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/images/checkmark-circle.svg',
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
