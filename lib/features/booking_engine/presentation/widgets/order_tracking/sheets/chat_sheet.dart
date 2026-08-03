import 'dart:async';
import 'package:digv/I10n/app_localizations.dart';
import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/features/chat/domain/models/chat_message.dart' as chat_models;
import 'package:digv/features/chat/domain/models/message_type.dart';
import 'package:digv/features/chat/presentation/providers/chat_provider.dart';
import 'package:digv/features/auth/presentation/providers/auth_provider.dart';
import 'package:digv/core/network/file_upload_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChatSheet extends ConsumerStatefulWidget {
  final String peerUserId;
  final String peerName;
  final String? peerAvatarUrl;

  const ChatSheet({
    super.key,
    required this.peerUserId,
    required this.peerName,
    this.peerAvatarUrl,
  });

  @override
  ConsumerState<ChatSheet> createState() => _ChatSheetState();
}

class _ChatSheetState extends ConsumerState<ChatSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isMeTyping = false;
  Timer? _typingDebounce;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    
    // Initial scroll after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(animated: false);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _scrollController.dispose();
    _typingDebounce?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    if (!_isMeTyping && _controller.text.isNotEmpty) {
      _isMeTyping = true;
      ref.read(activeChatNotifierProvider(widget.peerUserId).notifier).notifyTyping(true);
    }
    
    _typingDebounce?.cancel();
    _typingDebounce = Timer(const Duration(seconds: 2), () {
      if (_isMeTyping) {
        _isMeTyping = false;
        ref.read(activeChatNotifierProvider(widget.peerUserId).notifier).notifyTyping(false);
      }
    });
  }

  void _scrollToBottom({bool animated = true}) {
    if (_scrollController.hasClients) {
      if (animated) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    }
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    ref.read(activeChatNotifierProvider(widget.peerUserId).notifier).sendMessage(text);
    _controller.clear();
    
    if (_isMeTyping) {
      _isMeTyping = false;
      ref.read(activeChatNotifierProvider(widget.peerUserId).notifier).notifyTyping(false);
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _handlePickImage() async {
    final l10n = AppLocalizations.of(context)!;
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(l10n.uploading_attachment, style: const TextStyle(color: Colors.white)),
          ],
        ),
        duration: const Duration(seconds: 15),
      ),
    );

    try {
      final uploadService = ref.read(fileUploadServiceProvider);
      final url = await uploadService.uploadFile(image.path, category: 'message-files');
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Send image message
      await ref.read(activeChatNotifierProvider(widget.peerUserId).notifier).sendMessage(
        l10n.sent_image_attachment,
        type: 'image',
        attachmentUrls: [url],
      );

      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chatState = ref.watch(activeChatNotifierProvider(widget.peerUserId));
    final profileAsync = ref.watch(profileProvider);

    // Set up auto-scroller listener when new messages arrive
    ref.listen<ActiveChatState>(
      activeChatNotifierProvider(widget.peerUserId),
      (previous, next) {
        if (previous?.messages.length != next.messages.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        }
      },
    );

    final inputBg = Theme.of(context).brightness == Brightness.dark
        ? AppColors.inputBgSecondaryDark
        : AppColors.inputBgSecondary;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: Column(
          children: [
            // Header Handler bar
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  // Technician Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: inputBg,
                      border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
                      image: widget.peerAvatarUrl != null && widget.peerAvatarUrl!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(widget.peerAvatarUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: widget.peerAvatarUrl == null || widget.peerAvatarUrl!.isEmpty
                        ? Icon(Icons.person, color: Theme.of(context).colorScheme.secondary, size: 28)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.peerName,
                          style: AppTextStyles.titleLight.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.online_status,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Close Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: inputBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.primary,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Theme.of(context).dividerColor),
            
            // Messages Area
            Expanded(
              child: profileAsync.when(
                data: (profileUser) {
                  if (chatState.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (chatState.errorMessage != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              chatState.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.error),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                ref.invalidate(activeChatNotifierProvider(widget.peerUserId));
                              },
                              child: Text(l10n.retry),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final messages = chatState.messages;
                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 48,
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.no_messages_yet,
                            style: AppTextStyles.caption.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == profileUser.userId;
                      return _ChatBubble(message: msg, isMe: isMe);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Text('Authentication error: $err', style: const TextStyle(color: AppColors.error)),
                ),
              ),
            ),
            
            // Input Area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              child: Row(
                children: [
                  // Attachment Button
                  GestureDetector(
                    onTap: _handlePickImage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: inputBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Icon(
                        Icons.image_outlined,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  
                  // Text Input
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: inputBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _handleSend(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.type_a_message,
                          hintStyle: AppTextStyles.captionMedium.copyWith(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _handleSend,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/images/send.svg',
                          width: 16,
                          height: 16,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.onPrimary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],  
        ),
      );
    } 
}

class _ChatBubble extends StatelessWidget {
  final chat_models.ChatMessage message;
  final bool isMe;

  const _ChatBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final String timeString = DateFormat('hh:mm a').format(message.createdAt.toLocal());
    final hasAttachment = message.attachmentUrls.isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bubbleBg = isMe
        ? Theme.of(context).colorScheme.primary
        : (isDark ? AppColors.inputBgSecondaryDark : AppColors.inputBgSecondary);
    final textColor = isMe
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.primary;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bubbleBg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
                  bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Attachment image if exists
                  if (hasAttachment) ...[
                    GestureDetector(
                      onTap: () {
                        // Optional image zoom screen
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: EdgeInsets.zero,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                InteractiveViewer(
                                  child: Image.network(
                                    message.attachmentUrls.first,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Positioned(
                                  top: 40,
                                  right: 20,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          constraints: const BoxConstraints(
                            maxHeight: 180,
                          ),
                          width: double.infinity,
                          child: Image.network(
                            message.attachmentUrls.first,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                height: 120,
                                color: Colors.black.withOpacity(0.04),
                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              height: 120,
                              color: Colors.black.withOpacity(0.04),
                              child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  
                  // Text Content
                  if (message.content != null && message.content!.isNotEmpty && message.type == MessageType.text)
                    Text(
                      message.content!,
                      style: AppTextStyles.captionMedium.copyWith(
                        color: textColor,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                  
                  if (message.type == MessageType.image && !hasAttachment && message.content != null)
                    Text(
                      message.content!,
                      style: AppTextStyles.captionMedium.copyWith(
                        color: textColor,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            
            // Timestamp and read receipt
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeString,
                  style: AppTextStyles.caption.copyWith(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all,
                    size: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
