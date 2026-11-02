import 'package:digv/I10n/app_localizations.dart';
import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/core/widgets/app_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/faq_provider.dart';

class HelpCenterScreen extends ConsumerStatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  ConsumerState<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends ConsumerState<HelpCenterScreen> {
  final Map<String, bool?> _userVotes = {};
  final Set<String> _submittingFaqIds = {};
  bool _isBookingExpanded = true;
  int? _expandedArticle = 0;

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Booking & Scheduling',
      'count': '4 articles',
      'color': AppColors.unread,
      'icon': 'assets/images/CalendarBlank.svg',
      'iconColor': AppColors.blueLight,
    },
    {
      'title': 'Payments & Refunds',
      'count': '3 articles',
      'color': const Color(0xFFEDE9FE),
      'icon': 'assets/images/credit-card.svg',
      'iconColor': const Color(0xFF8B5CF6),
    },
    {
      'title': 'Service & Technicians',
      'count': '3 articles',
      'color': AppColors.warningBg,
      'icon': 'assets/images/flash.svg',
      'iconColor': AppColors.warningText,
    },
    {
      'title': 'Account & Profile',
      'count': '3 articles',
      'color': AppColors.successSecondaryBg,
      'icon': 'assets/images/person.svg',
      'iconColor': AppColors.success,
    },
    {
      'title': 'Referral & Rewards',
      'count': '2 articles',
      'color': AppColors.errorBg,
      'icon': 'assets/images/star_edge.svg',
      'iconColor': AppColors.error,
    },
  ];

  // Articles are now loaded from l10n in _buildExpandableCategory
  final List<Map<String, dynamic>> _popularTopics = [
    {'icon': 'assets/images/CalendarBlack.svg', 'label': 'How to book\na service'},
    {'icon': 'assets/images/CreditCardBlack.svg', 'label': 'Payment issues'},
    {'icon': 'assets/images/ClockRed.svg', 'label': 'Reschedule\nbooking'},
    {'icon': 'assets/images/XCircle.svg', 'label': 'Cancel booking'},
    {'icon': 'assets/images/star.svg', 'label': 'Rate a technician'},
    {'icon': 'assets/images/HouseLine.svg', 'label': 'Change address'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(title: AppLocalizations.of(context)!.helpCenter),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 20),
                    _buildPopularTopics(),
                    const SizedBox(height: 20),
                    _buildCategoryList(),
                    const SizedBox(height: 20),
                    _buildStillNeedHelp(),
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

  void _onTopicTap(int index) {
    switch (index) {
      case 0:
        context.push('/faqs?category=BOOKING&query=book');
        break;
      case 1:
        context.push('/faqs?category=PAYMENT&query=payment');
        break;
      case 2:
        context.push('/faqs?query=reschedule');
        break;
      case 3:
        context.push('/faqs?query=cancel');
        break;
      case 4:
        context.push('/faqs?query=rate');
        break;
      case 5:
        context.push('/faqs?query=address');
        break;
      default:
        context.push('/faqs');
        break;
    }
  }

  void _onCategoryTap(int index) {
    switch (index) {
      case 0:
        setState(() => _isBookingExpanded = !_isBookingExpanded);
        break;
      case 1:
        context.push('/faqs?category=PAYMENT');
        break;
      case 2:
        context.push('/faqs?category=SERVICE');
        break;
      case 3:
        context.push('/faqs?category=ACCOUNT');
        break;
      case 4:
        context.push('/faqs?category=GENERAL');
        break;
      default:
        context.push('/faqs');
        break;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildSearchBar() {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: () => context.push('/faqs'),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                child: Text(
                  AppLocalizations.of(context)!.search_help_articles,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 14,
                    fontFamily: AppTextStyles.fontFamily,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularTopics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.popular_topics,
          style: AppTextStyles.bodyMediumBold.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 13,
            fontFamily: AppTextStyles.fontFamilyPoppins,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.0,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _popularTopics.length,
          itemBuilder: (context, index) {
            return _buildTopicCard(_popularTopics[index], index);
          },
        ),
      ],
    );
  }

  String _getTopicLabel(int index, String fallback, AppLocalizations l10n) {
    switch (index) {
      case 0:
        return l10n.popular_how_to_book;
      case 1:
        return l10n.popular_payment_issues;
      case 2:
        return l10n.popular_reschedule;
      case 3:
        return l10n.popular_cancel;
      case 4:
        return l10n.popular_rate;
      case 5:
        return l10n.popular_change_address;
      default:
        return fallback;
    }
  }

  String _getCategoryTitle(int index, String fallback, AppLocalizations l10n) {
    switch (index) {
      case 0:
        return l10n.booking_scheduling;
      case 1:
        return l10n.payments_refunds;
      case 2:
        return l10n.service_technicians;
      case 3:
        return l10n.account_profile;
      case 4:
        return l10n.referral_rewards;
      default:
        return fallback;
    }
  }

  Widget _buildTopicCard(Map<String, dynamic> topic, int index) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.inputBgSecondaryDark : AppColors.inputBgSecondary,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => _onTopicTap(index),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: SvgPicture.asset(
                    topic['icon'] as String,
                    width: 18,
                    height: 18,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getTopicLabel(index, topic['label'] as String, l10n),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 11,
                    fontFamily: AppTextStyles.fontFamily,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return Column(
      children: [
        _buildExpandableCategory(),
        const SizedBox(height: 10),
        ..._categories.asMap().entries.skip(1).map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildCollapsedCategory(entry.value, entry.key),
            )),
      ],
    );
  }

  Widget _buildExpandableCategory() {
    final l10n = AppLocalizations.of(context)!;
    final cat = _categories[0];
    final title = _getCategoryTitle(0, cat['title'] as String, l10n);
    final count = '4 ${l10n.articles_count}';

    // Build articles from l10n
    final articles = [
      {'id': '67962f5a-22f4-4ce5-96f5-f7df6bcd213e', 'question': l10n.hc_q1, 'answer': l10n.hc_a1},
      {'id': '67962f5a-22f4-4ce5-96f5-f7df6bcd213f', 'question': l10n.hc_q2, 'answer': l10n.hc_a2},
      {'id': '67962f5a-22f4-4ce5-96f5-f7df6bcd2140', 'question': l10n.hc_q3, 'answer': l10n.hc_a3},
      {'id': '67962f5a-22f4-4ce5-96f5-f7df6bcd2141', 'question': l10n.hc_q4, 'answer': l10n.hc_a4},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _isBookingExpanded = !_isBookingExpanded),
            child: Container(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cat['color'] as Color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        cat['icon'] as String,
                        width: 19,
                        height: 19,
                        colorFilter: ColorFilter.mode(cat['iconColor'] as Color, BlendMode.srcIn),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.bodyMediumBold.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                            fontFamily: AppTextStyles.fontFamilyPoppins,
                          ),
                        ),
                        Text(
                          count,
                          style: AppTextStyles.caption.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                            fontFamily: AppTextStyles.fontFamilyPoppins,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SvgPicture.asset(
                    _isBookingExpanded ? 'assets/images/caret-up.svg' : 'assets/images/CaretDown.svg',
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
                  ),
                ],
              ),
            ),
          ),
          if (_isBookingExpanded) ...[
            ...articles.asMap().entries.map((entry) {
              final i = entry.key;
              final article = entry.value;
              final isExpanded = _expandedArticle == i;
              final faqId = article['id'] ?? '';
              final voteKey = faqId.isNotEmpty ? faqId : (article['question'] ?? '$i');
              final currentVote = _userVotes[voteKey];
              return Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _expandedArticle = isExpanded ? null : i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                article['question'] ?? '',
                                style: AppTextStyles.caption.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: AppTextStyles.fontFamilyPoppins,
                                ),
                              ),
                            ),
                            SvgPicture.asset(
                              isExpanded ? 'assets/images/caret-up.svg' : 'assets/images/CaretDown.svg',
                              width: 16,
                              height: 16,
                              colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((article['answer'] ?? '').isNotEmpty)
                              Text(
                                article['answer']!,
                                style: AppTextStyles.caption.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                  height: 1.5,
                                  fontFamily: AppTextStyles.fontFamilyPoppins,
                                ),
                              ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildFeedbackButton(
                                  'assets/images/ThumbsUp.svg',
                                  l10n.helpful,
                                  defaultColor: AppColors.textSecondary,
                                  isSelected: currentVote == true,
                                  isPositive: true,
                                  onTap: () => _handleFeedback(
                                    articleKey: voteKey,
                                    faqId: faqId,
                                    isHelpful: true,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildFeedbackButton(
                                  'assets/images/ThumbsDown.svg',
                                  l10n.not_helpful,
                                  defaultColor: AppColors.error,
                                  isSelected: currentVote == false,
                                  isPositive: false,
                                  onTap: () => _handleFeedback(
                                    articleKey: voteKey,
                                    faqId: faqId,
                                    isHelpful: false,
                                  ),
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
            }),
          ],
        ],
      ),
    );
  }

  Future<void> _handleFeedback({
    required String articleKey,
    required String faqId,
    required bool isHelpful,
  }) async {
    if (_submittingFaqIds.contains(articleKey)) return;

    final currentVote = _userVotes[articleKey];
    final bool? newVote = (currentVote == isHelpful) ? null : isHelpful;

    setState(() {
      _userVotes[articleKey] = newVote;
    });

    if (newVote == null) return;

    setState(() {
      _submittingFaqIds.add(articleKey);
    });

    try {
      if (faqId.isNotEmpty) {
        await ref.read(faqProvider.notifier).submitFeedback(
          faqId: faqId,
          isHelpful: newVote,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your feedback!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your feedback!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _submittingFaqIds.remove(articleKey);
        });
      }
    }
  }

  Widget _buildFeedbackButton(
    String svgPath,
    String label, {
    required Color defaultColor,
    required bool isSelected,
    required VoidCallback onTap,
    bool isPositive = true,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color bgColor;
    final Color borderColor;
    final Color contentColor;

    if (isSelected) {
      if (isPositive) {
        bgColor = isDark ? const Color(0xFF1E3A5F) : AppColors.unread;
        borderColor = AppColors.blueLight;
        contentColor = isDark ? AppColors.blueLight : AppColors.blueDeep;
      } else {
        bgColor = isDark ? const Color(0xFF3F1D1D) : AppColors.dangerBg;
        borderColor = AppColors.dangerBorder;
        contentColor = isDark ? const Color(0xFFF87171) : AppColors.dangerText;
      }
    } else {
      bgColor = isDark ? const Color(0xFF1E1E1E) : AppColors.bg;
      borderColor = theme.dividerColor;
      contentColor = defaultColor;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: borderColor,
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
              colorFilter: ColorFilter.mode(contentColor, BlendMode.srcIn),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? contentColor : theme.colorScheme.secondary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontFamily: AppTextStyles.fontFamilyPoppins,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsedCategory(Map<String, dynamic> cat, int index) {
    final l10n = AppLocalizations.of(context)!;
    final title = _getCategoryTitle(index, cat['title'] as String, l10n);
    final countNum = cat['count'].toString().split(' ').first;
    final count = '$countNum ${l10n.articles_count}';

    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => _onCategoryTap(index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cat['color'] as Color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    cat['icon'] as String,
                    width: 19,
                    height: 19,
                    colorFilter: ColorFilter.mode(cat['iconColor'] as Color, BlendMode.srcIn),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMediumBold.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                        fontFamily: AppTextStyles.fontFamilyPoppins,
                      ),
                    ),
                    Text(
                      count,
                      style: AppTextStyles.caption.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                        fontFamily: AppTextStyles.fontFamilyPoppins,
                      ),
                    ),
                  ],
                ),
              ),
              SvgPicture.asset(
                'assets/images/arrow-right.svg',
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStillNeedHelp() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.still_need_help,
                  style: AppTextStyles.bodyMediumBold.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    fontFamily: AppTextStyles.fontFamilyPoppins,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.support_available_247,
                  style: AppTextStyles.caption.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontFamily: AppTextStyles.fontFamilyPoppins,
                  ),
                ),
              ],
            ),
          ),
          _buildContactRow(
            bgColor: AppColors.unread,
            svgPath: 'assets/images/message.svg',
            iconColor: AppColors.blueLight,
            title: l10n.live_chat,
            subtitle: l10n.avg_response,
            onTap: () => context.push('/contact_support'),
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _buildContactRow(
            bgColor: AppColors.successSecondaryBg,
            svgPath: 'assets/images/phone.svg',
            iconColor: AppColors.success,
            title: l10n.call_us,
            subtitle: '1800-XXX-XXXX · Free',
            onTap: () => _makePhoneCall('18001234567'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow({
    required Color bgColor,
    required String svgPath,
    required Color iconColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    svgPath,
                    width: 18,
                    height: 18,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMediumBold.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                        fontFamily: AppTextStyles.fontFamilyPoppins,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 11,
                        fontFamily: AppTextStyles.fontFamilyPoppins,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SvgPicture.asset(
                'assets/images/arrow-up-right.svg',
                width: 14,
                height: 14,
                colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), BlendMode.srcIn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
