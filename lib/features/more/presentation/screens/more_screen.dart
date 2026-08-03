import 'package:digv/I10n/app_localizations.dart';
import 'package:digv/features/more/presentation/widgets/logout_button.dart';
import 'package:digv/features/more/presentation/widgets/profile_header.dart';
import 'package:digv/features/more/presentation/widgets/section_card.dart';
import 'package:digv/features/more/presentation/widgets/stats_bar.dart';
import 'package:digv/features/more/presentation/widgets/support_section.dart';
import 'package:digv/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(profileProvider);
    final statsAsync = ref.watch(userStatsProvider);
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(profileProvider);
          ref.invalidate(userStatsProvider);
          try {
            await Future.wait([
              ref.read(profileProvider.future),
              ref.read(userStatsProvider.future),
            ]);
          } catch (_) {}
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
                child: profileAsync.when(
                  data: (user) => ProfileHeader(user: user),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => const Text('Failed to load profile'),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: statsAsync.when(
                  data: (stats) => StatsBar(
                    bookings: stats.totalBookings.toString(),
                    avgRating: stats.avgRating.toStringAsFixed(1),
                    spent: '₹${stats.totalSpent.toStringAsFixed(0)}',
                  ),
                  loading: () => const StatsBar(
                    bookings: '...',
                    avgRating: '...',
                    spent: '...',
                  ),
                  error: (_, __) => const StatsBar(
                    bookings: '0',
                    avgRating: '0.0',
                    spent: '₹0',
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionCard(
                      title: l10n.account.toUpperCase(),
                      items: [
                        MenuItem(
                          svgAsset: 'assets/images/person.svg',
                          label: l10n.edit_profile_title,
                          onTap: () => context.push('/edit_profile'),
                        ),
                        MenuItem(
                          svgAsset: 'assets/images/pin_g.svg',
                          label: l10n.manage_addresses,
                          onTap: () => context.push('/manage_addresses'),
                        ),
                        MenuItem(
                          svgAsset: 'assets/images/card.svg',
                          label: l10n.saved_cards,
                          onTap: () => context.push('/payment_methods'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // PREFERENCES
                    SectionCard(
                      title: l10n.preferences.toUpperCase(),
                      items: [
                        MenuItem(
                          svgAsset: 'assets/images/notification.svg',
                          label: l10n.notification_settings_title,
                          onTap: () => context.push('/notification_settings'),
                        ),
                        MenuItem(
                          svgAsset: 'assets/images/settings.svg',
                          label: l10n.app_settings,
                          onTap: () => context.push('/app_settings'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // SUPPORT
                    const SupportSection(),
                    const SizedBox(height: 16),

                    // LOGOUT
                    const LogoutButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
