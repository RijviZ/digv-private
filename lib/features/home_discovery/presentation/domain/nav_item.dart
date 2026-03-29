
class NavItem {
  final String icon;
  final String label;

  const NavItem({required this.icon, required this.label});

  NavItem copyWith({String? icon, String? label}) {
    return NavItem(icon: icon ?? this.icon, label: label ?? this.label);
  }

  Map<String, dynamic> toMap() {
    return {'icon': icon, 'label': label};
  }

  factory NavItem.fromMap(Map<String, dynamic> map) {
    return NavItem(icon: map['icon'] as String, label: map['label'] as String);
  }

  @override
  String toString() => 'NavItem(icon: $icon, label: $label)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NavItem && other.icon == icon && other.label == label;
  }

  @override
  int get hashCode => icon.hashCode ^ label.hashCode;
}
