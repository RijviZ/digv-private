import 'chat_participant.dart';

class Chat {
  final String chatId;
  final String type; // e.g., 'personal'
  final String? pairKey;
  final List<ChatParticipant> participants;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Chat({
    required this.chatId,
    required this.type,
    this.pairKey,
    required this.participants,
    this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    final participantsRaw = json['participants'] as List?;
    final List<ChatParticipant> parsedParticipants = participantsRaw != null
        ? participantsRaw
            .map((e) => ChatParticipant.fromJson(e as Map<String, dynamic>))
            .toList()
        : [];

    return Chat(
      chatId: json['chatId'] as String? ?? '',
      type: json['type'] as String? ?? 'personal',
      pairKey: json['pairKey'] as String?,
      participants: parsedParticipants,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.tryParse(json['lastMessageAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'type': type,
      'pairKey': pairKey,
      'participants': participants.map((e) => e.toJson()).toList(),
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
