class MessageModel {
  final String messageId;
  final String chatId;
  final String senderId;
  final String type;
  final String? content;
  final List<String>? attachmentUrls;
  final String createdAt;
  final String updatedAt;

  const MessageModel({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    required this.type,
    this.content,
    this.attachmentUrls,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final attachmentUrlsRaw = json['attachmentUrls'] as List?;
    final List<String>? urls = attachmentUrlsRaw != null
        ? attachmentUrlsRaw.map((e) => e.toString()).toList()
        : null;

    return MessageModel(
      messageId: json['messageId'] as String? ?? json['id'] as String? ?? '',
      chatId: json['chatId'] as String? ?? '',
      senderId: json['senderId'] as String? ??
          (json['sender'] is Map ? (json['sender']['userId'] ?? '') : ''),
      type: json['type'] as String? ?? 'text',
      content: json['content'] as String?,
      attachmentUrls: urls,
      createdAt: json['createdAt']?.toString() ??
          DateTime.now().toUtc().toIso8601String(),
      updatedAt: json['updatedAt']?.toString() ??
          DateTime.now().toUtc().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'senderId': senderId,
      'type': type,
      'content': content,
      'attachmentUrls': attachmentUrls,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
