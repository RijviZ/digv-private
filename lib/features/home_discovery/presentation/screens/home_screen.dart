import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/features/auth/presentation/providers/auth_provider.dart';
import 'package:digv/features/home_discovery/presentation/domain/quick_service_item.dart';
import 'package:digv/features/home_discovery/presentation/providers/service_categories_provider.dart';
import 'package:digv/features/home_discovery/presentation/widgets/location_dropdown_bottom_sheet.dart';
import 'package:digv/features/search/domain/entities/search_result.dart';
import 'package:digv/features/search/presentation/providers/search_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedCategoryIndex = 0;
  int _selectedSubTypeIndex = 0;
  late final PageController _promoBannerController;
  int _currentBannerPage = 0;

  final List<Map<String, String>> _promoBanners = [
    {'title': 'First Service 10% OFF', 'subtitle': 'New user exclusive offer'},
    {
      'title': 'Refer & Earn',
      'subtitle': 'Invite your friends and earn rewards',
    },
    {'title': 'Free Inspection', 'subtitle': 'Book your service now'},
    {'title': 'Flash Sale!', 'subtitle': 'Grab your discount today'},
  ];

  // _serviceCards removed to use live data from searchResultsProvider

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<QuickServiceItem> _quickServices = [
    const QuickServiceItem(label: 'AC Regular Service', price: '₹199'),
    const QuickServiceItem(label: 'Electrical Wiring', price: '₹199'),
    const QuickServiceItem(label: 'Plumbing Materials', price: '1500'),
    const QuickServiceItem(label: 'Roofing Materials', price: '₹3200'),
  ];

  @override
  void initState() {
    super.initState();
    _promoBannerController = PageController();
  }

  @override
  void dispose() {
    _promoBannerController.dispose();
    _searchController.dispose();
    super.dispose();
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBox(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(profileProvider);
                  ref.invalidate(serviceCategoriesProvider);
                  ref.invalidate(searchResultsProvider);
                  
                  try {
                    await Future.wait([
                      ref.read(profileProvider.future),
                      ref.read(serviceCategoriesProvider.future),
                    ]);
                  } catch (_) {}
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      if (_searchQuery.isNotEmpty)
                        _buildSearchResults()
                      else ...[
                        _buildExploreSection(),
                        _buildServicesForYouSection(),
                        _buildQuickServicesSection(),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    
    final displayAvatar = profileAsync.when(
      data: (user) => (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) 
          ? user.avatarUrl! 
          : "https://upload.wikimedia.org/wikipedia/commons/9/9e/Placeholder_Person.jpg",
      loading: () => "https://upload.wikimedia.org/wikipedia/commons/9/9e/Placeholder_Person.jpg",
      error: (_, __) => "https://upload.wikimedia.org/wikipedia/commons/9/9e/Placeholder_Person.jpg",
    );

    final selectedLocation = ref.watch(selectedLocationProvider);

    final locationText = selectedLocation != null
        ? ((selectedLocation.addressLine != null && selectedLocation.addressLine!.isNotEmpty)
            ? selectedLocation.addressLine!
            : (selectedLocation.city ?? 'Location not set'))
        : profileAsync.when(
            data: (_) => 'Location not set',
            loading: () => 'Loading...',
            error: (_, __) => 'Error loading',
          );

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              image: DecorationImage(
                image: NetworkImage(displayAvatar),
                fit: BoxFit.cover,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (context) => const SafeArea(
                    child: LocationDropdownBottomSheet(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 40,
                padding: const EdgeInsets.all(10),
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: SvgPicture.asset('assets/images/location.svg'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        locationText,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                          fontFamily: 'Inter Display',
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: SvgPicture.asset('assets/images/arrow-down.svg'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              context.push('/notifications');
            },
            child: Container(
              width: 40,
              height: 40,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: const Color(0xFFF3F4F6) /* bg-secondary */,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      width: 20,
                      height: 20,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(),
                      child: SvgPicture.asset('assets/images/BellSimple.svg'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreSection() {
    final categoriesAsync = ref.watch(serviceCategoriesProvider);
    
    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) return const SizedBox.shrink();
        
        final safeCategoryIndex = _selectedCategoryIndex < categories.length ? _selectedCategoryIndex : 0;
        final category = categories[safeCategoryIndex];
        final serviceTypes = category.serviceTypes;
        final safeSubTypeIndex = _selectedSubTypeIndex < serviceTypes.length ? _selectedSubTypeIndex : 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 22, 16, 12),
              child: Text('Explore Services', style: AppTextStyles.h3),
            ),
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = index == safeCategoryIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = index;
                        _selectedSubTypeIndex = 0;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsetsGeometry.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Image.network(
                            cat.iconUrl,
                            width: 24,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) => 
                                const Icon(Icons.category, size: 24, color: Colors.grey),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            cat.name,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: serviceTypes.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final type = serviceTypes[index];
                  final isSelected = index == safeSubTypeIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSubTypeIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsetsGeometry.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Text(
                        type,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsetsGeometry.symmetric(horizontal: 16),
              child: Consumer(
                builder: (context, ref, child) {
                  final searchAsync = ref.watch(searchResultsProvider(SearchFilters(
                    categoryId: category.categoryId,
                    serviceType: serviceTypes[safeSubTypeIndex],
                  )));

                  return searchAsync.when(
                    data: (searchResponse) {
                      final String currentType = serviceTypes[safeSubTypeIndex];
                      
                      final matchingServicesWithProviders = searchResponse.providers
                          .expand((provider) => provider.services
                              .where((s) => s.serviceType == currentType || s.title == currentType)
                              .map((service) => (provider, service)))
                          .toList();

                      if (matchingServicesWithProviders.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text('No services found.'),
                          ),
                        );
                      }

                      return Column(
                        children: matchingServicesWithProviders
                            .map(
                              (pair) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildServiceCard(pair.$1, pair.$2, searchResponse.providers),
                              ),
                            )
                            .toList(),
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (e, s) => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('Error loading providers'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: Text('Error loading categories')),
      ),
    );
  }

  Widget _buildServiceCard(SearchProviderEntity provider, SearchServiceEntity service, List<SearchProviderEntity> allProviders) {
    return GestureDetector(
      onTap: () {
        context.push('/service_details', extra: (provider, service, allProviders));
      },
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: service.serviceImageUrl != null && service.serviceImageUrl!.isNotEmpty
                      ? NetworkImage(service.serviceImageUrl!)
                      : const AssetImage('assets/images/Container.png') as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: const Alignment(0.50, -0.00),
                  end: const Alignment(0.50, 1.00),
                  colors: [Colors.black.withValues(alpha: 0.20), Colors.black],
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                height: 36,
                padding: const EdgeInsetsGeometry.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0x1A838383),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                ),
                child: Text(
                  'from ${provider.currency} ${service.priceOverride}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    height: 1.50,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                width: 36,
                height: 36,
                padding: const EdgeInsets.all(9),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: SvgPicture.asset(
                  'assets/images/arrow-up-right.svg',
                  height: 18,
                  width: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      height: 1.40,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SvgPicture.asset('assets/images/star.svg'),
                      const SizedBox(width: 6), 
                      Text(
                        '${double.tryParse(provider.averageRating ?? '0.0')?.toStringAsFixed(1) ?? '0.0'} · ${provider.completedServiceRequestCount ?? 0} bookings · ${service.durationMinutes ?? 0} min',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white,
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
 Widget _buildServicesForYouSection() {
    final searchAsync = ref.watch(searchResultsProvider(const SearchFilters()));
    final allServicesWithProviders = searchAsync.maybeWhen(
      data: (searchResponse) => searchResponse.providers
          .expand((provider) => provider.services.map((service) => (provider, service)))
          .toList(),
      orElse: () => <(SearchProviderEntity, SearchServiceEntity)>[],
    );
    final firstPair = allServicesWithProviders.isNotEmpty ? allServicesWithProviders.first : null;
    final allProviders = searchAsync.maybeWhen(
      data: (searchResponse) => searchResponse.providers,
      orElse: () => null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Text('Service for you', style: AppTextStyles.h3),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            'Verified technicians, guaranteed quality',
            style: AppTextStyles.labelMedium.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
        SizedBox(
          height: 188,
          child: PageView.builder(
            controller: _promoBannerController,
            itemCount: _promoBanners.length,
            onPageChanged: (index) => setState(() {
              _currentBannerPage = index;
            }),
            itemBuilder: (context, index) {
              return _buildPromoBanner(
                _promoBanners[index]['title']!,
                _promoBanners[index]['subtitle']!,
                firstPair,
                allProviders,
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _promoBanners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 16,
              height: 4,
              decoration: BoxDecoration(
                color: _currentBannerPage == index
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoBanner(
    String title,
    String subTitle,
    (SearchProviderEntity, SearchServiceEntity)? firstPair,
    List<SearchProviderEntity>? allProviders,
  ) {
    final hasService = firstPair != null && allProviders != null;

    Widget bannerContent = Container(
      margin: const EdgeInsetsGeometry.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/images/service-for-you.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h3.copyWith(color: Colors.white),
                ),
                Text(
                  subTitle,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (hasService) {
                      context.push(
                        '/service_details',
                        extra: (firstPair.$1, firstPair.$2, allProviders),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsetsGeometry.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  child: const Text('Book Now', style: AppTextStyles.bodyLarge),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (hasService) {
      return GestureDetector(
        onTap: () {
          context.push(
            '/service_details',
            extra: (firstPair.$1, firstPair.$2, allProviders),
          );
        },
        child: bannerContent,
      );
    }
    return bannerContent;
  }

  Widget _buildQuickServicesSection() {
    final searchAsync = ref.watch(searchResultsProvider(const SearchFilters()));

    return searchAsync.when(
      data: (searchResponse) {
        final allServicesWithProviders = searchResponse.providers
            .expand((provider) => provider.services.map((service) => (provider, service)))
            .toList();

        if (allServicesWithProviders.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 32, 16, 0),
              child: Text('Service for you', style: AppTextStyles.h3),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'Verified technicians, guaranteed quality',
                style: AppTextStyles.labelMedium.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            SizedBox(
              height: 127,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: allServicesWithProviders.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final pair = allServicesWithProviders[index];
                  final provider = pair.$1;
                  final service = pair.$2;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        context.push(
                          '/service_details',
                          extra: (provider, service, searchResponse.providers),
                        );
                      },
                      child: Container(
                        width: 160,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: service.serviceImageUrl != null && service.serviceImageUrl!.isNotEmpty
                                ? NetworkImage(service.serviceImageUrl!)
                                : const AssetImage('assets/images/quick.jpg') as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: const Alignment(0.50, -0.00),
                                  end: const Alignment(0.50, 1.00),
                                  colors: [
                                    Colors.black.withValues(alpha: 0.20),
                                    Colors.black,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            Positioned(
                              top: 16,
                              right: 16,
                              child: Container(
                                width: 36,
                                height: 36,
                                padding: const EdgeInsets.all(9),
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                                child: SvgPicture.asset(
                                  'assets/images/arrow-up-right.svg',
                                  height: 18,
                                  width: 18,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 16,
                              bottom: 16,
                              right: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.title,
                                    style: AppTextStyles.h6.copyWith(
                                      color: Colors.white,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'from ${provider.currency} ${service.priceOverride}',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surface,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6), // premium light grey slate
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              color: AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
                decoration: const InputDecoration(
                  hintText: 'Search services, providers...',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    fontFamily: 'Inter',
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  setState(() {
                    _searchQuery = value.trim();
                  });
                },
                onChanged: (value) {
                  if (value.trim().isEmpty && _searchQuery.isNotEmpty) {
                    setState(() {
                      _searchQuery = '';
                    });
                  }
                },
              ),
            ),
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                child: const Icon(
                  Icons.clear,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final searchAsync = ref.watch(searchResultsProvider(SearchFilters(q: _searchQuery)));

    return searchAsync.when(
      data: (searchResponse) {
        final providers = searchResponse.providers;
        if (providers.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.search_off,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No results found for "$_searchQuery"',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Try checking spelling or using more general terms',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: providers.length,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemBuilder: (context, index) {
            final provider = providers[index];
            return _buildProviderSearchResultCard(provider, providers);
          },
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'Error fetching results: $err',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildProviderSearchResultCard(SearchProviderEntity provider, List<SearchProviderEntity> allProviders) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Provider Header Details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF3F4F6),
                    image: (provider.avatarUrl != null && provider.avatarUrl!.isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(provider.avatarUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: (provider.avatarUrl == null || provider.avatarUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 28, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 12),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              provider.fullName,
                              style: AppTextStyles.bodyMediumBold.copyWith(
                                fontSize: 16,
                                color: AppColors.textDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Availability Tag
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: provider.isAvailableNow 
                                  ? const Color(0xFFDCFCE7) 
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: provider.isAvailableNow 
                                        ? const Color(0xFF22C55E) 
                                        : Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  provider.isAvailableNow ? 'Available' : 'Offline',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: provider.isAvailableNow 
                                        ? const Color(0xFF166534) 
                                        : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            double.tryParse(provider.averageRating ?? '0.0')?.toStringAsFixed(1) ?? '0.0',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${provider.reviewCount ?? 0} reviews) · ${provider.completedServiceRequestCount ?? 0} bookings',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (provider.bio != null && provider.bio!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          provider.bio!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          
          // Services Offered List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Services Offered',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                ...provider.services.map((service) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFF3F4F6)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Service Icon or Image
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFFE5E7EB),
                            image: (service.serviceImageUrl != null && service.serviceImageUrl!.isNotEmpty)
                                ? DecorationImage(
                                    image: NetworkImage(service.serviceImageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: (service.serviceImageUrl == null || service.serviceImageUrl!.isEmpty)
                              ? const Icon(Icons.build, size: 20, color: Colors.grey)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        // Service Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${provider.currency} ${service.priceOverride} · ${service.durationMinutes ?? 30} mins',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Book Button
                        ElevatedButton(
                          onPressed: () {
                            context.push(
                              '/service_details',
                              extra: (provider, service, allProviders),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Book',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
