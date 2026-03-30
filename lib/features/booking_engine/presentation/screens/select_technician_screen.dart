import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/core/widgets/app_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SelectTechnicianScreen extends StatefulWidget {
  const SelectTechnicianScreen({super.key});

  @override
  State<SelectTechnicianScreen> createState() => _SelectTechnicianScreenState();
}

class _SelectTechnicianScreenState extends State<SelectTechnicianScreen> {
  String _selectedFilter = 'All';

  final List<String> _filterTypes = [
    'All',
    'Top Rated',
    'Nearest',
  ];

  final List<Map<String, dynamic>> _technicians = [
    {
      'name': 'Arjun Kumar',
      'category': 'AC & Electrical',
      'rating': 4.9,
      'reviews': 312,
      'jobs': 892,
      'exp': '5 yrs',
      'price': 500,
      'distance': '2.1 km',
      'proximity': 'Near',
      'isTopRated': true,
      'image': 'https://images.unsplash.com/photo-1599566150163-29194dcaad36',
    },
    {
      'name': 'Maya Singh',
      'category': 'Plumbing Services',
      'rating': 4.8,
      'reviews': 415,
      'jobs': 250,
      'exp': '3 yrs',
      'price': 300,
      'distance': '1.5 km',
      'proximity': 'Nearby',
      'isTopRated': false,
      'image': 'https://images.unsplash.com/photo-1599566150163-29194dcaad36',
    },
    {
      'name': 'Ravi Sharma',
      'category': 'Home Renovation',
      'rating': 5.0,
      'reviews': 510,
      'jobs': 150,
      'exp': '2 yrs',
      'price': 400,
      'distance': '3.0 km',
      'proximity': 'Close By',
      'isTopRated': false,
      'image': 'https://images.unsplash.com/photo-1599566150163-29194dcaad36',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Select Technician',
          style: AppTextStyles.titleLight.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: SizedBox(
            width: 20,
            height: 20,
            child: SvgPicture.asset('assets/images/CaretLeft.svg'),
          ),
        ),
      ),
      body: Column(
        children: [
          AppFilterBar(items: ['Split', 'Window', 'Central', 'Cassette', 'In Progress'], selectedItem: _selectedFilter, onSelected: (item) {
            setState(() {
              _selectedFilter = item;
            });
          }),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: AppColors.unread,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: AppColors.inputBorderSecondary,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF1D4ED8) /* system-info-text */,
                    shape: OvalBorder(),
                  ),
                ),
                Text(
                  '3 verified technicians available near you',
                  style: TextStyle(
                    color: const Color(0xFF1D4ED8) /* system-info-text */,
                    fontSize: 11,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    height: 1.60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
