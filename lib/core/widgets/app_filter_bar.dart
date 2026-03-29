import 'package:digv/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppFilterBar extends StatelessWidget {
  final List<String> items;
  final String selectedItem;
  final Function(String) onSelected;
  final EdgeInsets padding;

  const AppFilterBar({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        padding: padding,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = item == selectedItem;
          return GestureDetector(
            onTap: () => onSelected(item),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary 
                      : Theme.of(context).dividerColor,
                ),
              ),
              child: Center(
                child: Text(
                  item,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
