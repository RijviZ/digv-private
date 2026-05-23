import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/core/widgets/app_primary_button.dart';
import 'package:digv/core/utils/snackbar_utils.dart';
import 'package:digv/features/orders/domain/models/order_item.dart';
import 'package:digv/features/orders/presentation/providers/orders_provider.dart';

class CancelBottomSheet extends ConsumerStatefulWidget {
  final OrderItem order;
  final VoidCallback? onCancelSuccess;

  const CancelBottomSheet({super.key, required this.order, this.onCancelSuccess});

  static void show(BuildContext context, OrderItem order, {VoidCallback? onCancelSuccess}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CancelBottomSheet(order: order, onCancelSuccess: onCancelSuccess),
    );
  }

  @override
  ConsumerState<CancelBottomSheet> createState() => _CancelBottomSheetState();
}

class _CancelBottomSheetState extends ConsumerState<CancelBottomSheet> {
  final List<String> _reasons = [
    'I no longer need this service',
    'Technician is delayed / not responding',
    'Found another professional / option',
    'Schedule changed / not available',
    'Other',
  ];

  String _selectedReason = 'I no longer need this service';
  final TextEditingController _customReasonCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _customReasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitCancel() async {
    final finalReason = _selectedReason == 'Other'
        ? _customReasonCtrl.text.trim()
        : _selectedReason;

    if (finalReason.isEmpty) {
      SnackBarUtils.showError(context, 'Please specify a reason for cancellation.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(ordersProvider('ACTIVE').notifier).cancelServiceRequest(
        id: widget.order.id,
        reason: finalReason,
      );
      ref.invalidate(ordersProvider('ACTIVE'));
      ref.invalidate(ordersProvider('UPCOMING'));
      ref.invalidate(ordersProvider('CANCELLED'));
      if (mounted) {
        SnackBarUtils.showSuccess(context, 'Order cancelled successfully.');
        Navigator.of(context).pop();
        if (widget.onCancelSuccess != null) {
          widget.onCancelSuccess!();
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to cancel order.';
        try {
          final dynamic errorData = (e as dynamic).response?.data;
          if (errorData is Map && errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          } else {
            errorMessage = e.toString();
          }
        } catch (_) {
          errorMessage = e.toString();
        }
        SnackBarUtils.showError(context, errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
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
            const SizedBox(height: 16),
            Center(child: _buildDragHandle()),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildHeader(context),
            ),
            const Divider(color: AppColors.dropDownBorder, height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Why are you cancelling?',
                      style: AppTextStyles.bodyMediumBold.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._reasons.map((reason) => _buildReasonTile(reason)),
                    if (_selectedReason == 'Other') ...[
                      const SizedBox(height: 12),
                      _buildCustomReasonInput(),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.dropDownBorder)),
              ),
              child: _isSubmitting
                  ? Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withAlpha(128),
                        borderRadius: BorderRadius.circular(36),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    )
                  : AppPrimaryButton(
                      text: 'Cancel Request',
                      onTap: _submitCancel,
                    ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 48,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.dropDownBorder.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cancel Service',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontFamily: AppTextStyles.fontFamily,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${widget.order.serviceName} • ${widget.order.orderId}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontFamily: AppTextStyles.fontFamily,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.bg,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              'assets/images/close.svg',
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(AppColors.textDark, BlendMode.srcIn),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReasonTile(String reason) {
    final isSelected = _selectedReason == reason;

    return GestureDetector(
      onTap: () => setState(() {
        _selectedReason = reason;
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary.withAlpha(15) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : AppColors.dropDownBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Theme.of(context).colorScheme.primary : AppColors.textSecondary,
                  width: isSelected ? 6 : 2,
                ),
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                reason,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected ? Theme.of(context).colorScheme.primary : AppColors.textDark,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomReasonInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dropDownBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _customReasonCtrl,
        maxLines: 3,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: 'Please write down your reason...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
