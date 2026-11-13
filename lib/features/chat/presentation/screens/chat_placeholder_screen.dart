import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:digv/I10n/app_localizations.dart';
import 'package:digv/features/chat/presentation/providers/chat_provider.dart';
import 'package:digv/features/chat/data/models/chat_model.dart';
import 'chat_detail_screen.dart';

class ChatPlaceholderScreen extends ConsumerStatefulWidget {
  const ChatPlaceholderScreen({super.key});

  @override
  ConsumerState<ChatPlaceholderScreen> createState() =>
      _ChatPlaceholderScreenState();
}

class _ChatPlaceholderScreenState extends ConsumerState<ChatPlaceholderScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        return DateFormat('hh:mm a').format(dateTime);
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else {
        return DateFormat('dd MMM').format(dateTime);
      }
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatsAsync = ref.watch(chatListProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 16, left: 16, right: 16, bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (Navigator.of(context).canPop()) ...[
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
                      ],
                      Text(
                        AppLocalizations.of(context)?.messages ?? 'Messages',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 24,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          height: 1.40,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E1E1E)
                          : const Color(0xFFF7F7F7),
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/search.svg',
                          width: 15,
                          height: 15,
                          colorFilter: ColorFilter.mode(
                            theme.colorScheme.secondary.withValues(alpha: 0.5),
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val.trim().toLowerCase();
                              });
                            },
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)
                                      ?.search_conversations ??
                                  'Search conversations...',
                              hintStyle: TextStyle(
                                color: theme.colorScheme.secondary
                                    .withValues(alpha: 0.6),
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Expanded(
              child: chatsAsync.when(
                data: (chats) {
                  final filteredChats = chats.where((chat) {
                    if (_searchQuery.isEmpty) return true;
                    final peerParticipant = chat.participants.firstWhere(
                      (p) => p.user?.role != 'CUSTOMER',
                      orElse: () => chat.participants.first,
                    );
                    final name = peerParticipant.user?.fullName?.toLowerCase() ?? '';
                    return name.contains(_searchQuery);
                  }).toList();

                  if (filteredChats.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isEmpty ? 'No messages yet' : 'No matching conversations',
                        style: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => ref.refresh(chatListProvider.future),
                    child: ListView.separated(
                      itemCount: filteredChats.length,
                      separatorBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 16.0),
                        child: Divider(
                            height: 1,
                            color: theme.dividerColor,
                            thickness: 0.5),
                      ),
                      itemBuilder: (context, index) {
                        final chat = filteredChats[index];
                        final peerParticipant = chat.participants.firstWhere(
                          (p) => p.user?.role != 'CUSTOMER',
                          orElse: () => chat.participants.first,
                        );
                        final customer = peerParticipant.user;
                        final customerName =
                            customer?.fullName ?? 'Technician';
                        final avatarInitial = customerName.isNotEmpty
                            ? customerName[0].toUpperCase()
                            : 'T';
                        final timeStr = _formatTime(chat.lastMessageAt);

                        return _buildChatItem(
                          context: context,
                          chat: chat,
                          name: customerName,
                          time: timeStr,
                          message: AppLocalizations.of(context)
                                  ?.tap_to_view_conversation ??
                              'Tap to view conversation',
                          subtitle: customer?.phoneNumber != null
                              ? '${customer?.countryCode ?? ""}${customer?.phoneNumber}'
                              : (customer?.role == 'PROVIDER'
                                  ? 'Technician'
                                  : 'Customer chat'),
                          avatarInitial: avatarInitial,
                          unreadCount: 0,
                          avatarUrl: customer?.avatarUrl,
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Failed to load messages: $error',
                        style: TextStyle(
                          color: Colors.red.shade400,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref.refresh(chatListProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatItem({
    required BuildContext context,
    required ChatModel chat,
    required String name,
    required String time,
    required String message,
    required String subtitle,
    required String avatarInitial,
    required int unreadCount,
    required String? avatarUrl,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        final peerParticipant = chat.participants.firstWhere(
          (p) => p.user?.role != 'CUSTOMER',
          orElse: () => chat.participants.first,
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              chatId: chat.chatId,
              peerUserId: peerParticipant.userId,
              customerName: name,
              customerAvatar: avatarUrl,
              customerPhone: subtitle,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFF0A0A0A),
                    shape: BoxShape.circle,
                    image: (avatarUrl != null && avatarUrl.isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(avatarUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: (avatarUrl != null && avatarUrl.isNotEmpty)
                      ? null
                      : Text(
                          avatarInitial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                          ),
                        ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: theme.colorScheme.surface, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight:
                              unreadCount > 0 ? FontWeight.w700 : FontWeight.w600,
                          height: 1.5,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontSize: 11,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color:
                          theme.colorScheme.secondary.withValues(alpha: 0.7),
                      fontSize: 10,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
