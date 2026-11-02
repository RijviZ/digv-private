import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../I10n/app_localizations.dart';
import '../../../../core/network/failure.dart';
import '../../../../core/network/file_upload_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/sources/support_ticket_remote_data_source.dart';

class ContactSupportScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;
  final String? initialSubject;

  const ContactSupportScreen({
    super.key,
    this.initialTabIndex = 0,
    this.initialSubject,
  });

  @override
  ConsumerState<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends ConsumerState<ContactSupportScreen> {
  late int _selectedTabIndex;
  String? _selectedSubject;
  final TextEditingController _orderIdController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  int _messageCharCount = 0;
  final ImagePicker _imagePicker = ImagePicker();
  File? _attachmentFile;

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
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
    if (widget.initialSubject != null && widget.initialSubject!.isNotEmpty) {
      _selectedSubject = widget.initialSubject;
    }
    _messageController.addListener(_onMessageChanged);
  }

  @override
  void dispose() {
    _messageController.removeListener(_onMessageChanged);
    _messageController.dispose();
    _orderIdController.dispose();
    super.dispose();
  }

  void _onMessageChanged() {
    setState(() {
      _messageCharCount = _messageController.text.length;
    });
  }

  bool _isFormValid() {
    return _selectedSubject != null && _messageController.text.trim().length >= 20;
  }

  String _formatTicketDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      final List<String> months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final monthName = months[dateTime.month - 1];
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$monthName ${dateTime.day}, ${dateTime.year} · $hour:$minute $period';
    } catch (_) {
      return '';
    }
  }

  Future<void> _pickAttachment(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (image != null) {
        setState(() {
          _attachmentFile = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF0A0A0A)),
                title: const Text(
                  'Take Photo',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickAttachment(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF0A0A0A)),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickAttachment(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessBottomSheet(String? ticketId) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bSheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.inputBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.dropDownBorder, width: 1),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Message Sent!',
                textAlign: TextAlign.center,
                style: AppTextStyles.h3.copyWith(
                  color: theme.colorScheme.onSurface,
                  height: 1.75,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'We have received your message and will get back to you shortly. You can track this in your tickets.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.50,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(bSheetContext);
                      if (ticketId != null && ticketId.isNotEmpty) {
                        context.push('/support_ticket_detail?ticketId=$ticketId');
                      } else {
                        setState(() {
                          _selectedTabIndex = 0;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text(
                      'View Support Tickets',
                      style: AppTextStyles.button.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 44),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitTicket() async {
    if (_selectedSubject == null || _selectedSubject!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a subject'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final messageText = _messageController.text.trim();
    if (messageText.length < 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message must be at least 20 characters long'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final parentContext = context;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      String? attachmentUrl;
      if (_attachmentFile != null) {
        final uploadService = ref.read(fileUploadServiceProvider);
        attachmentUrl = await uploadService.uploadFile(
          _attachmentFile!.path,
          category: 'message-files',
        );
      }

      final ticket = await ref.read(supportTicketRemoteDataSourceProvider).createTicket(
        subject: _selectedSubject!,
        referenceNumber: _orderIdController.text.trim(),
        message: messageText,
        attachmentUrl: attachmentUrl,
      );

      ref.invalidate(supportTicketsProvider);
      ref.invalidate(mySupportTicketsProvider);

      if (parentContext.mounted) {
        Navigator.pop(parentContext); // Close loading dialog
        _showSuccessBottomSheet(ticket.ticketId);

        // Reset form
        setState(() {
          _selectedSubject = null;
          _orderIdController.clear();
          _messageController.clear();
          _attachmentFile = null;
          _messageCharCount = 0;
        });
      }
    } catch (e) {
      if (parentContext.mounted) {
        Navigator.pop(parentContext); // Close loading dialog
        final msg = e is Failure ? e.message : e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(parentContext).showSnackBar(
          SnackBar(
            content: Text('Failed to submit ticket: $msg'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              title: l10n?.contact_support_title ?? 'Contact Support',
              subtitle: l10n?.support_subtitle ?? "We're here to help 24/7",
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
    final theme = Theme.of(context);
    final bool valid = _isFormValid();
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 44),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: ElevatedButton(
        onPressed: valid ? _submitTicket : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: valid ? theme.colorScheme.primary : theme.dividerColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: theme.dividerColor,
          disabledForegroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.38),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/send.svg',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                valid ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l10n?.send_message_btn ?? 'Send Message',
              style: AppTextStyles.button.copyWith(
                color: valid ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.38),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
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
                      color: _selectedTabIndex == 0 ? theme.colorScheme.primary : Colors.transparent,
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
                        _selectedTabIndex == 0
                            ? (isDark ? Colors.white : theme.colorScheme.primary)
                            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n?.contact_channels ?? 'Contact Channels',
                      style: AppTextStyles.button.copyWith(
                        color: _selectedTabIndex == 0
                            ? (isDark ? Colors.white : theme.colorScheme.primary)
                            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
                      color: _selectedTabIndex == 1 ? theme.colorScheme.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/email.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        _selectedTabIndex == 1
                            ? (isDark ? Colors.white : theme.colorScheme.primary)
                            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n?.send_message_btn ?? 'Send Message',
                      style: AppTextStyles.button.copyWith(
                        color: _selectedTabIndex == 1
                            ? (isDark ? Colors.white : theme.colorScheme.primary)
                            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
    final theme = Theme.of(context);
    final ticketsAsync = ref.watch(supportTicketsProvider);
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ticketsAsync.when(
            data: (tickets) {
              if (tickets.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.your_recent_ticket ?? 'YOUR RECENT TICKETS',
                    style: AppTextStyles.caption.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontFamily: AppTextStyles.fontFamilyPoppins,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.60,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...tickets.map((ticket) {
                    Color badgeBg;
                    Color badgeText;
                    switch (ticket.ticketStatus.toUpperCase()) {
                      case 'OPEN':
                        badgeBg = const Color(0xFFECFDF5);
                        badgeText = const Color(0xFF059669);
                        break;
                      case 'IN_PROGRESS':
                        badgeBg = AppColors.warningBg;
                        badgeText = AppColors.warningText;
                        break;
                      case 'RESOLVED':
                        badgeBg = const Color(0xFFEFF6FF);
                        badgeText = const Color(0xFF2563EB);
                        break;
                      default:
                        badgeBg = AppColors.inputBgSecondary;
                        badgeText = AppColors.textSecondary;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: InkWell(
                        onTap: () {
                          context.push('/support_ticket_detail?ticketId=${ticket.ticketId}');
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            border: Border.all(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ticket.subject,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: theme.colorScheme.onSurface,
                                        fontFamily: AppTextStyles.fontFamilyPoppins,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Ticket #${ticket.supportTicketNo} · ${_formatTicketDate(ticket.createdAt)}',
                                      style: AppTextStyles.caption.copyWith(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                        fontFamily: AppTextStyles.fontFamilyPoppins,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                                decoration: BoxDecoration(
                                  color: badgeBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  ticket.ticketStatus,
                                  style: AppTextStyles.caption.copyWith(
                                    color: badgeText,
                                    fontFamily: AppTextStyles.fontFamilyPoppins,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              SvgPicture.asset(
                                'assets/images/arrow-right.svg',
                                width: 14,
                                height: 14,
                                colorFilter: ColorFilter.mode(
                                  theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                  BlendMode.srcIn,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, stack) => const SizedBox.shrink(),
          ),
          Text(
            l10n?.choose_a_channel ?? 'CHOOSE A CHANNEL',
            style: AppTextStyles.caption.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontFamily: AppTextStyles.fontFamilyPoppins,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.60,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildChannelItem(
                  svgPath: 'assets/images/message.svg',
                  iconColor: AppColors.blueDeep,
                  iconBgColor: AppColors.unread,
                  title: l10n?.live_chat_title ?? 'Live Chat',
                  subtitle: 'Avg. reply in 2 minutes',
                  badgeText: 'Fastest',
                  badgeColorText: AppColors.success,
                  badgeBgColor: AppColors.successSecondaryBg,
                  isOnline: true,
                  onTap: () {
                    setState(() => _selectedTabIndex = 1);
                  },
                ),
                Divider(height: 1, color: theme.dividerColor),
                _buildChannelItem(
                  svgPath: 'assets/images/message.svg',
                  iconColor: AppColors.success,
                  iconBgColor: AppColors.successSecondaryBg,
                  title: l10n?.whatsapp_title ?? 'WhatsApp Support',
                  subtitle: 'Chat on WhatsApp',
                  badgeText: 'Popular',
                  badgeColorText: AppColors.success,
                  badgeBgColor: AppColors.successSecondaryBg,
                  isOnline: true,
                  onTap: () async {
                    final Uri launchUri = Uri.parse('https://wa.me/18005550199');
                    if (await canLaunchUrl(launchUri)) {
                      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not open WhatsApp')),
                        );
                      }
                    }
                  },
                ),
                Divider(height: 1, color: theme.dividerColor),
                _buildChannelItem(
                  svgPath: 'assets/images/phone.svg',
                  iconColor: AppColors.warningText,
                  iconBgColor: AppColors.warningBg,
                  title: l10n?.call_support_title ?? 'Call Support',
                  subtitle: '1800-XXX-XXXX · Free · 24/7',
                  isOnline: true,
                  onTap: () async {
                    final Uri launchUri = Uri(
                      scheme: 'tel',
                      path: '18005550199',
                    );
                    if (await canLaunchUrl(launchUri)) {
                      await launchUrl(launchUri);
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not place call to support')),
                        );
                      }
                    }
                  },
                ),
                Divider(height: 1, color: theme.dividerColor),
                _buildChannelItem(
                  svgPath: 'assets/images/email.svg',
                  iconColor: AppColors.purple,
                  iconBgColor: AppColors.purpleBg,
                  title: l10n?.email_support_title ?? 'Email Support',
                  subtitle: 'support@homeserv.app',
                  badgeText: '< 4 hrs',
                  badgeColorText: AppColors.purple,
                  badgeBgColor: AppColors.purpleBg,
                  isOnline: true,
                  onTap: () async {
                    final Uri launchUri = Uri(
                      scheme: 'mailto',
                      path: 'support@homeserv.app',
                    );
                    if (await canLaunchUrl(launchUri)) {
                      await launchUrl(launchUri);
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not launch email client')),
                        );
                      }
                    }
                  },
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
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
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
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: theme.colorScheme.onSurface,
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
                            style: AppTextStyles.captionSmall.copyWith(
                              color: badgeColorText,
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
                    style: AppTextStyles.caption.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportHours() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerColor),
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
                colorFilter: ColorFilter.mode(theme.colorScheme.onSurface, BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
              Text(
                l10n?.support_hours ?? 'Support Hours',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontFamily: AppTextStyles.fontFamilyPoppins,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSupportHourRow(
            'Live Chat & WhatsApp',
            '24 × 7',
          ),
          const SizedBox(height: 8),
          _buildSupportHourRow(
            'Phone Support',
            '7 AM – 10 PM',
          ),
          const SizedBox(height: 8),
          _buildSupportHourRow(
            'Email Support',
            '24 × 7 (reply in 4h)',
          ),
        ],
      ),
    );
  }

  Widget _buildSupportHourRow(String label, String value, {FontWeight valueWeight = FontWeight.w700}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.captionMedium.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontFamily: AppTextStyles.fontFamilyPoppins,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.captionMedium.copyWith(
            color: theme.colorScheme.onSurface,
            fontFamily: AppTextStyles.fontFamilyPoppins,
            fontWeight: valueWeight,
          ),
        ),
      ],
    );
  }

  Widget _buildSendMessageTab() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentUser = ref.watch(profileProvider).value;
    final name = currentUser?.fullName ?? 'N/A';
    final phone = currentUser?.phoneNumber != null && currentUser!.phoneNumber.isNotEmpty
        ? currentUser.phoneNumber
        : 'N/A';
    final email = currentUser?.email ?? 'N/A';
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.your_details ?? 'YOUR DETAILS',
                  style: AppTextStyles.caption.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontFamily: AppTextStyles.fontFamilyPoppins,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.60,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSupportHourRow('Name', name, valueWeight: FontWeight.w600),
                const SizedBox(height: 8),
                _buildSupportHourRow('Phone', phone, valueWeight: FontWeight.w600),
                const SizedBox(height: 8),
                _buildSupportHourRow('Email', email, valueWeight: FontWeight.w600),
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
            title: l10n?.related_order_id_optional ?? 'RELATED ORDER ID (OPTIONAL)',
            child: _buildOrderIdField(),
          ),
          const SizedBox(height: 16),
          _buildFormSection(
            title: 'YOUR MESSAGE ',
            isRequired: true,
            trailingWidget: Text(
              '$_messageCharCount/500 (min 20)',
              style: AppTextStyles.caption.copyWith(
                color: _messageCharCount > 0 && _messageCharCount < 20
                    ? Colors.red
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontFamily: AppTextStyles.fontFamilyPoppins,
                fontWeight:
                    _messageCharCount > 0 && _messageCharCount < 20 ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            child: _buildInputField(),
          ),
          const SizedBox(height: 16),
          _buildFormSection(
            title: l10n?.attachment_optional ?? 'ATTACHMENT (OPTIONAL)',
            child: _attachmentFile != null
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(
                            _attachmentFile!,
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _attachmentFile!.path.split('/').last,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.captionMedium.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontFamily: AppTextStyles.fontFamilyPoppins,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _attachmentFile = null;
                            });
                          },
                          child: const Icon(
                            Icons.cancel,
                            color: Colors.red,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  )
                : GestureDetector(
                    onTap: _showAttachmentOptions,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/images/attachment.svg',
                            width: 16,
                            height: 16,
                            colorFilter: ColorFilter.mode(
                              theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n?.attach_screenshot_photo ?? 'Attach screenshot or photo',
                            style: AppTextStyles.captionMedium.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              fontFamily: AppTextStyles.fontFamilyPoppins,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
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
    final theme = Theme.of(context);
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
                    style: AppTextStyles.caption.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontFamily: AppTextStyles.fontFamilyPoppins,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.60,
                    ),
                  ),
                  if (isRequired)
                    TextSpan(
                      text: '*',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.red.shade600,
                        fontFamily: AppTextStyles.fontFamilyPoppins,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.60,
                      ),
                    ),
                ],
              ),
            ),
            trailingWidget ?? const SizedBox.shrink(),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildSubjectDropdown() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedSubject,
        hint: Text(
          'Select a subject...',
          style: AppTextStyles.bodyMedium.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontFamily: AppTextStyles.fontFamilyPoppins,
            fontWeight: FontWeight.w400,
          ),
        ),
        icon: SvgPicture.asset(
          'assets/images/CaretDown.svg',
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(
            theme.colorScheme.onSurface.withValues(alpha: 0.6),
            BlendMode.srcIn,
          ),
        ),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
        dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        style: AppTextStyles.bodyMedium.copyWith(
          color: theme.colorScheme.onSurface,
          fontFamily: AppTextStyles.fontFamilyPoppins,
          fontWeight: FontWeight.w400,
        ),
        items: _subjects.map((subject) {
          return DropdownMenuItem<String>(
            value: subject,
            child: Text(
              subject,
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedSubject = value);
        },
      ),
    );
  }

  Widget _buildOrderIdField() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: _orderIdController,
        style: AppTextStyles.bodyMedium.copyWith(
          color: theme.colorScheme.onSurface,
          fontFamily: AppTextStyles.fontFamilyPoppins,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          hintText: 'e.g. ORD-7845',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontFamily: AppTextStyles.fontFamilyPoppins,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: _messageController,
        maxLines: 5,
        maxLength: 500,
        style: AppTextStyles.bodyMedium.copyWith(
          color: theme.colorScheme.onSurface,
          fontFamily: AppTextStyles.fontFamilyPoppins,
          fontWeight: FontWeight.w400,
        ),
        buildCounter: (
          BuildContext context, {
          required int currentLength,
          required bool isFocused,
          required int? maxLength,
        }) =>
            null,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
          hintText:
              'Describe your issue in detail. The more info you give, the faster we can help...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontFamily: AppTextStyles.fontFamilyPoppins,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
