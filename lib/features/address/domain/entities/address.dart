class Address {
  final String userLocationId;
  final String userId;
  final String? kind;
  final String? label;
  final double? lat;
  final double? lng;
  final String? addressLine;
  final String? city;
  final String? state;
  final String? postalCode;
  final double? accuracy;
  final bool? isLatest;
  final bool? isDefault;
  final bool? isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Address({
    required this.userLocationId,
    required this.userId,
    this.kind,
    this.label,
    this.lat,
    this.lng,
    this.addressLine,
    this.city,
    this.state,
    this.postalCode,
    this.accuracy,
    this.isLatest,
    this.isDefault,
    this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
}
