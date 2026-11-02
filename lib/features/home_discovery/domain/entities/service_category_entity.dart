class CategoryItemEntity {
  final String serviceItemId;
  final String? serviceTypeId;
  final String? categoryId;
  final String name;
  final String? description;
  final String basePrice;
  final String? customPrice;
  final String? startingPrice;
  final List<String> features;
  final String? imageUrl;
  final int? durationMinutes;
  final bool isActive;
  final double? rating;
  final int? totalBookings;

  const CategoryItemEntity({
    required this.serviceItemId,
    this.serviceTypeId,
    this.categoryId,
    required this.name,
    this.description,
    required this.basePrice,
    this.customPrice,
    this.startingPrice,
    this.features = const [],
    this.imageUrl,
    this.durationMinutes,
    this.isActive = true,
    this.rating,
    this.totalBookings,
  });

  String get effectivePrice {
    final customNum = double.tryParse(customPrice ?? '') ?? 0.0;
    if (customNum > 0) {
      if (customNum == customNum.roundToDouble()) {
        return customNum.toInt().toString();
      }
      return customNum.toStringAsFixed(2);
    }
    final baseNum = double.tryParse(basePrice) ?? 0.0;
    if (baseNum > 0) {
      if (baseNum == baseNum.roundToDouble()) {
        return baseNum.toInt().toString();
      }
      return baseNum.toStringAsFixed(2);
    }
    final startNum = double.tryParse(startingPrice ?? '');
    final price = (startNum != null && startNum > 0) ? startNum : baseNum;
    if (price == price.roundToDouble()) {
      return price.toInt().toString();
    }
    return price.toStringAsFixed(2);
  }

  String get displayPrice => effectivePrice;

  CategoryItemEntity copyWith({
    String? serviceItemId,
    String? serviceTypeId,
    String? categoryId,
    String? name,
    String? description,
    String? basePrice,
    String? customPrice,
    String? startingPrice,
    List<String>? features,
    String? imageUrl,
    int? durationMinutes,
    bool? isActive,
    double? rating,
    int? totalBookings,
  }) {
    return CategoryItemEntity(
      serviceItemId: serviceItemId ?? this.serviceItemId,
      serviceTypeId: serviceTypeId ?? this.serviceTypeId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice,
      customPrice: customPrice ?? this.customPrice,
      startingPrice: startingPrice ?? this.startingPrice,
      features: features ?? this.features,
      imageUrl: imageUrl ?? this.imageUrl,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      totalBookings: totalBookings ?? this.totalBookings,
    );
  }
}

class CategoryTypeEntity {
  final String serviceTypeId;
  final String? categoryId;
  final String name;
  final String? iconUrl;
  final bool isActive;
  final int sortOrder;
  final List<CategoryItemEntity> items;

  const CategoryTypeEntity({
    required this.serviceTypeId,
    this.categoryId,
    required this.name,
    this.iconUrl,
    required this.isActive,
    this.sortOrder = 0,
    this.items = const [],
  });
}

class ServiceCategoryEntity {
  final String categoryId;
  final String name;
  final String iconUrl;
  final bool isActive;
  final int sortOrder;
  final List<CategoryTypeEntity> serviceTypes;
  final List<CategoryItemEntity> directItems;

  const ServiceCategoryEntity({
    required this.categoryId,
    required this.name,
    required this.iconUrl,
    required this.isActive,
    this.sortOrder = 0,
    required this.serviceTypes,
    this.directItems = const [],
  });

  List<String> get serviceItems => directItems.map((e) => e.name).toList();
}

