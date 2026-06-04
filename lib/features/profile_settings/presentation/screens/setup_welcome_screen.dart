import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SetupWelcomeScreen extends StatelessWidget {
  final String phoneNumber;

  const SetupWelcomeScreen({super.key, this.phoneNumber = ''});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .surface,
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
                  child: SvgPicture.asset('assets/images/HandWaving.svg'),
                ),
              ),
              const SizedBox(height: 32),
              const Text("Welcome to HomeServ", style: AppTextStyles.h3),
              const SizedBox(height: 12),
              Text(
                "You're new here! Set up your profile to get the full experience - or jump in and do it later.",
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .secondary,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
          SizedBox(
          width: double.infinity,
          child: ElevatedButton(
              onPressed: () {
                context.push('/setup_personal_details', extra: phoneNumber);
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 10),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme
              .of(
            context,
          )
              .colorScheme
              .onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          elevation: 0,
        ),
        child: Text('Setup Profile', style: AppTextStyles.button),
      ),
    ),
    const SizedBox(height: 16),
    SizedBox(
    width: double.infinity,
    child: OutlinedButton(
    onPressed: () => context.push('/home'),
    style: OutlinedButton.styleFrom(
      padding: EdgeInsetsGeometry.symmetric(vertical: 14),
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
