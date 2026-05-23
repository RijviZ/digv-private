import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/core/widgets/app_filter_bar.dart';
import 'package:digv/core/widgets/app_top_bar.dart';
import 'package:digv/features/booking_engine/domain/technician.dart';
import 'package:digv/features/search/domain/entities/search_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/technician_card.dart';
 
class SelectTechnicianScreen extends StatefulWidget {
  final List<SearchProviderEntity> providers;
  final SearchServiceEntity service;

  const SelectTechnicianScreen({
    super.key,
    required this.providers,
    required this.service,
  });
 
  @override
  State<SelectTechnicianScreen> createState() => _SelectTechnicianScreenState();
}
 
class _SelectTechnicianScreenState extends State<SelectTechnicianScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Top rated', 'Nearest'];
  Technician? _selectedTechnician;
 
  List<Technician> get _allTechnicians {
    return widget.providers.map((p) {
      // Find the specific service offered by this provider that matches our current service
      final providerService = p.services.cast<SearchServiceEntity>().firstWhere(
        (s) => s.serviceId == widget.service.serviceId,
        orElse: () => p.services.cast<SearchServiceEntity>().firstWhere(
          (s) => s.title == widget.service.title,
          orElse: () => p.services.cast<SearchServiceEntity>().firstWhere(
            (s) => s.serviceType == widget.service.serviceType,
            orElse: () => widget.service,
          ),
        ),
      );

      final distanceKm = double.tryParse(p.distanceKm) ?? 0.0;

      return Technician(
        providerId: p.userId,
        name: p.fullName,
        specialty: providerService.title,
        rating: double.tryParse(p.averageRating ?? '0') ?? 0.0,
        reviews: p.reviewCount ?? 0,
        jobs: p.completedServiceRequestCount ?? 0,
        experience: providerService.experienceYears,
        pricePerVisit: providerService.priceOverride.toInt(),
        distanceKm: distanceKm,
        distanceLabel: distanceKm <= 1.99
            ? 'Nearby'
            : distanceKm <= 2.99
                ? 'Near'
                : 'Close by',
        isTopRated: (double.tryParse(p.averageRating ?? '0') ?? 0.0) >= 4.5,
        avatarUrl: p.avatarUrl,
        durationMinutes: providerService.durationMinutes,
      );
    }).toList();
  }

  List<Technician> get _filteredTechnicians {
    final list = _allTechnicians;
    switch (_selectedFilter) {
      case 1:
        return list.where((t) => t.isTopRated).toList();
      case 2:
        return [...list]..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      default:
        return list;
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AppTopBar(title: 'Select Technician'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    AppFilterBar(
                      items: _filters,
                      selectedItem: _filters.elementAt(_selectedFilter),
                      onSelected: (index) {
                        setState(() => _selectedFilter = _filters.indexOf(index));
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                    ),
                    const SizedBox(height: 20),
                    _buildVerifiedBanner(),
                    const SizedBox(height: 20),
                    ..._filteredTechnicians
                        .map((t) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedTechnician = t;
                                  });
                                },
                                child: TechnicianCard(
                                  technician: t,
                                  isSelected: _selectedTechnician == t,
                                ),
                              ),
                            ))
                        ,
                    _buildVerifiedFooter(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(top: BorderSide(color: AppColors.dropDownBorder)),
          ),
          child: AppPrimaryButton(
            text: 'Continue to select time',
            onTap: _selectedTechnician == null
                ? null
                : () {
                    context.push('/select_date_and_time', extra: (widget.service, _selectedTechnician!));
                  },
          ),
        ),
      ),
    );
  }

  Widget _buildVerifiedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.unread,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.inputBorderSecondary, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.blue,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${widget.providers.length} verified technicians available near you',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.blue,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildVerifiedFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.inputBorder, width: 1),
      ),
      child: Row(
        children: [
          SvgPicture.asset('assets/images/shield.svg'),
          const SizedBox(width: 8),
           Expanded(
            child: Text(
              'All technicians are background verified and trained',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
 
}