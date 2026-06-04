class SearchProviderEntity {
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final String userProfileId;
  final String? bio;
  final bool isAvailableNow;
  final String basePrice;
  final String currency;
  final String verificationStatus;
  final String addressLine;
  final String city;
  final String distanceKm;
  final List<SearchServiceEntity> services;
  final String? averageRating;
  final int? reviewCount;
  final int? completedServiceRequestCount;
  final double? providerLat;
  final double? providerLng;

  SearchProviderEntity({
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    required this.userProfileId,
    this.bio,
    required this.isAvailableNow,
    required this.basePrice,
    required this.currency,
    required this.verificationStatus,
    required this.addressLine,
    required this.city,
    required this.distanceKm,
    required this.services,
    this.averageRating,
    this.reviewCount,
    this.completedServiceRequestCount,
    this.providerLat,
    this.providerLng,
  });
}

class SearchServiceEntity {
  final bool isActive;
  final String categoryId;
  final String categoryName;
  final num priceOverride;
  final String serviceType;
  final int experienceYears;
  final String title;
  final String serviceId;
  final String? categoryIconUrl;
  final String? serviceImageUrl;
  final int? durationMinutes;
  final List<String>? serviceFeatures;
  final String? serviceDescription;
  final List<String>? serviceItems;

  SearchServiceEntity({
    required this.isActive,
    required this.categoryId,
    required this.categoryName,
    required this.priceOverride,
    required this.serviceType,
    required this.experienceYears,
    required this.title,
    required this.serviceId,
    this.categoryIconUrl,
    this.serviceImageUrl,
    this.durationMinutes,
    this.serviceFeatures,
    this.serviceDescription,
    this.serviceItems,
  });
}

class SearchResponseEntity {
  final List<SearchProviderEntity> providers;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final String? searchText;
  final Map<String, dynamic>? userLocation;

  SearchResponseEntity({
    required this.providers,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    this.searchText,
    this.userLocation,
  });
}
