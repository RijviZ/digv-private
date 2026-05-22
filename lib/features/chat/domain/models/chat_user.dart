class ChatUser {
  final String userId;
  final String? fullName;
  final String? avatarUrl;
  final String? role;

  const ChatUser({
    required this.userId,
    this.fullName,
    this.avatarUrl,
    this.role,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      userId: json['userId'] as String? ?? json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? json['name'] as String?,
      avatarUrl: json['avatarUrl'] as String? ?? json['imageUrl'] as String?,
      role: json['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'role': role,
    };
  }
}
