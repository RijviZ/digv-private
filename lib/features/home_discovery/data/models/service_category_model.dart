import '../../domain/entities/service_category_entity.dart';

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
      serviceTypes: (json['serviceTypes'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      serviceItems: (json['serviceItems'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
