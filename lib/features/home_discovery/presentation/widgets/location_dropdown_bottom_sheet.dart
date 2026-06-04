import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/features/address/domain/entities/address.dart';
import 'package:digv/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationDropdownBottomSheet extends ConsumerStatefulWidget {
  const LocationDropdownBottomSheet({super.key});

  @override
  ConsumerState<LocationDropdownBottomSheet> createState() => _LocationDropdownBottomSheetState();
}

class _LocationDropdownBottomSheetState extends ConsumerState<LocationDropdownBottomSheet> {
  bool _isLocating = false;

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled.')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied.')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are permanently denied.')),
          );
        }
        return;
      }

      final Position position = await Geolocator.getCurrentPosition();
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final Placemark place = placemarks.isNotEmpty ? placemarks.first : const Placemark();

      final String newAddressLine = [place.name, place.street, place.subLocality]
          .where((e) => e != null && e.isNotEmpty)
          .join(', ');
      final String newCity = [
        place.locality,
        place.subAdministrativeArea,
        place.administrativeArea,
        'Unknown City'
      ].firstWhere((c) => c != null && c.trim().length >= 2)!;

      final data = {
        "lat": position.latitude,
        "lng": position.longitude,
        "addressLine": newAddressLine,
        "city": newCity,
        "accuracy": position.accuracy.toInt(),
      };

      final history = ref.read(locationHistoryProvider).value ?? [];
      final matchesAnyHistory = history.any((loc) =>
          (loc.addressLine?.trim().toLowerCase() == newAddressLine.trim().toLowerCase()) &&
          (loc.city?.trim().toLowerCase() == newCity.trim().toLowerCase()));

      if (!matchesAnyHistory) {
        await ref.read(authProvider.notifier).updateLocation(data);
      } else {
        final matchedLoc = history.firstWhere((loc) =>
            (loc.addressLine?.trim().toLowerCase() == newAddressLine.trim().toLowerCase()) &&
            (loc.city?.trim().toLowerCase() == newCity.trim().toLowerCase()));
        ref.read(selectedLocationProvider.notifier).state = matchedLoc;
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating location: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _selectAddress(Address address) async {
    ref.read(selectedLocationProvider.notifier).state = address;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(locationHistoryProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Location',
                style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w700),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(height: 24),

          InkWell(
            onTap: _isLocating ? null : _useCurrentLocation,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.blueLight.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.my_location, color: AppColors.blueDeep),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Use Current Location',
                          style: AppTextStyles.bodyMediumBold.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Using GPS to pinpoint your location',
                          style: AppTextStyles.caption.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isLocating)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  historyAsync.when(
                    data: (history) {
                      if (history.isEmpty) return const SizedBox.shrink();
                      
                      final uniqueHistory = <String, Address>{};
                      for (final loc in history) {
                        final addressStr = loc.addressLine ?? '';
                        final cityStr = loc.city ?? '';
                        final key = '${addressStr.trim().toLowerCase()}_${cityStr.trim().toLowerCase()}';
                        if (!uniqueHistory.containsKey(key)) {
                          uniqueHistory[key] = loc;
                        }
                      }
                      final filteredHistory = uniqueHistory.values.toList();
                      if (filteredHistory.isEmpty) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          Text(
                            'RECENT LOCATIONS',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                              letterSpacing: 1.1,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredHistory.length > 5 ? 5 : filteredHistory.length,
                            separatorBuilder: (_, __) => const Divider(height: 12),
                            itemBuilder: (context, index) {
                              final loc = filteredHistory[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).dividerColor.withOpacity(0.3),
                                  child: Icon(
                                    Icons.history,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                title: Text(
                                  loc.addressLine ?? 'Recent Location',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodyMediumBold.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                subtitle: Text(
                                  loc.city ?? '',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                trailing: const Icon(Icons.chevron_right, size: 18),
                                onTap: _isLocating ? null : () => _selectAddress(loc),
                              );
                            },
                          ),
                        ],
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (err, _) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Error loading history: $err'),
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
}
