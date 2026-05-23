import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/features/booking_engine/domain/models/order_status.dart';
import 'package:digv/features/orders/domain/models/order_item.dart';
import 'package:flutter/material.dart';

class OrderDetailsCard extends StatelessWidget {
  final PaymentType paymentType;
  final OrderItem? order;

  const OrderDetailsCard({super.key, required this.paymentType, this.order});

  bool get _isPrepaid {
    if (order != null) {
      final isPostpaid = order!.paymentStatus == 'UNPAID' ||
          order!.price.toLowerCase().contains('postpaid');
      return !isPostpaid;
    }
    return paymentType == PaymentType.prepaid;
  }

  String _getPaymentMethodLabel() {
    if (order == null) return 'Google Pay';
    final method = order!.paymentMethod;
    if (method == 'CARD') return 'Card';
    if (method == 'UPI') return 'Google Pay';
    if (method == 'BANK_ACCOUNT') return 'Net Banking';
    if (method == 'CASH') return 'Cash';
    return method ?? 'Google Pay';
  }

  @override
  Widget build(BuildContext context) {
    final service = order?.serviceName ?? 'Deep Cleaning';
    final schedule = order?.scheduledTime ?? 'Today · 10:00 AM';
    final address = order?.location ?? 'Home — Jl. Ngagelrejo No.34,\nKhulna — 9000';
    final price = order?.price ?? (_isPrepaid ? '₹400' : '₹500');

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
          DetailRow(label: 'Service', value: service),
          if (order == null) const DetailRow(label: 'Type', value: 'Split'),
          DetailRow(label: 'Schedule', value: schedule),
          DetailRow(
            label: 'Address',
            value: address,
          ),
          DetailRow(
            label: 'Payment',
            value: _isPrepaid
                ? '$price · ${_getPaymentMethodLabel()} · Paid'
                : '$price · Postpaid (Pay after service)',
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
