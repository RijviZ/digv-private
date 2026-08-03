import 'package:digv/I10n/app_localizations.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SetupMoreDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> profileData;

  const SetupMoreDetailsScreen({super.key, required this.profileData});

  @override
  ConsumerState<SetupMoreDetailsScreen> createState() =>
      _SetupMoreDetailsScreenState();
}

class _SetupMoreDetailsScreenState extends ConsumerState<SetupMoreDetailsScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _dobController.dispose();
    _referralController.dispose();
    super.dispose();
  }

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
              GestureDetector(
                onTap: () => context.pop(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 6,
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/images/CaretLeft.svg'),
                      const SizedBox(width: 8),
                      Text(
                        'Back',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Complete Your Profile",
                style: AppTextStyles.h3.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  height: 1.75,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Just few more details to give you best security",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  height: 1.50,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [

                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          enableSuggestions: false,
                          autocorrect: false,
                          autofillHints: null,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(16),
                            hintText: 'Email',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintStyle: AppTextStyles.bodyLarge.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                          ),
                          child: TextField(
                            controller: _dobController,
                            readOnly: true,
                            onTap: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: Theme.of(context).colorScheme.primary,
                                        onPrimary: Theme.of(context).colorScheme.onPrimary,
                                        onSurface: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (pickedDate != null) {
                                final formattedDate = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                setState(() {
                                  _dobController.text = formattedDate;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              hintText: 'Date of Birth',
                              border: InputBorder.none,
                              suffixIconConstraints: const BoxConstraints(
                                minHeight: 20,
                                minWidth: 20,
                                maxHeight: 20,
                                maxWidth: 20,
                              ),
                              suffixIcon: SizedBox(
                                height: 20,
                                width: 20,
                                child: SvgPicture.asset(
                                  'assets/images/CalendarBlank.svg',
                                  height: 20,
                                  width: 20,
                                ),
                              ),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              hintStyle: AppTextStyles.bodyLarge.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                          ),
                          child: TextField(
                            controller: _referralController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              hintText: 'Referral code (optional)',
                              border: InputBorder.none,
                              suffixIconConstraints: const BoxConstraints(
                                minHeight: 20,
                                minWidth: 20,
                                maxHeight: 20,
                                maxWidth: 20,
                              ),
                              suffixIcon: SizedBox(
                                height: 20,
                                width: 20,
                                child: SvgPicture.asset(
                                  'assets/images/Gift.svg',
                                  height: 20,
                                  width: 20,
                                ),
                              ),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              hintStyle: AppTextStyles.bodyLarge.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: ref.watch(authProvider).isLoading
                      ? null
                      : () async {
                          final data = Map<String, dynamic>.from(widget.profileData);
                          data['email'] = _emailController.text.trim();
                          data['dateOfBirth'] = _dobController.text.trim();
                          final referral = _referralController.text.trim();
                          if (referral.isNotEmpty) {
                            data['referredByCode'] = referral;
                          }

                          try {
                            await ref.read(authProvider.notifier).updateProfile(data);
                            if (context.mounted) {
                              context.push('/enable_location_access');
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
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    elevation: 0,
                  ),
                  child: ref.watch(authProvider).isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.onPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context)!.continue_btn,
                          style: AppTextStyles.button.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
