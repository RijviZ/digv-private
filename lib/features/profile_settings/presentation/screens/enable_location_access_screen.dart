import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

class EnableLocationAccessScreen extends ConsumerStatefulWidget {
  const EnableLocationAccessScreen({super.key});

  @override
  ConsumerState<EnableLocationAccessScreen> createState() =>
      _EnableLocationAccessScreenState();
}

class _EnableLocationAccessScreenState
    extends ConsumerState<EnableLocationAccessScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.dropDownBorder),
                      ),
                      child: Center(
                        child: SvgPicture.asset('assets/images/MapPin.svg'),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      "Enable Location Access",
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "DigV needs your location to find the best verified technicians closest to you.",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: ref.watch(authProvider).isLoading
                          ? null
                          : () async {
                              try {
                                final bool serviceEnabled =
                                    await Geolocator.isLocationServiceEnabled();
                                if (!serviceEnabled) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Location services are disabled.'),
                                      ),
                                    );
                                  }
                                  return;
                                }

                                LocationPermission permission =
                                    await Geolocator.checkPermission();
                                if (permission == LocationPermission.denied) {
                                  permission =
                                      await Geolocator.requestPermission();
                                  if (permission == LocationPermission.denied) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Location permissions are denied'),
                                        ),
                                      );
                                    }
                                    return;
                                  }
                                }

                                if (permission ==
                                    LocationPermission.deniedForever) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Location permissions are permanently denied, we cannot request permissions.'),
                                      ),
                                    );
                                  }
                                  return;
                                }

                                final Position position =
                                    await Geolocator.getCurrentPosition();

                                final List<Placemark> placemarks =
                                    await placemarkFromCoordinates(
                                        position.latitude, position.longitude);
                                final Placemark place = placemarks.isNotEmpty
                                    ? placemarks.first
                                    : const Placemark();

                                final data = {
                                  "lat": position.latitude,
                                  "lng": position.longitude,
                                  "addressLine": [
                                    place.name,
                                    place.street,
                                    place.subLocality,
                                  ]
                                      .where((e) => e != null && e.isNotEmpty)
                                      .join(', '),
                                  "city": [
                                    place.locality,
                                    place.subAdministrativeArea,
                                    place.administrativeArea,
                                    'Unknown City'
                                  ].firstWhere((c) => c != null && c.trim().length >= 2)!,
                                  "accuracy": position.accuracy.toInt(),
                                };

                                await ref
                                    .read(authProvider.notifier)
                                    .updateLocation(data);
                                if (context.mounted) {
                                  context.push('/home');
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        elevation: 0,
                      ),
                      child: ref.watch(authProvider).isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Allow location access',
                              style: AppTextStyles.button,
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => context.push('/home'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        side: BorderSide(color: Theme.of(context).dividerColor),
                        elevation: 0,
                      ),
                      child: Text(
                        'Not Now',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
