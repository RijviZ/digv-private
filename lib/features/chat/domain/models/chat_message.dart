import 'chat_user.dart';
import 'message_type.dart';

class ChatMessage {
  final String messageId;
  final String chatId;
  final String senderId;
  final ChatUser? sender;
  final MessageType type;
  final String? content;
  final List<String> attachmentUrls;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ChatMessage({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    this.sender,
    required this.type,
    this.content,
    required this.attachmentUrls,
    required this.createdAt,
    this.updatedAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final attachmentUrlsRaw = json['attachmentUrls'] as List?;
    final List<String> urls = attachmentUrlsRaw != null
        ? attachmentUrlsRaw.map((e) => e.toString()).toList()
        : [];

    return ChatMessage(
      messageId: json['messageId'] as String? ?? json['id'] as String? ?? '',
      chatId: json['chatId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      sender: json['sender'] != null
          ? ChatUser.fromJson(json['sender'] as Map<String, dynamic>)
          : null,
      type: MessageType.fromString(json['type'] as String? ?? 'text'),
      content: json['content'] as String?,
      attachmentUrls: urls,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'senderId': senderId,
      if (sender != null) 'sender': sender!.toJson(),
      'type': type.toJson(),
      'content': content,
      'attachmentUrls': attachmentUrls,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
