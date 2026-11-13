class ChatModel {
  final String chatId;
  final String type;
  final String? pairKey;
  final List<ChatParticipantModel> participants;
  final String? lastMessageAt;
  final String? createdAt;
  final String? updatedAt;

  const ChatModel({
    required this.chatId,
    this.type = 'personal',
    this.pairKey,
    required this.participants,
    this.lastMessageAt,
    this.createdAt,
    this.updatedAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    final participantsRaw = json['participants'] as List? ?? [];
    return ChatModel(
      chatId: json['chatId'] as String? ?? json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'personal',
      pairKey: json['pairKey'] as String?,
      participants: participantsRaw
          .map((item) =>
              ChatParticipantModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      lastMessageAt: json['lastMessageAt']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'type': type,
      'pairKey': pairKey,
      'participants': participants.map((p) => p.toJson()).toList(),
      'lastMessageAt': lastMessageAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class ChatParticipantModel {
  final String participantId;
  final String chatId;
  final String userId;
  final ChatUserModel? user;
  final String? lastReadMessageId;
  final bool isMuted;

  const ChatParticipantModel({
    required this.participantId,
    required this.chatId,
    required this.userId,
    this.user,
    this.lastReadMessageId,
    this.isMuted = false,
  });

  factory ChatParticipantModel.fromJson(Map<String, dynamic> json) {
    return ChatParticipantModel(
      participantId: json['participantId'] as String? ?? '',
      chatId: json['chatId'] as String? ?? '',
      userId: json['userId'] as String? ?? json['id'] as String? ?? '',
      user: json['user'] != null
          ? ChatUserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      lastReadMessageId: json['lastReadMessageId'] as String?,
      isMuted: json['isMuted'] as bool? ?? false,
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
    };
  }
}

class ChatUserModel {
  final String userId;
  final String? fullName;
  final String? avatarUrl;
  final String? role;
  final String? phoneNumber;
  final String? countryCode;

  const ChatUserModel({
    required this.userId,
    this.fullName,
    this.avatarUrl,
    this.role,
    this.phoneNumber,
    this.countryCode,
  });

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
      userId: json['userId'] as String? ?? json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? json['name'] as String?,
      avatarUrl: json['avatarUrl'] as String? ?? json['imageUrl'] as String?,
      role: json['role'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      countryCode: json['countryCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'role': role,
      'phoneNumber': phoneNumber,
      'countryCode': countryCode,
    };
  }
}
