class ServiceCategoryEntity {
  final String categoryId;
  final String name;
  final String iconUrl;
  final bool isActive;
  final List<String> serviceTypes;
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
