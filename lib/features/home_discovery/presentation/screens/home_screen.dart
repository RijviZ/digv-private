import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/core/widgets/app_filter_bar.dart';
import 'package:digv/features/home_discovery/presentation/domain/nav_item.dart';
import 'package:digv/features/home_discovery/presentation/domain/quick_service_item.dart';
import 'package:digv/features/home_discovery/presentation/domain/service_card.dart';
import 'package:digv/features/home_discovery/presentation/domain/service_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedCategoryIndex = 0;
  int _selectedSubTypeIndex = 0;
  int _selectedNavIndex = 0;
  late final PageController _promoBannerController;
  int _currentBannerPage = 0;

  final List<ServiceCategory> _categories = const [
    ServiceCategory(label: 'AC', icon: 'assets/images/fast-wind.svg'),
    ServiceCategory(label: 'Electrical', icon: 'assets/images/flash.svg'),
    ServiceCategory(label: 'Plumber', icon: 'assets/images/wrench.svg'),
    ServiceCategory(label: 'Clean', icon: 'assets/images/soil-temp.svg'),
  ];

  final List<List<String>> _subTypes = [
    ['Split', 'Window', 'Central', 'Cassette', 'In Progress'],
    ['Wiring', 'Fan', 'Switch', 'MCB', 'Light'],
    ['Tap', 'Pipe', 'Drain', 'Toilet', 'Geyser'],
    ['Home', 'Office', 'Sofa', 'Carpet', 'Kitchen'],
  ];

  final List<Map<String, String>> _promoBanners = [
    {'title': 'First Service 10% OFF', 'subtitle': 'New user exclusive offer'},
    {
      'title': 'Refer & Earn',
      'subtitle': 'Invite your friends and earn rewards',
    },
    {'title': 'Free Inspection', 'subtitle': 'Book your service now'},
    {'title': 'Flash Sale!', 'subtitle': 'Grab your discount today'},
  ];

  final List<List<ServiceCard>> _serviceCards = [
    [
      ServiceCard(
        title: 'Regular Service',
        price: '₹199',
        rating: '4.8',
        bookings: '12.3k bookings',
        duration: '45 mins',
        imageColor: Color(0xFF3A3A3A),
        image: 'assets/images/Container.png',
      ),
      ServiceCard(
        title: 'Deep Cleaning',
        price: '₹299',
        rating: '4.9',
        bookings: '8.4k bookings',
        duration: '30 mins',
        imageColor: Color(0xFF2A2A2A),
        image: 'assets/images/Container.png',
      ),

      ServiceCard(
        title: 'Installation',
        price: '₹399',
        rating: '5.0',
        bookings: '2.1k bookings',
        duration: '15 mins',
        imageColor: Color(0xFF1A1A1A),
        image: 'assets/images/Container.png',
      ),
    ],
    [
      ServiceCard(
        title: 'Wiring Repair',
        price: '₹149',
        rating: '4.7',
        bookings: '9.1k bookings',
        duration: '30 mins',
        imageColor: Color(0xFF3A3A3A),
        image: 'assets/images/Container.png',
      ),
      ServiceCard(
        title: 'Fan Installation',
        price: '₹199',
        rating: '4.8',
        bookings: '5.2k bookings',
        duration: '20 mins',
        imageColor: Color(0xFF2A2A2A),
        image: 'assets/images/Container.png',
      ),
    ],
    [
      ServiceCard(
        title: 'Tap Fixing',
        price: '₹129',
        rating: '4.6',
        bookings: '7.3k bookings',
        duration: '25 mins',
        imageColor: Color(0xFF3A3A3A),
        image: 'assets/images/Container.png',
      ),
      ServiceCard(
        title: 'Pipe Repair',
        price: '₹199',
        rating: '4.8',
        bookings: '4.1k bookings',
        duration: '40 mins',
        imageColor: Color(0xFF2A2A2A),
        image: 'assets/images/Container.png',
      ),
    ],
    [
      ServiceCard(
        title: 'Home Cleaning',
        price: '₹249',
        rating: '4.9',
        bookings: '15.6k bookings',
        duration: '60 mins',
        imageColor: Color(0xFF3A3A3A),
        image: 'assets/images/Container.png',
      ),
    ],
  ];

  final List<QuickServiceItem> _quickServices = [
    QuickServiceItem(label: 'AC Regular Service', price: '₹199'),
    QuickServiceItem(label: 'Electrical Wiring', price: '₹199'),
    QuickServiceItem(label: 'Plumbing Materials', price: '1500'),
    QuickServiceItem(label: 'Roofing Materials', price: '₹3200'),
  ];

  @override
  void initState() {
    super.initState();
    _promoBannerController = PageController();
  }

  @override
  void dispose() {
    _promoBannerController.dispose();
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildExploreSection(),
                    _buildServicesForYouSection(),
                    _buildQuickServicesSection(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  "https://upload.wikimedia.org/wikipedia/commons/9/9e/Placeholder_Person.jpg",
                ),
                fit: BoxFit.cover,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
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
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'JI. Ngagelrejo No.34',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14,
                        fontFamily: 'Inter Display',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: SvgPicture.asset('assets/images/arrow-down.svg'),
                  ),
                ],
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
                      decoration: BoxDecoration(),
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
    final subTypes = _subTypes[_selectedCategoryIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
          child: Text('Explore Services', style: AppTextStyles.h3),
        ),
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,

            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = index == _selectedCategoryIndex;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategoryIndex = index;
                    _selectedSubTypeIndex = 0;
                  });
                },
                child: Container(
                  padding: EdgeInsetsGeometry.symmetric(
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
                      SvgPicture.asset(category.icon),
                      const SizedBox(width: 8),
                      Text(
                        category.label,
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
        SizedBox(height: 16),
        AppFilterBar(
          items: subTypes,
          selectedItem: subTypes[_selectedSubTypeIndex],
          onSelected: (item) {
            setState(() {
              _selectedSubTypeIndex = subTypes.indexOf(item);
            });
          },
        ),
        const SizedBox(height: 24),
        _buildServiceCards(),
      ],
    );
  }

  Widget _buildServiceCards() {
    final cards = _serviceCards[_selectedCategoryIndex];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: cards.map((card) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildServiceCard(card),
        )).toList(),
      ),
    );
  }

  Widget _buildServiceCard(ServiceCard card) {
    return GestureDetector(
      onTap: () => context.push('/service-details'),
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: card.imageColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: AssetImage(card.image),
                  fit: BoxFit.cover,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.2), Colors.black],
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFF838383),
                  border: Border.all(color: Colors.white.withOpacity(0.35)),
                ),
                child: Text(
                  'from ${card.price}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
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
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/arrow-up-right.svg',
                    width: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
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
                    card.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SvgPicture.asset('assets/images/star.svg'),
                      const SizedBox(width: 4),
                      Text(card.rating,
                          style: const TextStyle(color: Colors.white)),
                      const SizedBox(width: 8),
                      Text('· ${card.bookings} · ${card.duration}',
                          style: const TextStyle(color: Colors.white70)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
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

  Widget _buildPromoBanner(String title, String subTitle) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              child: const Text('Book Now', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
          child: Text('Quick Services', style: AppTextStyles.h3),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _quickServices.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final service = _quickServices[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      service.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'from ${service.price}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final List<NavItem> navItems = [
      NavItem(label: 'Home', icon: 'assets/images/House.svg'),
      NavItem(label: 'Bookings', icon: 'assets/images/CalendarBlank.svg'),
      NavItem(label: 'Search', icon: 'assets/images/MagnifyingGlass.svg'),
      NavItem(label: 'Account', icon: 'assets/images/UserCircle.svg'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) => setState(() => _selectedNavIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTextStyles.labelMedium,
        items: navItems.map((item) => BottomNavigationBarItem(
          icon: SvgPicture.asset(
            item.icon,
            colorFilter: ColorFilter.mode(
              _selectedNavIndex == navItems.indexOf(item)
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
              BlendMode.srcIn,
            ),
          ),
          label: item.label,
        )).toList(),
      ),
    );
  }
}
