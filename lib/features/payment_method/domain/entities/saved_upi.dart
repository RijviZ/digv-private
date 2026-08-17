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
}
