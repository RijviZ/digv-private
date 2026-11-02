import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../orders/domain/models/order_item.dart';
import '../../../orders/presentation/providers/orders_provider.dart';
import '../../domain/entities/dispute_entity.dart';

class DisputeOrderDetailsBottomSheet extends ConsumerStatefulWidget {
  final DisputeEntity dispute;
  final OrderItem? order;

  const DisputeOrderDetailsBottomSheet({
    super.key,
    required this.dispute,
    this.order,
  });

  static Future<void> show(
    BuildContext context, {
    required DisputeEntity dispute,
    OrderItem? order,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DisputeOrderDetailsBottomSheet(
        dispute: dispute,
        order: order,
      ),
    );
  }

  @override
  ConsumerState<DisputeOrderDetailsBottomSheet> createState() =>
      _DisputeOrderDetailsBottomSheetState();
}

class _DisputeOrderDetailsBottomSheetState
    extends ConsumerState<DisputeOrderDetailsBottomSheet> {
  Map<String, dynamic>? _remoteDetails;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDetailsIfNeeded();
  }

  Future<void> _fetchDetailsIfNeeded() async {
    final sId = widget.dispute.serviceRequestId;
    if (sId.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(ordersRepositoryProvider);
      final data = await repo.getServiceRequestById(id: sId);
      if (mounted) {
        setState(() {
          _remoteDetails = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatScheduleDate(dynamic rawDate) {
    if (rawDate == null) return '';
    if (rawDate is String) {
      final dt = DateTime.tryParse(rawDate);
      if (dt != null) {
        final local = dt.toLocal();
        final day = local.day.toString().padLeft(2, '0');
        final month = local.month.toString().padLeft(2, '0');
        final year = local.year;
        final hour =
            local.hour == 0 ? 12 : (local.hour > 12 ? local.hour - 12 : local.hour);
        final minute = local.minute.toString().padLeft(2, '0');
        final ampm = local.hour >= 12 ? 'PM' : 'AM';
        return '$day/$month/$year $hour:$minute $ampm';
      }
      return rawDate;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dispute = widget.dispute;
    final order = widget.order;
    final remote = _remoteDetails;

    // Resolve fields
    final serviceName = remote?['serviceItem']?['name']?.toString() ??
        remote?['serviceName']?.toString() ??
        remote?['title']?.toString() ??
        order?.serviceName ??
        'Service Request';

    final status = remote?['status']?.toString() ??
        order?.status.label.toUpperCase() ??
        'OTP_REQUIRED';

    final customerName = dispute.customerName ??
        remote?['customer']?['name']?.toString() ??
        remote?['customerName']?.toString() ??
        'Customer';

    final phone = dispute.customerPhone ??
        remote?['customer']?['phone']?.toString() ??
        remote?['customerPhone']?.toString() ??
        order?.providerPhoneNumber ??
        'Not available';

    final amountNum = dispute.serviceRequestTotalAmount ??
        (remote?['totalAmount'] is num
            ? (remote?['totalAmount'] as num).toDouble()
            : (order?.unitPrice ?? dispute.amountInDispute));
    final amountText = '₹ ${amountNum.toStringAsFixed(0)}';

    final paymentMode = remote?['paymentStatus']?.toString() ??
        remote?['paymentMethod']?.toString() ??
        order?.paymentStatus ??
        'PAID';

    final address = remote?['address']?['addressLine1']?.toString() ??
        remote?['addressLine']?.toString() ??
        remote?['location']?.toString() ??
        order?.location ??
        'Address not available';

    final description = remote?['description']?.toString() ??
        order?.description ??
        (dispute.reason.isNotEmpty ? dispute.reason : 'No description provided.');

    final scheduledAt = _formatScheduleDate(remote?['scheduledDate']) != ''
        ? _formatScheduleDate(remote?['scheduledDate'])
        : (order?.scheduledTime.isNotEmpty == true
            ? order!.scheduledTime
            : dispute.formattedDateTime);

    final disputeStatusText =
        '#${dispute.displayDisputeNo} (${dispute.status.label.toUpperCase()})';

    final orderCode = dispute.serviceRequestNumber?.isNotEmpty == true
        ? 'SBR${dispute.serviceRequestNumber}'
        : (order?.orderId.isNotEmpty == true
            ? (order!.orderId.startsWith('SBR') ? order.orderId : 'SBR${order.orderId}')
            : (dispute.serviceRequestId.isNotEmpty
                ? 'SBR${dispute.serviceRequestId.length > 6 ? dispute.serviceRequestId.substring(0, 6).toUpperCase() : dispute.serviceRequestId}'
                : ''));

    const orangeColor = Color(0xFFD9531E);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                      fontFamily: AppTextStyles.fontFamily,
                    ),
                  ),
                  if (orderCode.isNotEmpty)
                    Text(
                      orderCode,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.secondary,
                        fontFamily: AppTextStyles.fontFamily,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: theme.dividerColor),
            if (_isLoading)
              const LinearProgressIndicator(
                minHeight: 2,
                color: Color(0xFFD9531E),
                backgroundColor: Colors.transparent,
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  children: [
                    _buildDetailRow(
                      context,
                      label: 'Service Name',
                      value: serviceName,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      label: 'Status',
                      value: status,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      label: 'Customer Name',
                      value: customerName,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      label: 'Phone',
                      value: phone,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      label: 'Amount',
                      value: amountText,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      label: 'Payment Mode',
                      value: paymentMode,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      label: 'Address',
                      value: address,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      label: 'Description',
                      value: description,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      label: 'Scheduled At',
                      value: scheduledAt,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      label: 'Dispute Status',
                      value: disputeStatusText,
                      valueColor: orangeColor,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(top: BorderSide(color: theme.dividerColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: orangeColor, width: 1.5),
                        color: Colors.transparent,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.verified_outlined,
                            size: 18,
                            color: orangeColor,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Disputed',
                            style: TextStyle(
                              color: orangeColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDark ? Colors.white : const Color(0xFF0A0D14),
                          foregroundColor:
                              isDark ? Colors.black : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Close',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.secondary,
              fontFamily: AppTextStyles.fontFamily,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: valueColor ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontFamily: AppTextStyles.fontFamily,
            ),
          ),
        ),
      ],
    );
  }
}
