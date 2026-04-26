import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/core/widgets/app_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FaqsScreen extends StatefulWidget {
  const FaqsScreen({super.key});

  @override
  State<FaqsScreen> createState() => _FaqsScreenState();
}

class _FaqsScreenState extends State<FaqsScreen> {
  int _selectedCategoryIndex = 0;
  int? _expandedFaqIndex = 0;

  final List<String> _categories = [
    'All (19)',
    'Booking (5)',
    'Payment (4)',
    'Service (4)',
  ];

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I book a home service?',
      'answer':
          'Simply open the app, browse service categories (AC, Electrical, Plumbing, Cleaning etc.), choose a service, select an available technician based on ratings and reviews, pick your preferred time slot, and confirm your booking. You\'ll receive an instant confirmation notification.',
      'category': 'Booking',
    },
    {
      'question': 'Can I book for someone else\'s address?',
      'answer': '',
      'category': 'Booking',
    },
    {
      'question': 'How far in advance can I schedule a booking?',
      'answer': '',
      'category': 'Booking',
    },
    {
      'question': 'What is the cancellation policy?',
      'answer': '',
      'category': 'Booking',
    },
    {
      'question': 'Can I reschedule a confirmed booking?',
      'answer': '',
      'category': 'Booking',
    },
    {
      'question': 'What payment options are available?',
      'answer': '',
      'category': 'Payment',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const AppTopBar(
              title: 'FAQS',
              subtitle: '19 questions answered',
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildSearchBar(),
                    ),
                    const SizedBox(height: 16),
                    _buildCategoriesTab(),
                    const SizedBox(height: 16),
                    _buildFaqList(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.dropDownBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/images/search.svg',
            width: 16,
            height: 16,
            colorFilter: const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
          ),
          const SizedBox(width: 12),
          const Text(
            'Search frequently asked questions...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontFamily: AppTextStyles.fontFamily,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.inputBorder),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _categories.asMap().entries.map((entry) {
            final index = entry.key;
            final isSelected = index == _selectedCategoryIndex;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategoryIndex = index),
              child: Container(
                padding: const EdgeInsets.only(bottom: 8, right: 24),
                decoration: isSelected
                    ? const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.onLight, width: 2),
                        ),
                      )
                    : null,
                child: Text(
                  entry.value,
                  style: TextStyle(
                    color: isSelected ? AppColors.onLight : AppColors.textSecondary,
                    fontSize: 14,
                    fontFamily: AppTextStyles.fontFamily,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFaqList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _faqs.asMap().entries.map((entry) {
          final index = entry.key;
          final isExpanded = index == _expandedFaqIndex;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildFaqItem(entry.value, isExpanded, index),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFaqItem(Map<String, String> item, bool isExpanded, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expandedFaqIndex = isExpanded ? null : index),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: isExpanded ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 21.99,
                    height: 21.99,
                    decoration: ShapeDecoration(
                      color: isExpanded ? const Color(0xFF0A0A0A) : const Color(0xFFF7F7F7),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1.08,
                          color: isExpanded ? const Color(0xFF0A0A0A) : const Color(0xFFE5E7EB),
                        ),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Q',
                      style: TextStyle(
                        color: isExpanded ? Colors.white : const Color(0xFF6B7280),
                        fontSize: 10,
                        fontFamily: AppTextStyles.fontFamilyPoppins,
                        fontWeight: FontWeight.w900,
                        height: 1.50,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['question']!,
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 14,
                            fontFamily: AppTextStyles.fontFamilyPoppins,
                            fontWeight: isExpanded ? FontWeight.w700 : FontWeight.w600,
                            height: 1.40,
                          ),
                        ),
                        if (!isExpanded) ...[
                          const SizedBox(height: 4),
                          Text(
                            item['category']!,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontFamily: AppTextStyles.fontFamilyPoppins,
                              fontWeight: FontWeight.w500,
                              height: 1.50,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!isExpanded)
                    SvgPicture.asset(
                      'assets/images/CaretDown.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
                    ),
                ],
              ),
            ),
          ),
          if (isExpanded && item['answer']!.isNotEmpty) ...[
            const Divider(height: 1, color: AppColors.inputBorder),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 21.99,
                        height: 21.99,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFEFF6FF),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 1.08,
                              color: Color(0xFFBFDBFE),
                            ),
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'A',
                          style: TextStyle(
                            color: const Color(0xFF1E40AF),
                            fontSize: 10,
                            fontFamily: AppTextStyles.fontFamilyPoppins,
                            fontWeight: FontWeight.w900,
                            height: 1.50,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item['answer']!,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontFamily: AppTextStyles.fontFamilyPoppins,
                            fontWeight: FontWeight.w400,
                            height: 1.70,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildFeedbackButton('assets/images/ThumbsUp.svg', 'Helpful', color: AppColors.textDark),
                      const SizedBox(width: 8),
                      _buildFeedbackButton('assets/images/ThumbsDown.svg', 'Not helpful', color: AppColors.error),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeedbackButton(String svgPath, String label, {required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bg,
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(svgPath, width: 14, height: 14, colorFilter: ColorFilter.mode(color, BlendMode.srcIn)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontFamily: AppTextStyles.fontFamilyPoppins,
              fontWeight: FontWeight.w500,
              height: 1.50,
            ),
          ),
        ],
      ),
    );
  }
}
