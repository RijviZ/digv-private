class QuickServiceItem {
  final String label;
  final String price;

  const QuickServiceItem({
    required this.label,
    required this.price,
  });

  QuickServiceItem copyWith({
    String? label,
    String? price,
  }) {
    return QuickServiceItem(
      label: label ?? this.label,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'price': price,
    };
  }

  factory QuickServiceItem.fromMap(Map<String, dynamic> map) {
    return QuickServiceItem(
      label: map['label'] as String,
      price: map['price'] as String,
    );
  }

  @override
  String toString() => 'QuickServiceItem(label: $label, price: $price)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuickServiceItem &&
        other.label == label &&
        other.price == price;
  }

  @override
  int get hashCode => label.hashCode ^ price.hashCode;
}
