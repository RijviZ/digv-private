import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/I10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../../../../core/storage/secure_storage_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for the minimum splash duration (e.g. 2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final storage = ref.read(secureStorageProvider);
    final token = await storage.read(key: 'accessToken');

    if (token == null || token.isEmpty) {
      if (mounted) context.go('/login');
      return;
    }

    try {
      final user = await ref.read(authProvider.notifier).getProfile();
      if (mounted) {
        if (user.fullName == null ||
            user.gender == null ||
            user.email == null ||
            user.dateOfBirth == null ||
            user.avatarUrl == null) {
          context.go('/setup_welcome', extra: user.phoneNumber);
        } else if (user.latestLocation == null || user.latestLocation!.isEmpty) {
          context.go('/enable_location_access');
        } else {
          context.go('/home');
        }
      }
    } catch (e) {
      // Token might be expired or invalid
      if (mounted) context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              FadeTransition(
                opacity: _fadeIn,
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: SvgPicture.asset('assets/images/icon.svg'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.appTitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h1.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      l10n.splash_welcome,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                l10n.app_version,
                style: AppTextStyles.caption.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
