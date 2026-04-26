import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/core/widgets/app_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
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

  final List<Map<String, String>> _articles = [
    {
      'question': 'How do I book a service?',
      'answer':
          'Open the HomeServ app, choose a service category (AC, Electrical, Plumbing etc.), select a technician, pick a time slot and confirm payment. Your booking will be confirmed instantly.',
    },
    {'question': 'Can I reschedule my booking?', 'answer': ''},
    {'question': 'What happens if I cancel?', 'answer': ''},
    {'question': 'How do I track my technician?', 'answer': ''},
  ];

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
            const AppTopBar(title: 'Help Center'),
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
            'Search help articles...',
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

  Widget _buildPopularTopics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Topics',
          style: AppTextStyles.bodyMediumBold.copyWith(
            color: AppColors.textDark,
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
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _popularTopics.length,
          itemBuilder: (context, index) {
            return _buildTopicCard(_popularTopics[index]);
          },
        ),
      ],
    );
  }

  Widget _buildTopicCard(Map<String, dynamic> topic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.inputBgSecondary,
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.inputBorder),
              borderRadius: BorderRadius.circular(50),
            ),
            child: SvgPicture.asset(
              topic['icon'] as String,
              width: 18,
              height: 18,
              colorFilter: const ColorFilter.mode(AppColors.textDark, BlendMode.srcIn),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: Text(
                topic['label'] as String,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textDark,
                  fontSize: 11,
                  fontFamily: AppTextStyles.fontFamily,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    return Column(
      children: [
        _buildExpandableCategory(),
        const SizedBox(height: 10),
        ..._categories.skip(1).map((cat) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildCollapsedCategory(cat),
            )),
      ],
    );
  }

  Widget _buildExpandableCategory() {
    final cat = _categories[0];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.inputBorder),
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
                          cat['title'] as String,
                          style: AppTextStyles.bodyMediumBold.copyWith(
                            color: AppColors.onLight,
                            fontSize: 14,
                            fontFamily: AppTextStyles.fontFamilyPoppins,
                          ),
                        ),
                        Text(
                          cat['count'] as String,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
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
                    colorFilter: const ColorFilter.mode(AppColors.onLight, BlendMode.srcIn),
                  ),
                ],
              ),
            ),
          ),
          if (_isBookingExpanded) ...[
            ..._articles.asMap().entries.map((entry) {
              final i = entry.key;
              final article = entry.value;
              final isExpanded = _expandedArticle == i;
              return Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.inputBorder)),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _expandedArticle = isExpanded ? null : i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/update.svg',
                              width: 14,
                              height: 14,
                              colorFilter: const ColorFilter.mode(AppColors.blueLight, BlendMode.srcIn),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                article['question']!,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.onLight,
                                  fontSize: 13,
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SvgPicture.asset(
                              isExpanded ? 'assets/images/caret-up.svg' : 'assets/images/CaretDown.svg',
                              width: 16,
                              height: 16,
                              colorFilter: const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded && article['answer']!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.only(left: 40, right: 16, bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article['answer']!,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontFamily: AppTextStyles.fontFamilyPoppins,
                                height: 1.7,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildFeedbackButton('assets/images/ThumbsUp.svg', 'Helpful', iconColor: AppColors.textDark),
                                const SizedBox(width: 8),
                                _buildFeedbackButton('assets/images/ThumbsDown.svg', 'Not helpful', iconColor: AppColors.error),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildFeedbackButton(String svgPath, String label, {required Color iconColor}) {
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
          SvgPicture.asset(svgPath, width: 14, height: 14, colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn)),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              fontFamily: AppTextStyles.fontFamilyPoppins,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedCategory(Map<String, dynamic> cat) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(8),
      ),
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
                    cat['title'] as String,
                    style: AppTextStyles.bodyMediumBold.copyWith(
                      color: AppColors.onLight,
                      fontSize: 14,
                      fontFamily: AppTextStyles.fontFamilyPoppins,
                    ),
                  ),
                  Text(
                    cat['count'] as String,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
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
              colorFilter: const ColorFilter.mode(AppColors.onLight, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStillNeedHelp() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.inputBorder)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Still need help?',
                  style: AppTextStyles.bodyMediumBold.copyWith(
                    color: AppColors.onLight,
                    fontSize: 14,
                    fontFamily: AppTextStyles.fontFamilyPoppins,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Our support team is available 24/7',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
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
            title: 'Live Chat',
            subtitle: 'Avg response: 2 min',
          ),
          const Divider(height: 1, color: AppColors.inputBgSecondary),
          _buildContactRow(
            bgColor: AppColors.successSecondaryBg,
            svgPath: 'assets/images/phone.svg',
            iconColor: AppColors.success,
            title: 'Call Us',
            subtitle: '1800-XXX-XXXX · Free',
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
  }) {
    return Container(
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
                    color: AppColors.onLight,
                    fontSize: 14,
                    fontFamily: AppTextStyles.fontFamilyPoppins,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
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
            colorFilter: const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }
}
