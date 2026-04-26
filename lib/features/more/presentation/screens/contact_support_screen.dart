import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/core/widgets/app_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  int _selectedTabIndex = 0; // 0 = Contact Channels, 1 = Send Message
  String? _selectedSubject;
  final TextEditingController _orderIdController = TextEditingController();

  final List<String> _subjects = [
    'Booking Issue',
    'Payment Problem',
    'Refund Request',
    'Service Complaint',
    'Technician Feedback',
    'Account Issue',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const AppTopBar(
              title: 'Contact Support',
              subtitle: "We're here to help 24/7",
            ),
            _buildTabBar(),
            Expanded(
              child: _selectedTabIndex == 0
                  ? _buildContactChannelsTab()
                  : _buildSendMessageTab(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _selectedTabIndex == 1
          ? _buildBottomButton()
          : null,
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 44),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.inputBorder)),
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.onLight,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/send.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            Text(
              'Send Message',
              style: TextStyle(
                fontSize: 16,
                fontFamily: AppTextStyles.fontFamily,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.inputBorder),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _selectedTabIndex == 0 ? AppColors.onLight : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/phone.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        _selectedTabIndex == 0 ? AppColors.onLight : AppColors.textSecondary,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Contact Channels',
                      style: TextStyle(
                        color: _selectedTabIndex == 0 ? AppColors.onLight : AppColors.textSecondary,
                        fontSize: 16,
                        fontFamily: AppTextStyles.fontFamily,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _selectedTabIndex == 1 ? AppColors.onLight : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/message.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        _selectedTabIndex == 1 ? AppColors.onLight : AppColors.textSecondary,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Send Message',
                      style: TextStyle(
                        color: _selectedTabIndex == 1 ? AppColors.onLight : AppColors.textSecondary,
                        fontSize: 16,
                        fontFamily: AppTextStyles.fontFamily,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactChannelsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR RECENT TICKET',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontFamily: AppTextStyles.fontFamilyPoppins,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.60,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.inputBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Refund not received',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 13,
                          fontFamily: AppTextStyles.fontFamilyPoppins,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ticket #TKT-4821 · Feb 20, 2026',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontFamily: AppTextStyles.fontFamilyPoppins,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.warningBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'In Progress',
                    style: TextStyle(
                      color: AppColors.warningText,
                      fontSize: 11,
                      fontFamily: AppTextStyles.fontFamilyPoppins,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'CHOOSE A CHANNEL',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontFamily: AppTextStyles.fontFamilyPoppins,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.60,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.inputBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildChannelItem(
                  svgPath: 'assets/images/message.svg',
                  iconColor: AppColors.blueLight,
                  iconBgColor: AppColors.unread,
                  title: 'Live Chat',
                  subtitle: 'Avg. reply in 2 minutes',
                  badgeText: 'Fastest',
                  badgeColorText: AppColors.successText,
                  badgeBgColor: AppColors.successSecondaryBg,
                  isOnline: true,
                ),
                const Divider(height: 1, color: AppColors.inputBgSecondary),
                _buildChannelItem(
                  svgPath: 'assets/images/message.svg',
                  iconColor: AppColors.successText,
                  iconBgColor: AppColors.successSecondaryBg,
                  title: 'WhatsApp Support',
                  subtitle: 'Chat on WhatsApp',
                  badgeText: 'Popular',
                  badgeColorText: AppColors.successText,
                  badgeBgColor: AppColors.successSecondaryBg,
                  isOnline: true,
                ),
                const Divider(height: 1, color: AppColors.inputBgSecondary),
                _buildChannelItem(
                  svgPath: 'assets/images/phone.svg',
                  iconColor: AppColors.warningText,
                  iconBgColor: AppColors.warningBg,
                  title: 'Call Support',
                  subtitle: '1800-XXX-XXXX · Free · 24/7',
                  isOnline: true,
                ),
                const Divider(height: 1, color: AppColors.inputBgSecondary),
                _buildChannelItem(
                  svgPath: 'assets/images/message.svg',
                  iconColor: const Color(0xFF7C3AED),
                  iconBgColor: const Color(0xFFEDE9FE),
                  title: 'Email Support',
                  subtitle: 'support@homeserv.app',
                  badgeText: '< 4 hrs',
                  badgeColorText: const Color(0xFF7C3AED),
                  badgeBgColor: const Color(0xFFEDE9FE),
                  isOnline: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSupportHours(),
        ],
      ),
    );
  }

  Widget _buildChannelItem({
    required String svgPath,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    String? badgeText,
    Color? badgeColorText,
    Color? badgeBgColor,
    bool isOnline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(
              child: SvgPicture.asset(
                svgPath,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14,
                        fontFamily: AppTextStyles.fontFamilyPoppins,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (badgeText != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeBgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            color: badgeColorText,
                            fontSize: 10,
                            fontFamily: AppTextStyles.fontFamilyPoppins,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontFamily: AppTextStyles.fontFamilyPoppins,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (isOnline)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.successText,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSupportHours() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/images/clock.svg',
                width: 14,
                height: 14,
                colorFilter: const ColorFilter.mode(AppColors.textDark, BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
              Text(
                'Support Hours',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  fontFamily: AppTextStyles.fontFamilyPoppins,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSupportHourRow('Live Chat & WhatsApp', '24 × 7'),
          const SizedBox(height: 8),
          _buildSupportHourRow('Phone Support', '7 AM – 10 PM'),
          const SizedBox(height: 8),
          _buildSupportHourRow('Email Support', '24 × 7 (reply in 4h)'),
        ],
      ),
    );
  }

  Widget _buildSupportHourRow(String label, String value, {FontWeight valueWeight = FontWeight.w700}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontFamily: AppTextStyles.fontFamilyPoppins,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 13,
            fontFamily: AppTextStyles.fontFamilyPoppins,
            fontWeight: valueWeight,
          ),
        ),
      ],
    );
  }

  Widget _buildSendMessageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.inputBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR DETAILS',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontFamily: AppTextStyles.fontFamilyPoppins,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.60,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSupportHourRow('Name', 'Rahul Das', valueWeight: FontWeight.w600),
                const SizedBox(height: 8),
                _buildSupportHourRow('Phone', '+880 1711 234567', valueWeight: FontWeight.w600),
                const SizedBox(height: 8),
                _buildSupportHourRow('Email', 'rahul@example.com', valueWeight: FontWeight.w600),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildFormSection(
            title: 'SUBJECT ',
            isRequired: true,
            child: _buildSubjectDropdown(),
          ),
          const SizedBox(height: 16),
          _buildFormSection(
            title: 'RELATED ORDER ID (OPTIONAL)',
            child: _buildOrderIdField(),
          ),
          const SizedBox(height: 16),
          _buildFormSection(
            title: 'YOUR MESSAGE ',
            isRequired: true,
            trailingWidget: const Text(
              '0/500',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 11,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
            child: _buildInputContainer(
              text: 'Describe your issue in detail. The more info you give, the faster we can help... (min 20 characters)',
              height: 132,
              alignment: Alignment.topLeft,
            ),
          ),
          const SizedBox(height: 16),
          _buildFormSection(
            title: 'ATTACHMENT (OPTIONAL)',
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.inputBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/attachment.svg',
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Attach screenshot or photo',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontFamily: AppTextStyles.fontFamilyPoppins,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSupportHours(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFormSection({
    required String title,
    bool isRequired = false,
    Widget? trailingWidget,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: title,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontFamily: AppTextStyles.fontFamilyPoppins,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.60,
                    ),
                  ),
                  if (isRequired)
                    TextSpan(
                      text: '*',
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 11,
                        fontFamily: AppTextStyles.fontFamilyPoppins,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.60,
                      ),
                    ),
                ],
              ),
            ),
            if (trailingWidget != null) trailingWidget,
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildSubjectDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedSubject,
        hint: Text(
          'Select a subject...',
          style: TextStyle(
            color: AppColors.textDark.withOpacity(0.5),
            fontSize: 14,
            fontFamily: AppTextStyles.fontFamilyPoppins,
            fontWeight: FontWeight.w400,
          ),
        ),
        icon: SvgPicture.asset(
          'assets/images/CaretDown.svg',
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
        ),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
        dropdownColor: Colors.white,
        style: TextStyle(
          color: AppColors.textDark,
          fontSize: 14,
          fontFamily: AppTextStyles.fontFamilyPoppins,
          fontWeight: FontWeight.w400,
        ),
        items: _subjects.map((subject) {
          return DropdownMenuItem<String>(
            value: subject,
            child: Text(subject),
          );
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedSubject = value);
        },
      ),
    );
  }

  Widget _buildOrderIdField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: _orderIdController,
        style: TextStyle(
          color: AppColors.textDark,
          fontSize: 14,
          fontFamily: AppTextStyles.fontFamilyPoppins,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          hintText: 'e.g. ORD-7845',
          hintStyle: TextStyle(
            color: AppColors.textDark.withOpacity(0.5),
            fontSize: 14,
            fontFamily: AppTextStyles.fontFamilyPoppins,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildInputContainer({
    required String text,
    double? height,
    Alignment alignment = Alignment.centerLeft,
  }) {
    return Container(
      constraints: height != null ? BoxConstraints(minHeight: height) : const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: alignment,
      child: Opacity(
        opacity: 0.5,
        child: Text(
          text,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 14,
            fontFamily: AppTextStyles.fontFamilyPoppins,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
