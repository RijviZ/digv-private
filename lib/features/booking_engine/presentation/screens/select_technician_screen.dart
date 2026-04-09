import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/core/widgets/app_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:digv/features/booking_engine/domain/technician.dart';

import 'package:digv/core/widgets/app_top_bar.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/technician_card.dart';
 
class SelectTechnicianScreen extends StatefulWidget {
  const SelectTechnicianScreen({super.key});
 
  @override
  State<SelectTechnicianScreen> createState() => _SelectTechnicianScreenState();
}
 
class _SelectTechnicianScreenState extends State<SelectTechnicianScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Top rated', 'Nearest'];
 
static const List<Technician> technicians = [
  Technician(
    name: 'Arjun Kumar',
    specialty: 'AC & Electrical',
    rating: 4.9,
    reviews: 312,
    jobs: 892,
    experience: 5,
    pricePerVisit: 500,
    distanceKm: 2.1,
    distanceLabel: 'Near',
    isTopRated: true,
  ),
  Technician(
    name: 'Maya Singh',
    specialty: 'Plumbing Services',
    rating: 4.8,
    reviews: 415,
    jobs: 250,
    experience: 3,
    pricePerVisit: 300,
    distanceKm: 1.5,
    distanceLabel: 'Nearby', isTopRated: false,
  ),
  Technician(
    name: 'Ravi Sharma',
    specialty: 'Home Renovation',
    rating: 5.0,
    reviews: 510,
    jobs: 150,
    experience: 2,
    pricePerVisit: 400,
    distanceKm: 3.0,
    distanceLabel: 'Close by', isTopRated: false,
  ),
];

  List<Technician> get _filteredTechnicians {
    switch (_selectedFilter) {
      case 1:
        return technicians.where((t) => t.isTopRated).toList();
      case 2:
        return [...technicians]..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      default:
        return technicians;
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
                              child: TechnicianCard(technician: t),
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
            onTap: () {
              context.push('/select_date_and_time');
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
          const Text(
            '3 verified technicians available near you',
            style: TextStyle(
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