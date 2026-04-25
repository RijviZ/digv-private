import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/features/booking_engine/domain/models/order_status.dart';
import 'package:flutter/material.dart';

class OrderDetailsCard extends StatelessWidget {
  final PaymentType paymentType;

  const OrderDetailsCard({super.key, required this.paymentType});

  bool get _isPrepaid => paymentType == PaymentType.prepaid;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Details',
            style: AppTextStyles.captionMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),
          const DetailRow(label: 'Service', value: 'Deep Cleaning'),
          const DetailRow(label: 'Type', value: 'Split'),
          const DetailRow(label: 'Schedule', value: 'Today · 10:00 AM'),
          const DetailRow(
            label: 'Address',
            value: 'Home — Jl. Ngagelrejo No.34,\nKhulna — 9000',
          ),
          DetailRow(
            label: 'Payment',
            value: _isPrepaid
                ? '₹400 · Google Pay · Paid'
                : '₹500 · Postpaid (Pay after service)',
            valueColor: _isPrepaid ? null : AppColors.alertText,
          ),
        ],
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
