import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/core/widgets/app_primary_button.dart';
import 'package:digv/core/widgets/app_top_bar.dart';
import 'package:digv/features/booking_engine/domain/date_item.dart';
import 'package:digv/features/booking_engine/domain/technician.dart';
import 'package:digv/features/booking_engine/presentation/providers/booking_provider.dart';
import 'package:digv/features/search/domain/entities/search_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SelectDateTimeScreen extends ConsumerStatefulWidget {
  final SearchServiceEntity service;
  final Technician technician;

  const SelectDateTimeScreen({
    super.key,
    required this.service,
    required this.technician,
  });

  @override
  ConsumerState<SelectDateTimeScreen> createState() => _SelectDateTimeScreenState();
}

class _SelectDateTimeScreenState extends ConsumerState<SelectDateTimeScreen> {
  int _selectedDateIndex = 0;
  int? _selectedTimeIndex;

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
    return 'Confirm booking at $startTimeStr - $endTimeStr';
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = _dates[_selectedDateIndex];
    final dateStr = _formatScheduledDate(selectedDate);

    final slotsAsync = ref.watch(availableSlotsProvider(
      '${widget.technician.providerId ?? ''}|$dateStr',
    ));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AppTopBar(title: 'Select a Date & Time'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel('Select Date'),
                    const SizedBox(height: 12),
                    _buildDateSelector(),
                    const SizedBox(height: 20),
                    _buildSectionLabel('Select Time Slot'),
                    const SizedBox(height: 12),
                    slotsAsync.when(
                      data: (slots) => _buildTimeGrid(slots),
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (err, _) => Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'Failed to load slots: $err',
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: const Border(top: BorderSide(color: AppColors.dropDownBorder)),
          ),
          child: slotsAsync.when(
            data: (slots) {
              final canConfirm = _selectedTimeIndex != null && _selectedTimeIndex! < slots.length;
              return AppPrimaryButton(
                text: _ctaLabel(slots),
                onTap: canConfirm ? () {
                  final slot = slots[_selectedTimeIndex!];
                  final startTimeStr = _formatTime12H(slot['startTime'] as String? ?? '00:00');
                  final endTimeStr = _formatTime12H(slot['endTime'] as String? ?? '00:00');
                  final label = '$startTimeStr - $endTimeStr';
                  
                  final selectedTimeEncoded = '$label|${slot["availabilitySlotId"]}';
                  
                  context.push('/review_booking', extra: (
                    widget.service,
                    widget.technician,
                    selectedDate,
                    selectedTimeEncoded,
                  ));
                } : null,
              );
            },
            loading: () => const AppPrimaryButton(text: 'Loading slots...', onTap: null),
            error: (_, __) => const AppPrimaryButton(text: 'Error loading slots', onTap: null),
          ),
        ),
      ),
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
                color: selected ? Theme.of(context).colorScheme.primary : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected ? Theme.of(context).colorScheme.primary : AppColors.dropDownBorder,
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
                      color: selected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.date}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: selected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.primary,
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
          padding: const EdgeInsets.symmetric(vertical: 24),
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
            SvgPicture.asset('assets/images/clock.svg', color: iconColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.captionMedium.copyWith(
                color: textColor
              )
            ),
          ],
        ),
      ),
    );
  }
}
