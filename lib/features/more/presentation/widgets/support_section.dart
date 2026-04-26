import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/features/more/presentation/widgets/menu_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:digv/features/more/presentation/widgets/share_app_bottom_sheet.dart';

class SupportSection extends StatelessWidget {
  const SupportSection({super.key});

  static const Color _amber = Color(0xFFCA8A04);
  static const Color _amberLight = Color(0xFFFEF9C3);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.06),
              border: Border(
                bottom: BorderSide(color: theme.dividerColor),
              ),
            ),
            child: Text(
              'SUPPORT',
              style: AppTextStyles.caption.copyWith(
                color: theme.colorScheme.secondary,
              fontFamily: AppTextStyles.fontFamilyPoppins,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.60,
              ),
            ),
          ),
          // Items
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            child: Container(
              color: theme.colorScheme.surface,
              child: Column(
                children: [
                  MenuItemTile(
                    svgAsset: 'assets/images/help.svg',
                    label: 'Help Center',
                    onTap: () => context.push('/help_center'),
                  ),
                  Divider(height: 1, color: theme.dividerColor),
                  MenuItemTile(
                    svgAsset: 'assets/images/message.svg',
                    label: 'FAQs',
                    onTap: () => context.push('/faqs'),
                  ),
                  Divider(height: 1, color: theme.dividerColor),
                  MenuItemTile(
                    svgAsset: 'assets/images/send.svg',
                    label: 'Contact Support',
                    onTap: () => context.push('/contact_support'),
                  ),
                  Divider(height: 1, color: theme.dividerColor),
                  MenuItemTile(
                    svgAsset: 'assets/images/cancel.svg',
                    label: 'Report an Issue',
                    iconColor: theme.colorScheme.error,
                  ),
                  Divider(height: 1, color: theme.dividerColor),

                  InkWell(
                    onTap: () => ShareAppBottomSheet.show(context),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _amberLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(11),
                              child: SvgPicture.asset(
                                'assets/images/Gift.svg',
                                colorFilter: const ColorFilter.mode(
                                  _amber,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Refer & Earn',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontSize: 14,
                                    fontFamily:
                                        AppTextStyles.fontFamilyPoppins,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                                ),
                                const Text(
                                  'Invite friends · Get ₹50 per booking',
                                  style: TextStyle(
                                    color: _amber,
                                    fontSize: 11,
                                    fontFamily: AppTextStyles.fontFamilyPoppins,
                                    fontWeight: FontWeight.w600,
                                    height: 1.5,
                                  ),
                                ),
                              ],
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
