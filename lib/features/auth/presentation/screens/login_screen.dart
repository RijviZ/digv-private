import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/features/profile_settings/presentation/providers/locale_provider.dart';
import 'package:digv/I10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 32,
                        width: 32,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SizedBox(
                          height: 16,
                          width: 16,
                          child: SvgPicture.asset('assets/images/icon.svg'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.appTitle,
                        style: AppTextStyles.title.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.dropDownBorder),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Locale>(
                        elevation: 0,
                        isDense: true,
                        style: AppTextStyles.labelMedium.copyWith(height: 1.5),
                        iconSize: 18,
                        icon: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: SvgPicture.asset(
                            'assets/images/CaretDown.svg',
                          ),
                        ),
                        value: ref.watch(localeProvider),
                        items: [
                          DropdownMenuItem(
                            value: const Locale('en'),
                            child: Text(
                              'English (US)',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: const Locale('hi'),
                            child: Text(
                              'हिन्दी',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: const Locale('bn'),
                            child: Text(
                              'বাংলা',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (Locale? newLocale) {
                          if (newLocale != null) {
                            ref
                                .read(localeProvider.notifier)
                                .setLocale(newLocale);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Text(
                l10n.login_title,
                style: AppTextStyles.h2.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.login_subtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Text("🇮🇳", style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            '+91',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 56,
                      color: Theme.of(context).dividerColor,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            hintText: '0987654321',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintStyle: AppTextStyles.bodyLarge.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final phone = _phoneController.text.trim();
                    if (phone.isNotEmpty) {
                      context.push('/otp', extra: '+91 $phone');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    elevation: 0,
                  ),
                  child: Text(l10n.send_otp, style: AppTextStyles.button),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Divider(color: Theme.of(context).dividerColor),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      'OR',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Theme.of(context).dividerColor),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    side: BorderSide(color: Theme.of(context).dividerColor),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 20,
                        width: 20,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: SvgPicture.asset('assets/images/google.svg'),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Continue with Google',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.caption.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    height: 1.5,
                  ),
                  children: const [
                    TextSpan(text: 'By continuing, you agree to our '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                    TextSpan(text: ' & '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
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
