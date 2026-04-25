import 'package:digv/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar
        CircleAvatar(
          radius: 34,
          backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
          backgroundImage: const NetworkImage(
            'https://upload.wikimedia.org/wikipedia/commons/9/9e/Placeholder_Person.jpg',
          ),
        ),
        const SizedBox(width: 16),
        // Name / phone / email
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rahul Das',
              style: AppTextStyles.h4.copyWith(
                color: theme.colorScheme.primary,
                fontFamily: AppTextStyles.fontFamilyPoppins,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.30,
              ),
            ),
            Text(
              '+880 1711 234567',
              style: AppTextStyles.bodyMedium.copyWith(
                color: theme.colorScheme.secondary,
                fontFamily: AppTextStyles.fontFamilyPoppins,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              'rahul@example.com',
              style: AppTextStyles.labelMedium.copyWith(
                color: theme.colorScheme.secondary,
                fontFamily: AppTextStyles.fontFamilyPoppins,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
