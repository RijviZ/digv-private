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
      experienceYears: json['experienceYears'] is int
          ? json['experienceYears'] as int
          : (double.tryParse(json['experienceYears']?.toString() ?? '')?.toInt() ?? 0),
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

class SearchServiceItemModel extends SearchServiceItemEntity {
  SearchServiceItemModel({
    required super.serviceItemId,
    required super.serviceItemName,
    super.serviceItemDescription,
    super.durationMinutes,
    required super.basePrice,
    super.serviceItemImageUrl,
    super.serviceTypeId,
    super.serviceTypeName,
    super.serviceCategoryId,
    super.serviceCategoryName,
    required super.startingPrice,
    required super.availableProvidersCount,
    required super.nearestProviderDistanceKm,
    super.rating,
    required super.totalBookings,
  });

  factory SearchServiceItemModel.fromJson(Map<String, dynamic> json) {
    return SearchServiceItemModel(
      serviceItemId: json['serviceItemId'] ?? '',
      serviceItemName: json['serviceItemName'] ?? '',
      serviceItemDescription: json['serviceItemDescription'],
      durationMinutes: json['durationMinutes'],
      basePrice: json['basePrice']?.toString() ?? '0.00',
      serviceItemImageUrl: json['serviceItemImageUrl'],
      serviceTypeId: json['serviceTypeId'],
      serviceTypeName: json['serviceTypeName'],
      serviceCategoryId: json['serviceCategoryId'],
      serviceCategoryName: json['serviceCategoryName'],
      startingPrice: json['startingPrice']?.toString() ?? '0.00',
      availableProvidersCount: json['availableProvidersCount'] ?? 0,
      nearestProviderDistanceKm: json['nearestProviderDistanceKm']?.toString() ?? '0.00',
      rating: (json['rating'] as num?)?.toDouble(),
      totalBookings: json['totalBookings'] ?? 0,
    );
  }
}

class SearchResponseModel extends SearchResponseEntity {
  SearchResponseModel({
    required super.services,
    required super.total,
    required super.page,
    required super.limit,
    required super.totalPages,
    super.searchText,
    super.userLocation,
  });

  factory SearchResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final services = data['services'] as List<dynamic>?;
    final pagination = data['pagination'];

    return SearchResponseModel(
      services:
          services
              ?.map(
                (s) => SearchServiceItemModel.fromJson(s as Map<String, dynamic>),
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

class SelectableTypeModel extends SelectableTypeEntity {
  SelectableTypeModel({
    required super.serviceTypeId,
    required super.name,
    required super.isActive,
  });

  factory SelectableTypeModel.fromJson(Map<String, dynamic> json) {
    return SelectableTypeModel(
      serviceTypeId: json['serviceTypeId'] ?? '',
      name: json['name'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }
}

class ServiceDetailsModel extends ServiceDetailsEntity {
  ServiceDetailsModel({
    required super.serviceItemId,
    required super.serviceItemName,
    super.serviceItemDescription,
    super.durationMinutes,
    required super.basePrice,
    super.serviceItemImageUrl,
    super.serviceTypeId,
    super.serviceCategoryId,
    super.serviceCategoryName,
    required super.whatsIncluded,
    super.rating,
    required super.totalBookings,
    required super.startingPrice,
    required super.nearestProviderDistanceKm,
    required super.totalAvailableProviders,
    required super.selectableTypes,
  });

  factory ServiceDetailsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ServiceDetailsModel(
      serviceItemId: data['serviceItemId'] ?? '',
      serviceItemName: data['serviceItemName'] ?? '',
      serviceItemDescription: data['serviceItemDescription'],
      durationMinutes: data['durationMinutes'],
      basePrice: data['basePrice']?.toString() ?? '0.00',
      serviceItemImageUrl: data['serviceItemImageUrl'],
      serviceTypeId: data['serviceTypeId'],
      serviceCategoryId: data['serviceCategoryId'],
      serviceCategoryName: data['serviceCategoryName'],
      whatsIncluded: (data['whatsIncluded'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rating: (data['rating'] as num?)?.toDouble(),
      totalBookings: data['totalBookings'] ?? 0,
      startingPrice: data['startingPrice']?.toString() ?? '0.00',
      nearestProviderDistanceKm: data['nearestProviderDistanceKm']?.toString() ?? '0.00',
      totalAvailableProviders: data['totalAvailableProviders'] ?? 0,
      selectableTypes: (data['selectableTypes'] as List<dynamic>?)
              ?.map((e) => SelectableTypeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class SearchTechnicianModel extends SearchTechnicianEntity {
  SearchTechnicianModel({
    required super.providerId,
    required super.providerName,
    super.avatarUrl,
    required super.providerProfileId,
    required super.providerServiceId,
    required super.experienceYears,
    required super.serviceCategoryName,
    required super.servicePrice,
    super.rating,
    required super.totalJobs,
    required super.isTopRated,
    required super.distanceKm,
    required super.distanceTag,
  });

  factory SearchTechnicianModel.fromJson(Map<String, dynamic> json) {
    return SearchTechnicianModel(
      providerId: json['providerId'] ?? '',
      providerName: json['providerName'] ?? '',
      avatarUrl: json['avatarUrl'],
      providerProfileId: json['providerProfileId'] ?? '',
      providerServiceId: json['providerServiceId'] ?? '',
      experienceYears: json['experienceYears'] is int
          ? json['experienceYears'] as int
          : (double.tryParse(json['experienceYears']?.toString() ?? '')?.toInt() ?? 0),
      serviceCategoryName: json['serviceCategoryName'] ?? '',
      servicePrice: json['servicePrice']?.toString() ?? '0.00',
      rating: (json['rating'] as num?)?.toDouble(),
      totalJobs: json['totalJobs'] is int
          ? json['totalJobs'] as int
          : (double.tryParse(json['totalJobs']?.toString() ?? '')?.toInt() ?? 0),
      isTopRated: json['isTopRated'] ?? false,
      distanceKm: json['distanceKm']?.toString() ?? '0.00',
      distanceTag: json['distanceTag'] ?? '',
    );
  }
}

