import 'package:digv/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'booking_detail_item.dart';
import 'booking_detail_row.dart';

class BookingDetailsCard extends StatelessWidget {
  final List<BookingDetailItem> items;

  const BookingDetailsCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.inputBgSecondary,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final isLast = entry.key == items.length - 1;
          return Column(
            children: [
              BookingDetailRow(item: entry.value),
              if (!isLast) ...[
                const SizedBox(height: 16),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }
}
