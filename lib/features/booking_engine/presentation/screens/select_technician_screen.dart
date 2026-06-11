import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/core/widgets/app_filter_bar.dart';
import 'package:digv/core/widgets/app_top_bar.dart';
import 'package:digv/features/booking_engine/domain/technician.dart';
import 'package:digv/features/search/domain/entities/search_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/technician_card.dart';
import '../../../search/presentation/providers/search_provider.dart';

class SelectTechnicianScreen extends ConsumerStatefulWidget {
  final String serviceItemId;
  final int quantity;

  const SelectTechnicianScreen({
    super.key,
    required this.serviceItemId,
    this.quantity = 1,
  });

  @override
  ConsumerState<SelectTechnicianScreen> createState() => _SelectTechnicianScreenState();
}

class _SelectTechnicianScreenState extends ConsumerState<SelectTechnicianScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Top rated', 'Nearest'];
  Technician? _selectedTechnician;

  String get _currentFilterType {
    switch (_selectedFilter) {
      case 1:
        return 'TOP_RATED';
      case 2:
        return 'NEAREST';
      default:
        return 'ALL';
    }
  }

  List<Technician> _mapToTechnicians(List<SearchTechnicianEntity> providers, int durationMinutes) {
    return providers.map((t) {
      final distanceKm = double.tryParse(t.distanceKm) ?? 0.0;

      return Technician(
        providerId: t.providerId,
        name: t.providerName,
        specialty: t.serviceCategoryName,
        rating: t.rating ?? 0.0,
        reviews: t.totalJobs * 2 + 3,
        jobs: t.totalJobs,
        experience: t.experienceYears,
        pricePerVisit: double.tryParse(t.servicePrice)?.toInt() ?? 0,
        distanceKm: distanceKm,
        distanceLabel: t.distanceTag.isNotEmpty ? t.distanceTag : (distanceKm <= 1.99
            ? 'Nearby'
            : distanceKm <= 2.99
                ? 'Near'
                : 'Close by'),
        isTopRated: t.isTopRated,
        avatarUrl: t.avatarUrl,
        durationMinutes: durationMinutes,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final providersAsync = ref.watch(serviceProvidersProvider(ProvidersFilters(
      serviceItemId: widget.serviceItemId,
      filterType: _currentFilterType,
    )));
    final detailsAsync = ref.watch(serviceDetailsProvider(widget.serviceItemId));

    return providersAsync.when(
      data: (providers) {
        return detailsAsync.when(
          data: (details) {
            final techniciansList = _mapToTechnicians(providers, details.durationMinutes ?? 30);
            final serviceEntity = details.toSearchServiceEntity();

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
                                setState(() {
                                  _selectedFilter = _filters.indexOf(index);
                                  _selectedTechnician = null;
                                });
                              },
                              padding: const EdgeInsets.symmetric(horizontal: 0),
                            ),
                            const SizedBox(height: 20),
                            _buildVerifiedBanner(providers.length),
                            const SizedBox(height: 20),
                            if (techniciansList.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40.0),
                                child: Center(
                                  child: Text('No technicians found matching this filter.'),
                                ),
                              )
                            else
                              ...techniciansList.map((t) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedTechnician = t;
                                        });
                                      },
                                      child: TechnicianCard(
                                        technician: t,
                                        isSelected: _selectedTechnician?.providerId == t.providerId,
                                      ),
                                    ),
                                  )),
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
                    border: const Border(top: BorderSide(color: AppColors.dropDownBorder)),
                  ),
                  child: AppPrimaryButton(
                    text: 'Continue to select time',
                    onTap: _selectedTechnician == null
                        ? null
                        : () {
                            context.push(
                              '/select_date_and_time',
                              extra: (serviceEntity, _selectedTechnician!, widget.quantity),
                            );
                          },
                  ),
                ),
              ),
            );
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) => Scaffold(
            body: Center(child: Text('Error loading service details: $err')),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Error loading providers: $err')),
      ),
    );
  }

  Widget _buildVerifiedBanner(int count) {
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
            '$count verified technicians available near you',
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