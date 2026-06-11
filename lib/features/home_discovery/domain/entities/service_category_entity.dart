class CategoryTypeEntity {
  final String serviceTypeId;
  final String name;
  final bool isActive;

  const CategoryTypeEntity({
    required this.serviceTypeId,
    required this.name,
    required this.isActive,
  });
}

class ServiceCategoryEntity {
  final String categoryId;
  final String name;
  final String iconUrl;
  final bool isActive;
  final List<CategoryTypeEntity> serviceTypes;
  final List<String> serviceItems;

  const ServiceCategoryEntity({
    required this.categoryId,
    required this.name,
    required this.iconUrl,
    required this.isActive,
    required this.serviceTypes,
    required this.serviceItems,
  });
}
