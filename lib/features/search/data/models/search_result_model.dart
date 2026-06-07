import '../../domain/entities/search_result.dart';

class SearchProviderModel extends SearchProviderEntity {
  SearchProviderModel({
    required super.userId,
    required super.fullName,
    super.avatarUrl,
    required super.userProfileId,
    super.bio,
    required super.isAvailableNow,
    required super.basePrice,
    required super.currency,
    required super.verificationStatus,
    required super.addressLine,
    required super.city,
    required super.distanceKm,
    required super.services,
    super.averageRating,
    super.reviewCount,
    super.completedServiceRequestCount,
    super.providerLat,
    super.providerLng,
  });

  factory SearchProviderModel.fromJson(Map<String, dynamic> json) {
    return SearchProviderModel(
      userId: json['userId'] ?? '',
      fullName: json['fullName'] ?? '',
      avatarUrl: json['avatarUrl'],
      userProfileId: json['userProfileId'] ?? '',
      bio: json['bio'],
      isAvailableNow: json['isAvailableNow'] ?? false,
      basePrice: json['basePrice'] ?? '0.00',
      currency: json['currency'] ?? 'INR',
      verificationStatus: json['verificationStatus'] ?? '',
      addressLine: json['addressLine'] ?? '',
      city: json['city'] ?? '',
      distanceKm: json['distanceKm'] ?? '0.00',
      services:
          (json['services'] as List<dynamic>?)
              ?.map(
                (s) => SearchServiceModel.fromJson(s as Map<String, dynamic>),
              )
              .toList() ??
          [],
      averageRating: json['averageRating']?.toString(),
      reviewCount: json['reviewCount'],
      completedServiceRequestCount: json['completedServiceRequestCount'],
      providerLat: (json['providerLat'] as num?)?.toDouble(),
      providerLng: (json['providerLng'] as num?)?.toDouble(),
    );
  }
}

class SearchServiceModel extends SearchServiceEntity {
  SearchServiceModel({
    required super.isActive,
    required super.categoryId,
    required super.categoryName,
    required super.priceOverride,
    required super.serviceType,
    required super.experienceYears,
    required super.title,
    required super.serviceId,
    super.categoryIconUrl,
    super.serviceImageUrl,
    super.durationMinutes,
    super.serviceFeatures,
    super.serviceDescription,
    super.serviceItems,
  });

  factory SearchServiceModel.fromJson(Map<String, dynamic> json) {
    return SearchServiceModel(
      isActive: json['isActive'] ?? false,
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      priceOverride: json['priceOverride'] ?? 0,
      serviceType: json['serviceType'] ?? '',
      experienceYears: json['experienceYears'] ?? 0,
      title: json['title'] ?? '',
      serviceId: json['serviceId'] ?? '',
      categoryIconUrl: json['categoryIconUrl'],
      serviceImageUrl: json['serviceImageUrl'],
      durationMinutes: json['durationMinutes'],
      serviceFeatures: (json['serviceFeatures'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      serviceDescription: json['serviceDescription'],
      serviceItems: (json['serviceItems'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }
}

class SearchResponseModel extends SearchResponseEntity {
  SearchResponseModel({
    required super.providers,
    required super.total,
    required super.page,
    required super.limit,
    required super.totalPages,
    super.searchText,
    super.userLocation,
  });

  factory SearchResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final providers = data['providers'] as List<dynamic>?;
    final pagination = data['pagination'];

    return SearchResponseModel(
      providers:
          providers
              ?.map(
                (p) => SearchProviderModel.fromJson(p as Map<String, dynamic>),
              )
              .toList() ??
          [],
      total: pagination?['total'] ?? 0,
      page: pagination?['page'] ?? 1,
      limit: pagination?['limit'] ?? 10,
      totalPages: pagination?['totalPages'] ?? 1,
      searchText: data?['searchText'],
      userLocation: data?['userLocation'],
    );
  }
}
