import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class ServiceDetailsScreen extends StatefulWidget {
  const ServiceDetailsScreen({super.key});

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  String _selectedService = 'Split';
  int _quantity = 1;

  final List<String> _types = [
    'Split',
    'Window',
    'Central',
    'Cassette',
    'In Progress',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Service Details',
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
          icon: SvgPicture.asset('assets/images/CaretLeft.svg'),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 240,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1621905251189-08b45d6a269e',
                  ),
                  fit: BoxFit.cover,
                ),
                gradient: LinearGradient(
                  begin: Alignment(0.50, -0.00),
                  end: Alignment(0.50, 1.00),
                  colors: [Colors.black.withValues(alpha: 0.20), Colors.black],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Deep Cleaning',
              style: AppTextStyles.h3.copyWith(
                color: Theme.of(context).colorScheme.primary,
                height: 1.40,
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                SvgPicture.asset('assets/images/star.svg'),
                SizedBox(width: 6),
                Text(
                  '4.8',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  '· 12.3k bookings · 45 mins',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Complete AC checkup, filter cleaning, gas pressure check & performance optimization.',
              style: AppTextStyles.captionMedium.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'What\'s Included',
              style: AppTextStyles.titleLight.copyWith(
                color: Theme.of(context).colorScheme.primary,
                height: 1.75,
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: 7),
            _includedItem(text: 'Filter Cleaning'),
            _includedItem(text: 'Gas Pressure Check'),
            _includedItem(text: 'Cooling Test'),
            _includedItem(text: 'Performance Report'),
            SizedBox(height: 17),
            Text(
              'Select Type',
              style: AppTextStyles.titleLight.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
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
            SizedBox(height: 20),
            Text(
              'Quantity',
              style: AppTextStyles.titleLight.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            _buildQuantitySelector(),
            SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(top: BorderSide(color: AppColors.dropDownBorder)),
          ),
          child: ElevatedButton(
            onPressed: () {
              context.push('/select-technician');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              elevation: 0,
              foregroundColor: Theme.of(context).colorScheme.surface,
              padding: EdgeInsetsGeometry.symmetric(vertical: 16),
            ),
            child: Text(
              'Continue to select technician',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
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
        border: Border.all(color: AppColors.dropDownBorder),
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
              decoration: BoxDecoration(color: AppColors.inputBgSecondary),
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
              decoration: BoxDecoration(color: AppColors.inputBgSecondary),
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
      padding: EdgeInsetsGeometry.symmetric(vertical: 3),
      child: Row(
        children: [
          SvgPicture.asset('assets/images/checkmark-circle.svg'),
          SizedBox(width: 10),
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
