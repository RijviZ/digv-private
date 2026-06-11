import '../../domain/entities/service_category_entity.dart';

class CategoryTypeModel extends CategoryTypeEntity {
  const CategoryTypeModel({
    required super.serviceTypeId,
    required super.name,
    required super.isActive,
  });

  factory CategoryTypeModel.fromJson(Map<String, dynamic> json) {
    return CategoryTypeModel(
      serviceTypeId: json['serviceTypeId'] ?? '',
      name: json['name'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }
}

class ServiceCategoryModel extends ServiceCategoryEntity {
  const ServiceCategoryModel({
    required super.categoryId,
    required super.name,
    required super.iconUrl,
    required super.isActive,
    required super.serviceTypes,
    required super.serviceItems,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      categoryId: json['categoryId'] ?? '',
      name: json['name'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
      isActive: json['isActive'] ?? false,
      serviceTypes: (json['types'] as List? ?? [])
          .map((e) => CategoryTypeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      serviceItems: (json['directItems'] as List? ?? [])
          .map((e) => (e as Map<String, dynamic>)['name'].toString())
          .toList(),
    );
  }
}
