import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/failure.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../orders/domain/models/order_item.dart';
import '../providers/disputes_provider.dart';

class RaiseDisputeBottomSheet extends ConsumerStatefulWidget {
  final OrderItem order;
  final VoidCallback? onDisputeSubmitted;

  const RaiseDisputeBottomSheet({
    super.key,
    required this.order,
    this.onDisputeSubmitted,
  });

  static Future<void> show(
    BuildContext context, {
    required OrderItem order,
    VoidCallback? onDisputeSubmitted,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RaiseDisputeBottomSheet(
        order: order,
        onDisputeSubmitted: onDisputeSubmitted,
      ),
    );
  }

  @override
  ConsumerState<RaiseDisputeBottomSheet> createState() =>
      _RaiseDisputeBottomSheetState();
}

class _RaiseDisputeBottomSheetState
    extends ConsumerState<RaiseDisputeBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _reasonController;

  final List<String> _presetReasons = [
    'The service was not completed as promised and quality was poor.',
    'Technician did not show up or was excessively delayed.',
    'Charged extra amount not agreed upon.',
    'Damages occurred to property during service.',
    'Technician was unprofessional or rude.',
    'Other issue',
  ];

  String? _selectedPreset;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final defaultAmount = _parseOrderAmount(widget.order.price);
    _amountController = TextEditingController(
      text: defaultAmount > 0 ? defaultAmount.toStringAsFixed(0) : '',
    );
    _reasonController = TextEditingController();
  }

  double _parseOrderAmount(String? priceStr) {
    if (priceStr == null) return 0.0;
    final clean = priceStr.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(clean) ?? 0.0;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _selectPreset(String preset) {
    setState(() {
      _selectedPreset = preset;
      if (preset != 'Other issue') {
        _reasonController.text = preset;
      } else {
        _reasonController.clear();
      }
    });
  }

  Future<void> _submitDispute() async {
    if (!_formKey.currentState!.validate()) return;

    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText) ?? 0.0;
    final reason = _reasonController.text.trim();

    if (amount <= 0) {
      SnackBarUtils.showError(context, 'Please enter a valid dispute amount.');
      return;
    }

    if (reason.length < 5) {
      SnackBarUtils.showError(
        context,
        'Please provide a detailed reason (at least 5 characters).',
      );
      return;
    }

    final serviceRequestId = widget.order.id.trim();
    if (serviceRequestId.isEmpty) {
      SnackBarUtils.showError(context, 'Unable to submit dispute: service request ID is missing.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(disputeNotifierProvider.notifier).submitDispute(
            serviceRequestId: serviceRequestId,
            amountInDispute: amount,
            reason: reason,
          );

      if (mounted) {
        Navigator.of(context).pop();
        SnackBarUtils.showSuccess(
          context,
          'Dispute raised successfully. Our team will review it.',
        );
        widget.onDisputeSubmitted?.call();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to submit dispute.';
        if (e is Failure) {
          errorMessage = e.message;
        } else if (e is DioException) {
          errorMessage = Failure.fromDioException(e).message;
        } else {
          try {
            final dynamic errorData = (e as dynamic).response?.data;
            if (errorData is Map && errorData['message'] != null) {
              final msg = errorData['message'];
              if (msg is List) {
                errorMessage = msg.join('\n');
              } else {
                errorMessage = msg.toString();
              }
            } else {
              errorMessage = e.toString().replaceFirst('Exception: ', '');
            }
          } catch (_) {
            errorMessage = e.toString().replaceFirst('Exception: ', '');
          }
        }

        // If duplicate dispute error, invalidate providers so UI reflects existing dispute
        if (errorMessage.toLowerCase().contains('already') ||
            errorMessage.toLowerCase().contains('duplicate')) {
          ref.invalidate(disputesForOrderProvider(serviceRequestId));
          ref.invalidate(myDisputesProvider);
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
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
            Center(child: _buildDragHandle()),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildHeader(context),
            ),
            Divider(color: theme.dividerColor, height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOrderSummaryCard(theme, isDark),
                      const SizedBox(height: 18),
                      Text(
                        'Amount in Dispute',
                        style: AppTextStyles.bodyMediumBold.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildAmountField(theme),
                      const SizedBox(height: 18),
                      Text(
                        'Reason for Dispute',
                        style: AppTextStyles.bodyMediumBold.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildPresetChips(theme),
                      const SizedBox(height: 12),
                      _buildReasonField(theme),
                      const SizedBox(height: 16),
                      _buildInfoBanner(theme),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(top: BorderSide(color: theme.dividerColor)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isSubmitting)
                    Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(128),
                        borderRadius: BorderRadius.circular(36),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    )
                  else
                    AppPrimaryButton(
                      text: 'Submit Dispute',
                      onTap: _submitDispute,
                    ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push(
                        '/contact_support',
                        extra: {
                          'orderId': widget.order.orderId,
                          'subject': 'Service Complaint',
                        },
                      );
                    },
                    child: Text(
                      'Contact Support Instead',
                      style: AppTextStyles.captionMedium.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
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
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: AppColors.errorBg,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.gavel_outlined,
            size: 20,
            color: AppColors.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Raise a Dispute',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppTextStyles.fontFamily,
                ),
              ),
              Text(
                'Order ID: ${widget.order.orderId}',
                style: AppTextStyles.captionMedium.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: () => Navigator.of(context).pop(),
          splashRadius: 20,
        ),
      ],
    );
  }

  Widget _buildOrderSummaryCard(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.inputBgSecondaryDark : AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.order.serviceName,
                  style: AppTextStyles.bodyMediumBold.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                widget.order.price,
                style: AppTextStyles.bodyMediumBold.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 14,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 4),
              Text(
                widget.order.technicianName,
                style: AppTextStyles.captionMedium.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.access_time,
                size: 14,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.order.scheduledTime,
                  style: AppTextStyles.captionMedium.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField(ThemeData theme) {
    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Text(
            '₹',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        hintText: 'Enter disputed amount',
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return 'Dispute amount is required';
        }
        final numVal = double.tryParse(val.trim());
        if (numVal == null || numVal <= 0) {
          return 'Enter a valid amount greater than 0';
        }
        return null;
      },
    );
  }

  Widget _buildPresetChips(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _presetReasons.map((preset) {
        final isSelected = _selectedPreset == preset;
        return InkWell(
          onTap: () => _selectPreset(preset),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withAlpha(25)
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.dividerColor,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Text(
              preset,
              style: AppTextStyles.captionMedium.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReasonField(ThemeData theme) {
    return TextFormField(
      controller: _reasonController,
      minLines: 3,
      maxLines: 5,
      decoration: InputDecoration(
        hintText:
            'Describe the issue in detail so our dispute team can resolve it...',
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return 'Please provide a reason for the dispute';
        }
        if (val.trim().length < 5) {
          return 'Reason must be at least 5 characters';
        }
        return null;
      },
    );
  }

  Widget _buildInfoBanner(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.alertBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.alertBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 18,
            color: AppColors.alertText,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Once submitted, our support and dispute resolution team will review service timeline logs and contact you within 24-48 hours.',
              style: AppTextStyles.captionMedium.copyWith(
                color: AppColors.alertText,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
