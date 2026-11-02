class SavedUpi {
  final String id;
  final String name;
  final String upiId;
  final String emoji;
  final bool isDefault;

  const SavedUpi({
    required this.id,
    required this.name,
    required this.upiId,
    this.emoji = '🪙',
    this.isDefault = false,
  });

  SavedUpi copyWith({
    String? id,
    String? name,
    String? upiId,
    String? emoji,
    bool? isDefault,
  }) {
    return SavedUpi(
      id: id ?? this.id,
      name: name ?? this.name,
      upiId: upiId ?? this.upiId,
      emoji: emoji ?? this.emoji,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'upiId': upiId,
      'emoji': emoji,
      'isDefault': isDefault,
    };
  }

  factory SavedUpi.fromJson(Map<String, dynamic> json) {
    return SavedUpi(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      upiId: json['upiId'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '🪙',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}
