import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/features/more/presentation/widgets/menu_item_tile.dart';
import 'package:flutter/material.dart';

class MenuItem {
  final String? svgAsset;
  final IconData? icon;
  final String label;
  final VoidCallback? onTap;

  const MenuItem({
    this.svgAsset,
    this.icon,
    required this.label,
    this.onTap,
  }) : assert(svgAsset != null || icon != null,
            'Provide either svgAsset or icon');
}

class SectionCard extends StatelessWidget {
  final String title;
  final List<MenuItem> items;

  const SectionCard({
    super.key,
    required this.title,
    required this.items,
  });

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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.06),
              border: Border(
                bottom: BorderSide(color: theme.dividerColor),
              ),
            ),
            child: Text(
              title,
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
                children: items.asMap().entries.map((entry) {
                  final isLast = entry.key == items.length - 1;
                  final item = entry.value;
                  return Column(
                    children: [
                      MenuItemTile(
                        svgAsset: item.svgAsset,
                        icon: item.icon,
                        label: item.label,
                        onTap: item.onTap,
                      ),
                      if (!isLast)
                        Divider(height: 1, color: theme.dividerColor),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
