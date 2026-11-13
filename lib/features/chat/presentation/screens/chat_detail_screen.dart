import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:digv/features/chat/presentation/providers/chat_provider.dart';
import 'package:digv/features/orders/presentation/providers/orders_provider.dart';
import 'package:digv/features/orders/domain/models/order_item.dart';
import 'package:digv/core/network/file_upload_service.dart';
import 'package:digv/I10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String peerUserId;
  final String customerName;
  final String? customerAvatar;
  final String? customerPhone;
  final dynamic activeJob;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.peerUserId,
    required this.customerName,
    this.customerAvatar,
    this.customerPhone,
    this.activeJob,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _showPinnedJob = true;
  bool _isUploading = false;

  @override
  void dispose() {
    _controller.dispose();
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
      if (difference == 0) return timeStr;
      if (difference == 1) return 'Yesterday, $timeStr';
      if (difference < 7) {
        const weekdays = [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday',
        ];
        return '${weekdays[dateTime.weekday - 1]}, $timeStr';
      }
      final monthStr = dateTime.month.toString().padLeft(2, '0');
      final dayStr = dateTime.day.toString().padLeft(2, '0');
      return '$dayStr/$monthStr/${dateTime.year}, $timeStr';
    } catch (_) {
      return '';
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await ref
        .read(chatMessagesProvider(widget.chatId).notifier)
        .sendMessage(text, peerUserId: widget.peerUserId);
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (image != null) {
        setState(() => _isUploading = true);
        final fileUploadService = ref.read(fileUploadServiceProvider);
        final uploadedUrl = await fileUploadService.uploadFile(
          image.path,
          category: 'message-files',
        );
        if (uploadedUrl.isNotEmpty) {
          await ref
              .read(chatMessagesProvider(widget.chatId).notifier)
              .sendMessage(
                'Sent an image attachment',
                peerUserId: widget.peerUserId,
                type: 'image',
                attachmentUrls: [uploadedUrl],
              );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showAttachmentOptions() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: theme.colorScheme.primary,
                ),
                title: Text(
                  'Take Photo',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: theme.colorScheme.primary,
                ),
                title: Text(
                  'Choose from Gallery',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageAttachment(String url) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200, maxHeight: 200),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 200,
              height: 150,
              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6),
              alignment: Alignment.center,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            width: 200,
            height: 150,
            color: isDark ? const Color(0xFF3B1010) : const Color(0xFFFEE2E2),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(height: 4),
                Text(
                  'Failed to load',
                  style: TextStyle(
                    color: Colors.red.shade400,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messagesState = ref.watch(chatMessagesProvider(widget.chatId));
    final messagesAsync = messagesState.messages;
    final activeOrders = ref.watch(ordersProvider('ACTIVE')).value;
    final activeJob =
        widget.activeJob ??
        (activeOrders != null && activeOrders.isNotEmpty
            ? activeOrders.first
            : null);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, activeJob),
            Divider(height: 1, color: theme.dividerColor, thickness: 1),
            if (_showPinnedJob && activeJob != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildPinnedJobDetails(activeJob),
              ),
            Expanded(
              child: messagesAsync.when(
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Failed to load messages: $err',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                data: (messagesList) {
                  if (messagesList.isEmpty) {
                    return Center(
                      child: Text(
                        'No messages yet. Say Hello!',
                        style: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    );
                  }
                  final reversedList = messagesList.reversed.toList();
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    itemCount: reversedList.length,
                    itemBuilder: (context, index) {
                      final msg = reversedList[index];
                      final isMe = msg.senderId == (messagesState.userId ?? '');
                      final timeStr = _formatMessageTime(msg.createdAt);
                      if (isMe) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildSentMessage(
                            text: msg.content ?? '',
                            time: timeStr,
                            isRead: true,
                            attachmentUrls: msg.attachmentUrls,
                          ),
                        );
                      } else {
                        final initials = widget.customerName.isNotEmpty
                            ? widget.customerName
                                  .trim()
                                  .split(' ')
                                  .map((e) => e.isNotEmpty ? e[0] : '')
                                  .take(1)
                                  .join()
                                  .toUpperCase()
                            : 'C';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildReceivedMessage(
                            text: msg.content ?? '',
                            time: timeStr,
                            avatarInitial: initials,
                            attachmentUrls: msg.attachmentUrls,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic activeJob) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final avatarUrl = widget.customerAvatar;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    final initials = widget.customerName.isNotEmpty
        ? widget.customerName.trim().split(' ').first[0].toUpperCase()
        : 'C';
    final hasActiveJob = activeJob != null;
    final jobTitle = hasActiveJob
        ? (activeJob is Map
              ? activeJob['title'] ?? 'Active Job'
              : (activeJob is OrderItem ? activeJob.serviceName : 'Active Job'))
        : 'Customer Chat';
    final jobStatus = hasActiveJob
        ? (activeJob is Map
              ? activeJob['status'] ?? 'In Progress'
              : (activeJob is OrderItem
                    ? activeJob.status.label
                    : 'In Progress'))
        : null;

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
                theme.colorScheme.secondary,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: hasAvatar
                  ? Colors.transparent
                  : (isDark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFF0A0A0A)),
              shape: BoxShape.circle,
              image: hasAvatar
                  ? DecorationImage(
                      image: NetworkImage(avatarUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: hasAvatar
                ? null
                : Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.customerName,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        jobTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    if (jobStatus != null) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 2,
                        ),
                        decoration: ShapeDecoration(
                          color: isDark
                              ? const Color(0xFF3B2800)
                              : const Color(0xFFFFF7ED),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: isDark
                                  ? const Color(0xFF92400E)
                                  : const Color(0xFFFED7AA),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          jobStatus.toUpperCase() == 'ACCEPTED'
                              ? (AppLocalizations.of(context)?.accepted ??
                                    'ACCEPTED')
                              : jobStatus,
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFFFB923C)
                                : const Color(0xFFC2410C),
                            fontSize: 10,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (widget.customerPhone != null && widget.customerPhone!.isNotEmpty)
            GestureDetector(
              onTap: () async {
                final uri = Uri(scheme: 'tel', path: widget.customerPhone);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Could not place call to ${widget.customerPhone}',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF14532D).withValues(alpha: 0.4)
                      : const Color(0xFFF0FDF4),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF166534)
                        : const Color(0xFFBBF7D0),
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/images/phone.svg',
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF16A34A),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPinnedJobDetails(dynamic activeJob) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final title = activeJob is Map
        ? activeJob['title'] ?? 'Active Job'
        : (activeJob is OrderItem ? activeJob.serviceName : 'Active Job');
    final amount = activeJob is Map
        ? activeJob['amount'] ?? 399
        : (activeJob is OrderItem ? activeJob.price : 399);
    final address = activeJob is Map
        ? activeJob['address'] ?? 'Address not available'
        : (activeJob is OrderItem
              ? activeJob.location
              : 'Address not available');
    final isPrePaid = activeJob is Map
        ? (activeJob['paymentStatus'] == 'PREPAID' ||
              activeJob['paymentStatus'] == 'PAID' ||
              activeJob['isPrePaid'] == true)
        : (activeJob is OrderItem
              ? (activeJob.paymentStatus == 'PAID' ||
                    activeJob.paymentStatus == 'PREPAID')
              : true);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF3B2800) : const Color(0xFFFFF7ED),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/pin_g.svg',
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(
                        theme.colorScheme.onSurface,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)?.pinned_job_details ??
                          'Pinned Job Details',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => setState(() => _showPinnedJob = false),
                  child: SvgPicture.asset(
                    'assets/images/close.svg',
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                      theme.colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Window · Today 2:00 PM',
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          amount.toString().startsWith('₹')
                              ? amount.toString()
                              : '₹$amount',
                          style: const TextStyle(
                            color: Color(0xFF16A34A),
                            fontSize: 20,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          isPrePaid
                              ? (AppLocalizations.of(context)?.pre_paid ??
                                    'Pre-paid')
                              : (AppLocalizations.of(context)?.post_paid ??
                                    'Post-paid'),
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF93C5FD)
                                : const Color(0xFF1E40AF),
                            fontSize: 10,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/MapPin.svg',
                      width: 14,
                      height: 14,
                      colorFilter: ColorFilter.mode(
                        theme.colorScheme.secondary,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        address,
                        style: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '2.1 ${AppLocalizations.of(context)?.km_away ?? "km away"}',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF93C5FD)
                            : const Color(0xFF1E40AF),
                        fontSize: 11,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(width: 1, color: theme.dividerColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          AppLocalizations.of(context)?.navigate ?? 'Navigate',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (activeJob is Map) {
                            final reqId =
                                activeJob['serviceRequestId'] ??
                                activeJob['orderId'];
                            if (reqId != null) {
                              context.push(
                                '/order_tracking',
                                extra: reqId.toString(),
                              );
                            }
                          } else if (activeJob is OrderItem) {
                            context.push('/order_tracking', extra: activeJob);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          AppLocalizations.of(context)?.continue_job ??
                              'Continue Job',
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceivedMessage({
    required String text,
    required String time,
    required String avatarInitial,
    List<String>? attachmentUrls,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasAttachment = attachmentUrls != null && attachmentUrls.isNotEmpty;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFF0A0A0A),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            avatarInitial,
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
              if (hasAttachment)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: _buildImageAttachment(attachmentUrls.first),
                ),
              if (!hasAttachment || text != 'Sent an image attachment')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                  child: Text(
                    text,
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
                style: TextStyle(
                  color: theme.colorScheme.secondary,
                  fontSize: 10,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildSentMessage({
    required String text,
    required String time,
    required bool isRead,
    List<String>? attachmentUrls,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasAttachment = attachmentUrls != null && attachmentUrls.isNotEmpty;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(width: 48),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (hasAttachment)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: _buildImageAttachment(attachmentUrls.first),
                ),
              if (!hasAttachment || text != 'Sent an image attachment')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFF0A0A0A),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: Text(
                    text,
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontSize: 10,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (isRead)
                    const Icon(
                      Icons.check_circle_outline,
                      size: 12,
                      color: Color(0xFF3B82F6),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputArea() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: _isUploading ? null : _showAttachmentOptions,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: _isUploading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : Icon(
                        Icons.add_photo_alternate_outlined,
                        color: theme.colorScheme.secondary,
                        size: 22,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E1E1E)
                      : const Color(0xFFF9FAFB),
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _sendMessage(),
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText:
                        AppLocalizations.of(context)?.type_a_message_hint ??
                        'Type a message...',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFF0A0A0A),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/images/send.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
