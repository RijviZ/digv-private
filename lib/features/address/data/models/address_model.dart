import '../../domain/entities/address.dart';

class AddressModel extends Address {
  const AddressModel({
    required super.userLocationId,
    required super.userId,
    super.kind,
    super.label,
    super.lat,
    super.lng,
    super.addressLine,
    super.city,
    super.state,
    super.postalCode,
    super.accuracy,
    super.isLatest,
    super.isDefault,
    super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      userLocationId: json['userLocationId'] ?? '',
      userId: json['userId'] ?? '',
      kind: json['kind'] ?? '',
      label: json['label'] ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      addressLine: json['addressLine'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postalCode'] ?? '',
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      isLatest: json['isLatest'] ?? false,
      isDefault: json['isDefault'] ?? false,
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userLocationId': userLocationId,
      'userId': userId,
      'kind': kind,
      'label': label,
      'lat': lat,
      'lng': lng,
      'addressLine': addressLine,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'accuracy': accuracy,
      'isLatest': isLatest,
      'isDefault': isDefault,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
