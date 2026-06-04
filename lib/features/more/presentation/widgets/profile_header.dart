import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/features/auth/domain/entities/user.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final User user;
  const ProfileHeader({super.key, required this.user});

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
          backgroundImage: NetworkImage(
            (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                ? user.avatarUrl!
                : 'https://upload.wikimedia.org/wikipedia/commons/9/9e/Placeholder_Person.jpg',
          ),
        ),
        const SizedBox(width: 16),
        // Name / phone / email
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (user.fullName != null && user.fullName!.isNotEmpty) ? user.fullName! : 'User',
                style: AppTextStyles.h4.copyWith(
                  color: theme.colorScheme.primary,
                  fontFamily: AppTextStyles.fontFamilyPoppins,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.30,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${user.countryCode} ${user.phoneNumber}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: theme.colorScheme.secondary,
                  fontFamily: AppTextStyles.fontFamilyPoppins,
                  fontWeight: FontWeight.w400,
                ),
              ),
              if (user.email != null && user.email!.isNotEmpty)
                Text(
                  user.email!,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: theme.colorScheme.secondary,
                    fontFamily: AppTextStyles.fontFamilyPoppins,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
