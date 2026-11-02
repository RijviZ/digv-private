import '../../domain/entities/service_category_entity.dart';

class CategoryItemModel extends CategoryItemEntity {
  const CategoryItemModel({
    required super.serviceItemId,
    super.serviceTypeId,
    super.categoryId,
    required super.name,
    super.description,
    required super.basePrice,
    super.customPrice,
    super.startingPrice,
    super.features = const [],
    super.imageUrl,
    super.durationMinutes,
    super.isActive = true,
    super.rating,
    super.totalBookings,
  });

  factory CategoryItemModel.fromJson(Map<String, dynamic> json) {
    final customPrice = (json['customPrice'] ??
            json['custom_price'] ??
            json['servicePrice'] ??
            json['price'])
        ?.toString();

    return CategoryItemModel(
      serviceItemId: json['serviceItemId']?.toString() ?? '',
      serviceTypeId: json['serviceTypeId']?.toString(),
      categoryId: json['categoryId']?.toString(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      basePrice: json['basePrice']?.toString() ?? '0',
      customPrice: customPrice,
      startingPrice: json['startingPrice']?.toString(),
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      imageUrl: json['imageUrl']?.toString(),
      durationMinutes: json['durationMinutes'] is int
          ? json['durationMinutes'] as int
          : int.tryParse(json['durationMinutes']?.toString() ?? ''),
      isActive: json['isActive'] is bool ? json['isActive'] as bool : true,
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      totalBookings: json['totalBookings'] != null
          ? int.tryParse(json['totalBookings'].toString())
          : null,
    );
  }
}

class CategoryTypeModel extends CategoryTypeEntity {
  const CategoryTypeModel({
    required super.serviceTypeId,
    super.categoryId,
    required super.name,
    super.iconUrl,
    required super.isActive,
    super.sortOrder = 0,
    super.items = const [],
  });

  factory CategoryTypeModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return CategoryTypeModel(
      serviceTypeId: json['serviceTypeId']?.toString() ?? '',
      categoryId: json['categoryId']?.toString(),
      name: json['name']?.toString() ?? '',
      iconUrl: json['iconUrl']?.toString(),
      isActive: json['isActive'] is bool ? json['isActive'] as bool : false,
      sortOrder: json['sortOrder'] is int ? json['sortOrder'] as int : 0,
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map((e) => CategoryItemModel.fromJson(e))
          .where((item) => item.isActive)
          .toList(),
    );
  }
}

class ServiceCategoryModel extends ServiceCategoryEntity {
  const ServiceCategoryModel({
    required super.categoryId,
    required super.name,
    required super.iconUrl,
    required super.isActive,
    super.sortOrder = 0,
    required super.serviceTypes,
    super.directItems = const [],
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    final rawTypes = (json['types'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => CategoryTypeModel.fromJson(e))
        .where((type) => type.isActive)
        .toList();
    rawTypes.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final rawDirectItems = (json['directItems'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => CategoryItemModel.fromJson(e))
        .where((item) => item.isActive)
        .toList();

    return ServiceCategoryModel(
      categoryId: json['categoryId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      iconUrl: json['iconUrl']?.toString() ?? '',
      isActive: json['isActive'] is bool ? json['isActive'] as bool : false,
      sortOrder: json['sortOrder'] is int ? json['sortOrder'] as int : 0,
      serviceTypes: rawTypes,
      directItems: rawDirectItems,
    );
  }
}

