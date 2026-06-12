import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/core/widgets/app_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_filter_bar.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../search/presentation/providers/search_provider.dart';

class ServiceDetailsScreen extends ConsumerStatefulWidget {
  final String serviceItemId;

  const ServiceDetailsScreen({
    super.key,
    required this.serviceItemId,
  });

  @override
  ConsumerState<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends ConsumerState<ServiceDetailsScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(serviceDetailsProvider(widget.serviceItemId));

    return detailsAsync.when(
      data: (details) {
        final types = details.selectableTypes.map((t) => t.name).toList();

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: Column(
              children: [
                const AppTopBar(title: 'Service Details'),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 240,
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            image: DecorationImage(
                              image: details.serviceItemImageUrl != null && details.serviceItemImageUrl!.isNotEmpty
                                  ? NetworkImage(details.serviceItemImageUrl!)
                                  : const AssetImage('assets/images/Container.png') as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                            gradient: LinearGradient(
                              begin: const Alignment(0.50, -0.00),
                              end: const Alignment(0.50, 1.00),
                              colors: [Colors.black.withOpacity(0.20), Colors.black],
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          details.serviceItemName,
                          style: AppTextStyles.h3.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            height: 1.40,
                            letterSpacing: 0,
                          ),
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
                          details.serviceItemDescription ?? 'Professional service provided by our top-rated technicians.',
                          style: AppTextStyles.captionMedium.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
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
                        if (details.whatsIncluded.isNotEmpty)
                          ...details.whatsIncluded.map((feature) => _includedItem(text: feature))
                        else ...[
                          _includedItem(text: 'Filter Cleaning'),
                          _includedItem(text: 'Gas Pressure Check'),
                          _includedItem(text: 'Cooling Test'),
                          _includedItem(text: 'Performance Report'),
                        ],

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
                border: const Border(top: BorderSide(color: AppColors.dropDownBorder)),
              ),
              child: AppPrimaryButton(
                text: 'Continue to select technician',
                onTap: () {
                  context.push('/select_technician', extra: (widget.serviceItemId, _quantity));
                },
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Service Details'),
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Service Details'),
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
        ),
        body: Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
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
              decoration: const BoxDecoration(color: AppColors.inputBgSecondary),
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
              decoration: const BoxDecoration(color: AppColors.inputBgSecondary),
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
          SvgPicture.asset('assets/images/checkmark-circle.svg'),
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
