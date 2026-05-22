import 'chat_user.dart';

class ChatParticipant {
  final String participantId;
  final String chatId;
  final String userId;
  final ChatUser? user;
  final String? lastReadMessageId;
  final bool isMuted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ChatParticipant({
    required this.participantId,
    required this.chatId,
    required this.userId,
    this.user,
    this.lastReadMessageId,
    required this.isMuted,
    this.createdAt,
    this.updatedAt,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      participantId: json['participantId'] as String? ?? '',
      chatId: json['chatId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      user: json['user'] != null
          ? ChatUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      lastReadMessageId: json['lastReadMessageId'] as String?,
      isMuted: json['isMuted'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participantId': participantId,
      'chatId': chatId,
      'userId': userId,
      if (user != null) 'user': user!.toJson(),
      'lastReadMessageId': lastReadMessageId,
      'isMuted': isMuted,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
