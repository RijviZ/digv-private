import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SetupPersonalDetailsScreen extends StatefulWidget {
  final String phoneNumber;

  const SetupPersonalDetailsScreen({super.key, this.phoneNumber = ''});

  @override
  State<SetupPersonalDetailsScreen> createState() =>
      _SetupPersonalDetailsScreenState();
}

class _SetupPersonalDetailsScreenState
    extends State<SetupPersonalDetailsScreen> {
  String _selectedGender = 'Male';
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.phoneNumber);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 6,
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/images/CaretLeft.svg'),
                      const SizedBox(width: 8),
                      Text(
                        'Back',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Set Up Profile",
                style: AppTextStyles.h2.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "A few details to personalize your experience",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  height: 1.50,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: AppColors.dropDownBorder,
                                ),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/images/User.svg',
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Edit",
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(16),
                            hintText: 'Your full name',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintStyle: AppTextStyles.bodyLarge.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  const Text(
                                    "🇮🇳",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '+91',
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 56,
                              color: Theme.of(context).dividerColor,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    hintText: '0987654321',
                                    border: InputBorder.none,
                                    suffixIconConstraints: const BoxConstraints(
                                      minHeight: 20,
                                      minWidth: 20,
                                      maxHeight: 20,
                                      maxWidth: 20,
                                    ),
                                    suffixIcon: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: SvgPicture.asset(
                                        'assets/images/CheckCircle.svg',
                                        height: 20,
                                        width: 20,
                                      ),
                                    ),
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    hintStyle: AppTextStyles.bodyLarge.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Gender",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildGenderOption('Male'),
                          const SizedBox(width: 12),
                          _buildGenderOption('Female'),
                          const SizedBox(width: 12),
                          _buildGenderOption('Other'),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push('/setup_more_details'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    elevation: 0,
                  ),
                  child: const Text("Continue", style: AppTextStyles.button),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderOption(String label) {
    final isSelected = _selectedGender == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGender = label;
          });
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                isSelected
                    ? 'assets/images/CircleSelected.svg'
                    : 'assets/images/CircleNotSelected.svg',
                height: 16,
                width: 16,
                colorFilter: ColorFilter.mode(
                  isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.secondary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.primary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
