import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/core/widgets/app_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/entities/faq.dart';
import '../providers/faq_provider.dart';

class FaqsScreen extends ConsumerStatefulWidget {
  const FaqsScreen({super.key});

  @override
  ConsumerState<FaqsScreen> createState() => _FaqsScreenState();
}

class _FaqsScreenState extends ConsumerState<FaqsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategoryKey = 'ALL';
  int? _expandedFaqIndex;
  final Map<String, bool> _userVotes = {};
  final Set<String> _submittingFaqIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatCategoryName(String key) {
    if (key == 'ALL') return 'All';
    if (key.isEmpty) return '';
    return key[0].toUpperCase() + key.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final faqAsync = ref.watch(faqProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            faqAsync.when(
              data: (faqData) => AppTopBar(
                title: 'FAQS',
                subtitle: '${faqData.items.length} questions answered',
              ),
              loading: () => const AppTopBar(
                title: 'FAQS',
                subtitle: 'Loading questions...',
              ),
              error: (_, _) => const AppTopBar(
                title: 'FAQS',
                subtitle: 'Error loading FAQs',
              ),
            ),
            Expanded(
              child: faqAsync.when(
                data: (faqData) {
                  // Filter items locally by search query and tab selection
                  final filteredFaqs = faqData.items.where((item) {
                    // Category filter
                    if (_selectedCategoryKey != 'ALL') {
                      if (item.type.toUpperCase() != _selectedCategoryKey.toUpperCase()) {
                        return false;
                      }
                    }
                    // Search filter
                    final query = _searchController.text.trim().toLowerCase();
                    if (query.isNotEmpty) {
                      final questionMatch = item.question.toLowerCase().contains(query);
                      final answerMatch = item.answer.toLowerCase().contains(query);
                      if (!questionMatch && !answerMatch) {
                        return false;
                      }
                    }
                    return true;
                  }).toList();

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildSearchBar(),
                        ),
                        const SizedBox(height: 16),
                        _buildCategoriesTab(faqData.tabs),
                        const SizedBox(height: 16),
                        _buildFaqList(filteredFaqs),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.error,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load FAQs: $err',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                            fontFamily: AppTextStyles.fontFamily,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.invalidate(faqProvider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleFeedback(String faqId, bool isHelpful) async {
    if (_submittingFaqIds.contains(faqId)) return;

    if (_userVotes.containsKey(faqId)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You have already submitted feedback for this question.'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _submittingFaqIds.add(faqId);
    });

    try {
      await ref.read(faqProvider.notifier).submitFeedback(faqId: faqId, isHelpful: isHelpful);
      if (mounted) {
        setState(() {
          _userVotes[faqId] = isHelpful;
        });
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isHelpful ? 'Thank you for your helpful feedback!' : 'Feedback submitted successfully.'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit feedback: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _submittingFaqIds.remove(faqId);
        });
      }
    }
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/images/search.svg',
            width: 16,
            height: 16,
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() {
                _expandedFaqIndex = null; // Collapse active item on search changes
              }),
              decoration: InputDecoration(
                hintText: 'Search frequently asked questions...',
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 14,
                  fontFamily: AppTextStyles.fontFamily,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
                fontFamily: AppTextStyles.fontFamily,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(Map<String, int> tabs) {
    final keys = tabs.keys.toList();
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
          children: keys.asMap().entries.map((entry) {
            final key = entry.value;
            final isSelected = key == _selectedCategoryKey;
            final label = '${_formatCategoryName(key)} (${tabs[key] ?? 0})';
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategoryKey = key;
                  _expandedFaqIndex = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.only(bottom: 8, right: 24),
                decoration: isSelected
                    ? BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                        ),
                      )
                    : null,
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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

  Widget _buildFaqList(List<FaqItem> items) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 12),
              Text(
                'No FAQs found matching your filters.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 14,
                  fontFamily: AppTextStyles.fontFamily,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: items.asMap().entries.map((entry) {
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

  Widget _buildFaqItem(FaqItem item, bool isExpanded, int index) {
    final userVote = _userVotes[item.faqId];
    final isSubmitting = _submittingFaqIds.contains(item.faqId);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor),
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
                          item.question,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                            fontFamily: AppTextStyles.fontFamilyPoppins,
                            fontWeight: isExpanded ? FontWeight.w700 : FontWeight.w600,
                            height: 1.40,
                          ),
                        ),
                        if (!isExpanded) ...[
                          const SizedBox(height: 4),
                          Text(
                            _formatCategoryName(item.type),
                            style: const TextStyle(
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
          if (isExpanded && item.answer.isNotEmpty) ...[
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
                        child: const Text(
                          'A',
                          style: TextStyle(
                            color: Color(0xFF1E40AF),
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
                          item.answer,
                          style: const TextStyle(
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
                      _buildFeedbackButton(
                        'assets/images/ThumbsUp.svg',
                        'Helpful (${item.helpfulCount})',
                        color: userVote == true ? AppColors.blueDeep : AppColors.textDark,
                        isSelected: userVote == true,
                        isDisabled: userVote != null || isSubmitting,
                        activeBgColor: AppColors.unread,
                        activeBorderColor: AppColors.inputBorderSecondary,
                        activeTextColor: AppColors.blueDeep,
                        onTap: isSubmitting ? null : () => _handleFeedback(item.faqId, true),
                      ),
                      const SizedBox(width: 8),
                      _buildFeedbackButton(
                        'assets/images/ThumbsDown.svg',
                        'Not helpful (${item.notHelpfulCount})',
                        color: userVote == false ? AppColors.dangerText : AppColors.error,
                        isSelected: userVote == false,
                        isDisabled: userVote != null || isSubmitting,
                        activeBgColor: AppColors.dangerBg,
                        activeBorderColor: AppColors.dangerBorder,
                        activeTextColor: AppColors.dangerText,
                        onTap: isSubmitting ? null : () => _handleFeedback(item.faqId, false),
                      ),
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

  Widget _buildFeedbackButton(
    String svgPath,
    String label, {
    required Color color,
    bool isSelected = false,
    bool isDisabled = false,
    Color activeBgColor = AppColors.unread,
    Color activeBorderColor = AppColors.inputBorderSecondary,
    Color activeTextColor = AppColors.blueDeep,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeBgColor : AppColors.bg,
          border: Border.all(
            color: isSelected ? activeBorderColor : AppColors.inputBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              svgPath,
              width: 14,
              height: 14,
              colorFilter: ColorFilter.mode(
                isSelected ? color : (isDisabled ? AppColors.textGray : color),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? activeTextColor
                    : (isDisabled ? AppColors.textGray : AppColors.textSecondary),
                fontSize: 11,
                fontFamily: AppTextStyles.fontFamilyPoppins,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                height: 1.50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
