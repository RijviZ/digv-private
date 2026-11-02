import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/failure.dart';
import '../../../../core/network/file_upload_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/sources/support_ticket_remote_data_source.dart';

class SupportTicketDetailScreen extends ConsumerStatefulWidget {
  final String ticketId;

  const SupportTicketDetailScreen({
    super.key,
    required this.ticketId,
  });

  @override
  ConsumerState<SupportTicketDetailScreen> createState() => _SupportTicketDetailScreenState();
}

typedef SupportTicketDetailsScreen = SupportTicketDetailScreen;

class _SupportTicketDetailScreenState extends ConsumerState<SupportTicketDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  File? _selectedImage;
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatMessageTime(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();

      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

      final hour = dateTime.hour > 12
          ? dateTime.hour - 12
          : (dateTime.hour == 0 ? 12 : dateTime.hour);
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final timeStr = '$hour:$minute $period';

      final difference = today.difference(messageDate).inDays;

      if (difference == 0) {
        return timeStr;
      } else if (difference == 1) {
        return 'Yesterday, $timeStr';
      } else if (difference < 7) {
        final List<String> weekdays = [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday'
        ];
        return '${weekdays[dateTime.weekday - 1]}, $timeStr';
      } else {
        final List<String> months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
        return '${months[dateTime.month - 1]} ${dateTime.day}, $timeStr';
      }
    } catch (_) {
      return '';
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
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
                  _pickImage(ImageSource.camera);
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
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendReply() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    setState(() {
      _isSending = true;
    });

    try {
      String? attachmentUrl;
      if (_selectedImage != null) {
        final uploadService = ref.read(fileUploadServiceProvider);
        attachmentUrl = await uploadService.uploadFile(
          _selectedImage!.path,
          category: 'message-files',
        );
      }

      await ref.read(supportTicketRemoteDataSourceProvider).replyTicket(
            id: widget.ticketId,
            message: text.isNotEmpty ? text : 'Sent an attachment',
            attachmentUrl: attachmentUrl,
          );

      _messageController.clear();
      setState(() {
        _selectedImage = null;
      });

      ref.invalidate(supportTicketDetailProvider(widget.ticketId));
      ref.invalidate(mySupportTicketsProvider);

      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        final msg = e is Failure ? e.message : e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send reply: $msg'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketState = ref.watch(supportTicketDetailProvider(widget.ticketId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            ticketState.when(
              data: (ticket) => _buildHeader(context, ticket),
              loading: () => _buildLoadingHeader(context),
              error: (err, stack) => _buildLoadingHeader(context),
            ),
            Divider(height: 1, color: theme.dividerColor, thickness: 1),
            Expanded(
              child: ticketState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Failed to load details: $err',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              ref.invalidate(supportTicketDetailProvider(widget.ticketId)),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (ticket) {
                  final messagesList = ticket.messages;

                  if (messagesList.isEmpty) {
                    return const Center(
                      child: Text(
                        'No messages in this ticket yet.',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: messagesList.length,
                    itemBuilder: (context, index) {
                      final msg = messagesList[index];
                      // Provider or ticket owner is user, admin/support is received
                      final isMe = msg.sender?.userType == 'CUSTOMER' ||
                          msg.sender?.userType == 'PROVIDER' ||
                          msg.senderId == ticket.userId;
                      final timeStr = _formatMessageTime(msg.createdAt);

                      if (isMe) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildSentMessage(msg, timeStr),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildReceivedMessage(msg, timeStr),
                        );
                      }
                    },
                  );
                },
              ),
            ),
            _buildInputArea(theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: SvgPicture.asset(
              'assets/images/CaretLeft.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.onSurface.withValues(alpha: 0.7),
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Support Ticket Details',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SupportTicketModel ticket) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color badgeBg;
    Color badgeText;
    switch (ticket.ticketStatus.toUpperCase()) {
      case 'OPEN':
        badgeBg = const Color(0xFFECFDF5);
        badgeText = const Color(0xFF059669);
        break;
      case 'IN_PROGRESS':
        badgeBg = const Color(0xFFFFF7ED);
        badgeText = const Color(0xFFC2410C);
        break;
      case 'RESOLVED':
        badgeBg = const Color(0xFFEFF6FF);
        badgeText = const Color(0xFF2563EB);
        break;
      default:
        badgeBg = const Color(0xFFF3F4F6);
        badgeText = const Color(0xFF4B5563);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: SvgPicture.asset(
              'assets/images/CaretLeft.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Color(0xFF6B7280), BlendMode.srcIn),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0A0A0A),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ticket #${ticket.supportTicketNo}',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              ticket.ticketStatus,
              style: TextStyle(
                color: badgeText,
                fontSize: 11,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentMessage(SupportMessageModel msg, String time) {
    final hasAttachment = msg.attachmentUrl != null && msg.attachmentUrl!.isNotEmpty;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(width: 40),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (hasAttachment)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: _buildMessageAttachment(msg.attachmentUrl!),
                ),
              if (!hasAttachment || msg.message != 'Sent an attachment')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF030712),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: Text(
                    msg.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 10,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReceivedMessage(SupportMessageModel msg, String time) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasAttachment = msg.attachmentUrl != null && msg.attachmentUrl!.isNotEmpty;
    final senderName = msg.sender?.fullName ?? 'Support Agent';
    final initials = senderName.isNotEmpty
        ? senderName.trim().split(' ').map((e) => e[0]).take(1).join().toUpperCase()
        : 'S';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFF3B82F6),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                senderName,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 11,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              if (hasAttachment)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: _buildMessageAttachment(msg.attachmentUrl!),
                ),
              if (!hasAttachment || msg.message != 'Sent an attachment')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                  child: Text(
                    msg.message,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 10,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildMessageAttachment(String url) {
    String cleanUrl = url.trim();
    if (cleanUrl.isNotEmpty && !cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      const base = 'https://dev-service-api.roketbus.com';
      cleanUrl = cleanUrl.startsWith('/') ? '$base$cleanUrl' : '$base/$cleanUrl';
    }

    final lower = cleanUrl.toLowerCase();
    final isPdf = lower.contains('.pdf');
    final isImage = lower.contains('.png') ||
        lower.contains('.jpg') ||
        lower.contains('.jpeg') ||
        lower.contains('.webp') ||
        lower.contains('.gif') ||
        lower.contains('.bmp') ||
        lower.contains('.heic') ||
        lower.contains('.heif');

    if (isImage) {
      return GestureDetector(
        onTap: () => _openAttachment(cleanUrl),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 200,
              maxHeight: 200,
            ),
            child: Image.network(
              cleanUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 200,
                  height: 150,
                  color: const Color(0xFFF3F4F6),
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF030712)),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 150,
                  color: const Color(0xFFFEE2E2),
                  alignment: Alignment.center,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red),
                      SizedBox(height: 4),
                      Text(
                        'Failed to load image',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openAttachment(cleanUrl),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file,
                color: isPdf ? const Color(0xFFDC2626) : const Color(0xFF4B5563),
              ),
              const SizedBox(width: 8),
              Text(
                isPdf ? 'View PDF' : 'View Attachment',
                style: AppTextStyles.captionMedium.copyWith(
                  color: const Color(0xFF1F2937),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openAttachment(String rawUrl) async {
    String cleanUrl = rawUrl.trim();
    if (cleanUrl.isEmpty) return;

    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      const base = 'https://dev-service-api.roketbus.com';
      cleanUrl = cleanUrl.startsWith('/') ? '$base$cleanUrl' : '$base/$cleanUrl';
    }

    final lower = cleanUrl.toLowerCase();
    final isImage = lower.contains('.png') ||
        lower.contains('.jpg') ||
        lower.contains('.jpeg') ||
        lower.contains('.webp') ||
        lower.contains('.gif') ||
        lower.contains('.bmp') ||
        lower.contains('.heic') ||
        lower.contains('.heif');

    if (isImage) {
      _showImagePreviewDialog(cleanUrl);
      return;
    }

    try {
      final uri = Uri.parse(cleanUrl);
      bool launched = false;
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}

      if (!launched) {
        try {
          launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (_) {}
      }

      if (!launched) {
        try {
          launched = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
        } catch (_) {}
      }

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open attachment')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open attachment: $e')),
        );
      }
    }
  }

  void _showImagePreviewDialog(String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                  errorBuilder: (context, error, stack) => Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 40),
                        const SizedBox(height: 8),
                        const Text('Failed to load image preview'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () async {
                            final uri = Uri.parse(imageUrl);
                            try {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            } catch (_) {}
                          },
                          child: const Text('Open in Browser'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
            Positioned(
              bottom: 12,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: () async {
                  final uri = Uri.parse(imageUrl);
                  try {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } catch (_) {
                    try {
                      await launchUrl(uri, mode: LaunchMode.platformDefault);
                    } catch (_) {}
                  }
                },
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Open in Browser'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border(
          top: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Column(
        children: [
          if (_selectedImage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedImage = null),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              GestureDetector(
                onTap: _showAttachmentOptions,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/images/attachment.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      isDark ? Colors.white70 : const Color(0xFF4B5563),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _messageController,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: InputBorder.none,
                      hintText: 'Type your message...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: isDark ? Colors.white54 : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _isSending ? null : _sendReply,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _isSending ? const Color(0xFF9CA3AF) : const Color(0xFF030712),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: _isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : SvgPicture.asset(
                          'assets/images/send.svg',
                          width: 18,
                          height: 18,
                          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
