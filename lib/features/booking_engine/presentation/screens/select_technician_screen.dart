import 'package:digv/core/theme/app_text_styles.dart';
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
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _types.length,
              itemBuilder: (context, index) {
                final subType = _types[index];
                final isSelected = subType == _selectedService;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedService = subType;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 12),
                    padding: EdgeInsetsGeometry.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    child: Text(
                      _types[index],
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: const Color(0xFFEFF6FF) /* system-info-bg */,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: const Color(0xFFBFDBFE) /* system-info-border */,
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

  Widget _buildFilterChip(String label) {
    final isSelected = label == _selectedFilter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 16, vertical: 8),

      )
    );
  }
}
