import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/core/widgets/app_top_bar.dart';
import 'package:digv/core/widgets/app_primary_button.dart';
import 'package:flutter/material.dart';
import 'package:digv/features/booking_engine/domain/date_item.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SelectDateTimeScreen extends StatefulWidget {
  const SelectDateTimeScreen({super.key});

  @override
  State<SelectDateTimeScreen> createState() => _SelectDateTimeScreenState();
}

class _SelectDateTimeScreenState extends State<SelectDateTimeScreen> {
  int _selectedDateIndex = 1;
  int? _selectedTimeIndex;

  final List<DateItem> _dates = const [
    DateItem(day: 'Fri', date: 3, month: 'Apr'),
    DateItem(day: 'Sat', date: 4, month: 'Apr'),
    DateItem(day: 'Sun', date: 5, month: 'Apr'),
    DateItem(day: 'Mon', date: 6, month: 'Apr'),
    DateItem(day: 'Tue', date: 7, month: 'Apr'),
    DateItem(day: 'Wed', date: 8, month: 'Apr'),
    DateItem(day: 'Thu', date: 9, month: 'Apr'),
  ];

  final List<String> _timeSlots = const [
    '8:00 AM',
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
    '6:00 PM',
  ];

  final Set<int> _unavailableSlots = const {0, 1, 5};

  String get _ctaLabel {
    if (_selectedTimeIndex == null) return 'Select a time slot';
    return 'Confirm booking at ${_timeSlots[_selectedTimeIndex!]}';
  }

  @override
  Widget build(BuildContext context) {
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
                    _buildTimeGrid(),
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
            border: Border(top: BorderSide(color: AppColors.dropDownBorder)),
          ),
          child: AppPrimaryButton(
            text: _ctaLabel,
            onTap: _selectedTimeIndex != null ? () {
              context.push('/review_booking');
            } : null,
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

  Widget _buildTimeGrid() {
    final List<Widget> rows = [];
    for (int i = 0; i < _timeSlots.length; i += 2) {
      final hasSecond = i + 1 < _timeSlots.length;
      rows.add(
        Row(
          children: [
            Expanded(child: _buildTimeSlot(i)),
            const SizedBox(width: 10),
            hasSecond ? Expanded(child: _buildTimeSlot(i + 1)) : const Expanded(child: SizedBox()),
          ],
        ),
      );
      if (i + 2 < _timeSlots.length) rows.add(const SizedBox(height: 10));
    }
    return Column(children: rows);
  }

  Widget _buildTimeSlot(int index) {
    final selected = _selectedTimeIndex == index;
    final unavailable = _unavailableSlots.contains(index);
    final label = _timeSlots[index];

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
