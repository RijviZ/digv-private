import 'package:digv/I10n/app_localizations.dart';
import 'package:digv/core/network/file_upload_service.dart';
import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/core/widgets/app_top_bar.dart';
import 'package:digv/features/auth/presentation/providers/auth_provider.dart';
import 'package:digv/features/more/data/sources/support_ticket_remote_data_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class ContactSupportScreen extends ConsumerStatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  ConsumerState<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends ConsumerState<ContactSupportScreen> {
  int _selectedTabIndex = 0; // 0 = Contact Channels, 1 = Send Message
  String? _selectedSubject;
  final TextEditingController _orderIdController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String? _uploadedAttachmentUrl;
  bool _isUploadingAttachment = false;
  bool _isSubmittingTicket = false;

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
  void dispose() {
    _orderIdController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAttachment() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() {
      _isUploadingAttachment = true;
    });

    try {
      final uploadService = ref.read(fileUploadServiceProvider);
      final url = await uploadService.uploadFile(picked.path, category: 'SUPPORT_TICKET');
      setState(() {
        _uploadedAttachmentUrl = url;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attachment uploaded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingAttachment = false;
        });
      }
    }
  }

  Future<void> _submitSupportTicket() async {
    if (_selectedSubject == null || _selectedSubject!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subject')),
      );
      return;
    }

    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your message')),
      );
      return;
    }

    setState(() {
      _isSubmittingTicket = true;
    });

    try {
      final dataSource = ref.read(supportTicketRemoteDataSourceProvider);
      final ticket = await dataSource.createTicket(
        subject: _selectedSubject!,
        referenceNumber: _orderIdController.text.trim().isNotEmpty ? _orderIdController.text.trim() : null,
        message: messageText,
        attachmentUrl: _uploadedAttachmentUrl,
      );

      ref.invalidate(mySupportTicketsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ticket #${ticket.supportTicketNo} created successfully!')),
        );
        _messageController.clear();
        _orderIdController.clear();
        setState(() {
          _selectedSubject = null;
          _uploadedAttachmentUrl = null;
          _selectedTabIndex = 0; // Switch to Tickets list
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit ticket: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingTicket = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              title: l10n.contact_support_title,
              subtitle: l10n.support_subtitle,
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 44),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: ElevatedButton(
        onPressed: (_isSubmittingTicket || _isUploadingAttachment) ? null : _submitSupportTicket,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: _isSubmittingTicket
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Row(
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
                    l10n.send_message_btn,
                    style: const TextStyle(
                      color: Colors.white,
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
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
                      color: _selectedTabIndex == 0 ? Theme.of(context).colorScheme.primary : Colors.transparent,
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
                            ? (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Theme.of(context).colorScheme.primary)
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.contact_channels,
                      style: TextStyle(
                        color: _selectedTabIndex == 0
                            ? (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Theme.of(context).colorScheme.primary)
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 16,
                        fontFamily: AppTextStyles.fontFamily,
                        fontWeight: FontWeight.w600,
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
                      color: _selectedTabIndex == 1 ? Theme.of(context).colorScheme.primary : Colors.transparent,
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
                        _selectedTabIndex == 1
                            ? (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Theme.of(context).colorScheme.primary)
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.send_message_btn,
                      style: TextStyle(
                        color: _selectedTabIndex == 1
                            ? (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Theme.of(context).colorScheme.primary)
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 16,
                        fontFamily: AppTextStyles.fontFamily,
                        fontWeight: FontWeight.w600,
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
    final l10n = AppLocalizations.of(context)!;
    final myTicketsAsync = ref.watch(mySupportTicketsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.your_recent_ticket,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 11,
              fontFamily: AppTextStyles.fontFamilyPoppins,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.60,
            ),
          ),
          const SizedBox(height: 8),
          myTicketsAsync.when(
            data: (tickets) {
              if (tickets.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'No open support tickets',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 13,
                      fontFamily: AppTextStyles.fontFamilyPoppins,
                    ),
                  ),
                );
              }
              final ticket = tickets.first;
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(color: Theme.of(context).dividerColor),
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
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 13,
                              fontFamily: AppTextStyles.fontFamilyPoppins,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Ticket #${ticket.supportTicketNo} · ${ticket.createdAt.split("T").first}',
                            style: const TextStyle(
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
                        color: ticket.ticketStatus == 'RESOLVED'
                            ? Colors.green.withValues(alpha: 0.15)
                            : AppColors.warningBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ticket.ticketStatus,
                        style: TextStyle(
                          color: ticket.ticketStatus == 'RESOLVED'
                              ? Colors.green
                              : AppColors.warningText,
                          fontSize: 11,
                          fontFamily: AppTextStyles.fontFamilyPoppins,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Error loading tickets: $err'),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.choose_a_channel,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 11,
              fontFamily: AppTextStyles.fontFamilyPoppins,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.60,
            ),
          ),
          const SizedBox(height: 12),
          _buildChannelItem(
            icon: 'assets/images/message.svg',
            title: l10n.live_chat_title,
            subtitle: l10n.live_chat_desc,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildChannelItem(
            icon: 'assets/images/whatsapp.svg',
            title: l10n.whatsapp_title,
            subtitle: l10n.whatsapp_desc,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildChannelItem(
            icon: 'assets/images/phone.svg',
            title: l10n.call_support_title,
            subtitle: l10n.call_support_desc,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildChannelItem(
            icon: 'assets/images/mail.svg',
            title: l10n.email_support_title,
            subtitle: l10n.email_support_desc,
            onTap: () {},
          ),
          const SizedBox(height: 24),
          _buildSupportHours(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildChannelItem({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                icon,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primary,
                  BlendMode.srcIn,
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
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                      fontFamily: AppTextStyles.fontFamilyPoppins,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 11,
                      fontFamily: AppTextStyles.fontFamilyPoppins,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              'assets/images/CaretRight.svg',
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportHours() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/images/clock.svg',
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.support_hours,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
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
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 13,
            fontFamily: AppTextStyles.fontFamilyPoppins,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 13,
            fontFamily: AppTextStyles.fontFamilyPoppins,
            fontWeight: valueWeight,
          ),
        ),
      ],
    );
  }

  Widget _buildSendMessageTab() {
    final l10n = AppLocalizations.of(context)!;
    final currentUser = ref.watch(profileProvider).value;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.your_details,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontFamily: AppTextStyles.fontFamilyPoppins,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.60,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSupportHourRow('Name', currentUser?.fullName ?? 'User', valueWeight: FontWeight.w600),
                const SizedBox(height: 8),
                _buildSupportHourRow('Phone', currentUser?.phoneNumber ?? '', valueWeight: FontWeight.w600),
                const SizedBox(height: 8),
                _buildSupportHourRow('Email', currentUser?.email ?? '', valueWeight: FontWeight.w600),
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
            title: l10n.related_order_id_optional,
            child: _buildOrderIdField(),
          ),
          const SizedBox(height: 16),
          _buildFormSection(
            title: 'YOUR MESSAGE ',
            isRequired: true,
            trailingWidget: Text(
              '${_messageController.text.length}/500',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 11,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
            child: _buildMessageField(),
          ),
          const SizedBox(height: 16),
          _buildFormSection(
            title: l10n.attachment_optional,
            child: GestureDetector(
              onTap: _isUploadingAttachment ? null : _pickAndUploadAttachment,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isUploadingAttachment) ...[
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      const Text('Uploading...'),
                    ] else ...[
                      SvgPicture.asset(
                        'assets/images/attachment.svg',
                        width: 16,
                        height: 16,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _uploadedAttachmentUrl != null
                            ? 'Attachment Added ✓'
                            : l10n.attach_screenshot_photo,
                        style: TextStyle(
                          color: _uploadedAttachmentUrl != null
                              ? Colors.green
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 14,
                          fontFamily: AppTextStyles.fontFamily,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
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

  Widget _buildMessageField() {
    return Container(
      constraints: const BoxConstraints(minHeight: 132),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: _messageController,
        maxLines: 5,
        maxLength: 500,
        onChanged: (_) => setState(() {}),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 14,
          fontFamily: AppTextStyles.fontFamilyPoppins,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          counterText: '',
          border: InputBorder.none,
          hintText: AppLocalizations.of(context)!.describe_issue_hint,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: 14,
            fontFamily: AppTextStyles.fontFamilyPoppins,
            fontWeight: FontWeight.w400,
          ),
        ),
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
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedSubject,
        hint: Text(
          'Select a subject...',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: 14,
            fontFamily: AppTextStyles.fontFamilyPoppins,
            fontWeight: FontWeight.w400,
          ),
        ),
        icon: SvgPicture.asset(
          'assets/images/CaretDown.svg',
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            BlendMode.srcIn,
          ),
        ),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
        dropdownColor: Theme.of(context).colorScheme.surface,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 14,
          fontFamily: AppTextStyles.fontFamilyPoppins,
          fontWeight: FontWeight.w400,
        ),
        items: _subjects.map((subject) {
          return DropdownMenuItem<String>(
            value: subject,
            child: Text(
              subject,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: _orderIdController,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 14,
          fontFamily: AppTextStyles.fontFamilyPoppins,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          hintText: 'e.g. ORD-7845',
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: 14,
            fontFamily: AppTextStyles.fontFamilyPoppins,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
