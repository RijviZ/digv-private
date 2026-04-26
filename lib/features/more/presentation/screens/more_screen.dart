import 'package:digv/features/more/presentation/widgets/logout_button.dart';
import 'package:digv/features/more/presentation/widgets/profile_header.dart';
import 'package:digv/features/more/presentation/widgets/section_card.dart';
import 'package:digv/features/more/presentation/widgets/stats_bar.dart';
import 'package:digv/features/more/presentation/widgets/support_section.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(28, 16, 28, 0),
              child: ProfileHeader(),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 28),
              child: StatsBar(),
            ),

            const SizedBox(height: 28),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionCard(
                    title: 'ACCOUNT',
                    items: [
                      MenuItem(
                        svgAsset: 'assets/images/person.svg',
                        label: 'Edit Profile',
                        onTap: () => context.push('/edit_profile'),
                      ),
                      MenuItem(
                        svgAsset: 'assets/images/pin_g.svg',
                        label: 'Manage Addresses',
                        onTap: () => context.push('/manage_addresses'),
                      ),
                      MenuItem(
                        svgAsset: 'assets/images/card.svg',
                        label: 'Saved Payment Methods',
                        onTap: () => context.push('/payment_methods'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // PREFERENCES
                  SectionCard(
                    title: 'PREFERENCES',
                    items: [
                      MenuItem(
                        svgAsset: 'assets/images/notification.svg',
                        label: 'Notification Settings',
                        onTap: () => context.push('/notification_settings'),
                      ),
                      MenuItem(
                        svgAsset: 'assets/images/settings.svg',
                        label: 'App Settings',
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
    );
  }
}
