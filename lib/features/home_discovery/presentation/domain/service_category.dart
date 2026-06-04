class ServiceCategory {
  final String label;
  final String icon;

  const ServiceCategory({
    required this.label,
    required this.icon,
  });

  ServiceCategory copyWith({
    String? label,
    String? icon,
  }) {
    return ServiceCategory(
      label: label ?? this.label,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'icon': icon,
    };
  }

  factory ServiceCategory.fromMap(Map<String, dynamic> map) {
    return ServiceCategory(
      label: map['label'] as String,
      icon: map['icon'] as String,
    );
  }

  @override
  String toString() => 'ServiceCategory(label: $label, icon: $icon)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceCategory &&
        other.label == label &&
        other.icon == icon;
  }

  @override
  int get hashCode => label.hashCode ^ icon.hashCode;
}
