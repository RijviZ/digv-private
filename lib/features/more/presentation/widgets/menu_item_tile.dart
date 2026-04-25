import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MenuItemTile extends StatelessWidget {
  final String? svgAsset;
  final IconData? icon;
  final String label;
  final Color? iconBgColor;
  final Color? iconColor;
  final Widget? subtitle;
  final VoidCallback? onTap;

  const MenuItemTile({
    super.key,
    this.svgAsset,
    this.icon,
    required this.label,
    this.iconBgColor,
    this.iconColor,
    this.subtitle,
    this.onTap,
  }) : assert(svgAsset != null || icon != null,
            'Provide either svgAsset or icon');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedIconBg = iconBgColor ?? AppColors.inputBgSecondary;
    final resolvedBorder = iconBgColor == null
        ? Border.all(color: theme.dividerColor)
        : null;
    final resolvedRadius = iconBgColor != null ? 12.0 : 4.0;
    final resolvedIconColor = iconColor ?? theme.colorScheme.secondary;

    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: resolvedIconBg,
                borderRadius: BorderRadius.circular(resolvedRadius),
                border: resolvedBorder,
              ),
              child: svgAsset != null
                  ? Padding(
                      padding: const EdgeInsets.all(11),
                      child: SvgPicture.asset(
                        svgAsset!,
                        colorFilter: ColorFilter.mode(
                          resolvedIconColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    )
                  : Icon(icon, size: 18, color: resolvedIconColor),
            ),
            const SizedBox(width: 12),
            // Label (+ optional subtitle)
            Expanded(
              child: subtitle != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: AppTextStyles.h6.copyWith(
                            color: theme.colorScheme.primary,
                            fontFamily: AppTextStyles.fontFamilyPoppins,
                          ),
                        ),
                        subtitle!,
                      ],
                    )
                  : Text(
                      label,
                      style: AppTextStyles.h6.copyWith(
                        color: theme.colorScheme.primary,
                        fontFamily: AppTextStyles.fontFamilyPoppins,
                      ),
                    ),
            ),
            SvgPicture.asset(
              'assets/images/arrow-right.svg',
              colorFilter: ColorFilter.mode(
                theme.colorScheme.secondary,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
