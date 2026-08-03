import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/core/widgets/app_primary_button.dart';
import 'package:digv/core/utils/snackbar_utils.dart';
import 'package:digv/features/booking_engine/domain/date_item.dart';
import 'package:digv/features/booking_engine/presentation/providers/booking_provider.dart';
import 'package:digv/features/orders/domain/models/order_item.dart';
import 'package:digv/features/orders/presentation/providers/orders_provider.dart';

class RescheduleBottomSheet extends ConsumerStatefulWidget {
  final OrderItem order;

  const RescheduleBottomSheet({super.key, required this.order});

  static void show(BuildContext context, OrderItem order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RescheduleBottomSheet(order: order),
    );
  }

  @override
  ConsumerState<RescheduleBottomSheet> createState() => _RescheduleBottomSheetState();
}

class _RescheduleBottomSheetState extends ConsumerState<RescheduleBottomSheet> {
  int _selectedDateIndex = 0;
  int? _selectedTimeIndex;
  bool _isSubmitting = false;

  late final List<DateItem> _dates;

  @override
  void initState() {
    super.initState();
    _dates = _generateDates();
  }

  List<DateItem> _generateDates() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return List.generate(7, (index) {
      final date = now.add(Duration(days: index));
      return DateItem(
        day: days[date.weekday - 1],
        date: date.day,
        month: months[date.month - 1],
      );
    });
  }

  String _formatScheduledDate(DateItem dateItem) {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final monthIdx = months.indexOf(dateItem.month) + 1;
    final year = now.year;
    final mm = monthIdx.toString().padLeft(2, '0');
    final dd = dateItem.date.toString().padLeft(2, '0');
    return '$year-$mm-$dd';
  }

  String _formatTime12H(String time24) {
    try {
      final parts = time24.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      final minuteStr = minute.toString().padLeft(2, '0');
      return '$hour12:$minuteStr $period';
    } catch (_) {
      return time24;
    }
  }

  String _ctaLabel(List<Map<String, dynamic>> slots) {
    if (_selectedTimeIndex == null || _selectedTimeIndex! >= slots.length) return 'Select a time slot';
    final slot = slots[_selectedTimeIndex!];
    final startTimeStr = _formatTime12H(slot['startTime'] as String? ?? '00:00');
    final endTimeStr = _formatTime12H(slot['endTime'] as String? ?? '00:00');
    return 'Confirm reschedule at $startTimeStr - $endTimeStr';
  }

  Future<void> _submitReschedule(String slotId, String dateStr) async {
    setState(() => _isSubmitting = true);
    try {
      await ref.read(ordersProvider('ACTIVE').notifier).rescheduleServiceRequest(
        id: widget.order.id,
        scheduledDate: dateStr,
        availabilitySlotIds: [slotId],
      );
      ref.invalidate(ordersProvider('ACTIVE'));
      ref.invalidate(ordersProvider('UPCOMING'));
      if (mounted) {
        SnackBarUtils.showSuccess(context, 'Order rescheduled successfully!');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to reschedule order.';
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
    final selectedDate = _dates[_selectedDateIndex];
    final dateStr = _formatScheduledDate(selectedDate);
    final providerId = widget.order.providerId;

    final AsyncValue<List<Map<String, dynamic>>>? slotsAsync = providerId != null
        ? ref.watch(availableSlotsProvider('$providerId|$dateStr'))
        : null;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
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
            
            if (providerId == null)
              _buildNoProviderWarning()
            else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel('Select Date'),
                    const SizedBox(height: 12),
                    _buildDateSelector(),
                    const SizedBox(height: 24),
                    _buildSectionLabel('Select Time Slot'),
                    const SizedBox(height: 12),
                    if (slotsAsync != null)
                      slotsAsync.when(
                        data: (slots) => _buildTimeGrid(slots),
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 36),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (err, _) => Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 36),
                            child: Text(
                              'Failed to load slots: $err',
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (slotsAsync != null)
                slotsAsync.when(
                  data: (slots) {
                    final canConfirm = _selectedTimeIndex != null &&
                        _selectedTimeIndex! < slots.length &&
                        !_isSubmitting;
                    return Container(
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
                              text: _ctaLabel(slots),
                              onTap: canConfirm
                                  ? () {
                                      final slot = slots[_selectedTimeIndex!];
                                      final slotId = slot['availabilitySlotId'] as String;
                                      _submitReschedule(slotId, dateStr);
                                    }
                                  : null,
                            ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
            ],
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
                'Reschedule Service',
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

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.titleLight.copyWith(
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final selected = _selectedDateIndex == i;
          final item = _dates[i];
          return GestureDetector(
            onTap: () => setState(() {
              _selectedDateIndex = i;
              _selectedTimeIndex = null;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 68,
              decoration: BoxDecoration(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.day,
                    style: AppTextStyles.captionSmall.copyWith(
                      height: 1.4,
                      color: selected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.date}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: selected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.month,
                    style: AppTextStyles.captionSmall.copyWith(
                      height: 1.4,
                      color: selected ? AppColors.textGray : Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeGrid(List<Map<String, dynamic>> slots) {
    if (slots.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 36),
          child: Text(
            'No available slots for this date',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final List<Widget> rows = [];
    for (int i = 0; i < slots.length; i += 2) {
      final hasSecond = i + 1 < slots.length;
      rows.add(
        Row(
          children: [
            Expanded(child: _buildTimeSlot(slots, i)),
            const SizedBox(width: 10),
            hasSecond ? Expanded(child: _buildTimeSlot(slots, i + 1)) : const Expanded(child: SizedBox()),
          ],
        ),
      );
      if (i + 2 < slots.length) rows.add(const SizedBox(height: 10));
    }
    return Column(children: rows);
  }

  Widget _buildTimeSlot(List<Map<String, dynamic>> slots, int index) {
    final selected = _selectedTimeIndex == index;
    final slot = slots[index];
    final unavailable = !(slot['isAvailable'] as bool? ?? false);

    final startTimeStr = _formatTime12H(slot['startTime'] as String? ?? '00:00');
    final endTimeStr = _formatTime12H(slot['endTime'] as String? ?? '00:00');
    final label = '$startTimeStr - $endTimeStr';

    Color bgColor;
    Color borderColor;
    Color textColor;
    Color iconColor;

    if (selected) {
      bgColor = Theme.of(context).colorScheme.primary;
      borderColor = AppColors.dropDownBorder;
      textColor = Theme.of(context).colorScheme.onPrimary;
      iconColor = Theme.of(context).colorScheme.onPrimary;
    } else if (unavailable) {
      bgColor = AppColors.inputBgSecondary;
      borderColor = AppColors.inputBorder;
      textColor = AppColors.textGray;
      iconColor = AppColors.textGray;
    } else {
      bgColor = Theme.of(context).colorScheme.surface;
      borderColor = AppColors.dropDownBorder;
      textColor = Theme.of(context).colorScheme.primary;
      iconColor = Theme.of(context).colorScheme.primary;
    }

    return GestureDetector(
      onTap: unavailable
          ? null
          : () => setState(() {
                _selectedTimeIndex = selected ? null : index;
              }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 52,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/clock.svg',
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.captionMedium.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoProviderWarning() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFD97706),
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Professional Assigned Yet',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontFamily: AppTextStyles.fontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We are currently matching your request with the best technician. Rescheduling is available once a provider has been assigned.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontFamily: AppTextStyles.fontFamily,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.onLight,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Go Back'),
            ),
          ),
        ],
      ),
    );
  }
}
