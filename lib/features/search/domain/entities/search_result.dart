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

class SearchServiceItemEntity {
  final String serviceItemId;
  final String serviceItemName;
  final String? serviceItemDescription;
  final int? durationMinutes;
  final String basePrice;
  final String? serviceItemImageUrl;
  final String? serviceTypeId;
  final String? serviceTypeName;
  final String? serviceCategoryId;
  final String? serviceCategoryName;
  final String startingPrice;
  final int availableProvidersCount;
  final String nearestProviderDistanceKm;
  final double? rating;
  final int totalBookings;

  SearchServiceItemEntity({
    required this.serviceItemId,
    required this.serviceItemName,
    this.serviceItemDescription,
    this.durationMinutes,
    required this.basePrice,
    this.serviceItemImageUrl,
    this.serviceTypeId,
    this.serviceTypeName,
    this.serviceCategoryId,
    this.serviceCategoryName,
    required this.startingPrice,
    required this.availableProvidersCount,
    required this.nearestProviderDistanceKm,
    this.rating,
    required this.totalBookings,
  });
}

class SearchResponseEntity {
  final List<SearchServiceItemEntity> services;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final String? searchText;
  final Map<String, dynamic>? userLocation;

  SearchResponseEntity({
    required this.services,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    this.searchText,
    this.userLocation,
  });
}

extension SearchServiceItemMapping on SearchServiceItemEntity {
  SearchServiceEntity toSearchServiceEntity() {
    return SearchServiceEntity(
      isActive: true,
      categoryId: serviceCategoryId ?? '',
      categoryName: serviceCategoryName ?? '',
      priceOverride: double.tryParse(startingPrice) ?? (double.tryParse(basePrice) ?? 0.0),
      serviceType: serviceTypeName ?? '',
      experienceYears: 5,
      title: serviceItemName,
      serviceId: serviceItemId,
      serviceImageUrl: serviceItemImageUrl,
      durationMinutes: durationMinutes,
      serviceDescription: serviceItemDescription,
    );
  }

  List<SearchProviderEntity> toMockProviders() {
    final count = availableProvidersCount > 0 ? availableProvidersCount : 1;
    final service = toSearchServiceEntity();
    
    final firstNames = ['Amit', 'Rahul', 'Priyo', 'Sujon', 'Anis'];
    final lastNames = ['Sharma', 'Khan', 'Rahman', 'Dutta', 'Ahmed'];

    return List.generate(count, (index) {
      final fName = firstNames[index % firstNames.length];
      final lName = lastNames[(index + 1) % lastNames.length];
      
      return SearchProviderEntity(
        userId: 'mock-provider-id-$serviceItemId-$index',
        fullName: '$fName $lName',
        avatarUrl: 'https://i.pravatar.cc/150?img=${(index + 7) * 3}',
        userProfileId: 'mock-profile-id-$serviceItemId-$index',
        bio: 'Professional technician specializing in ${serviceCategoryName ?? 'services'}. Quick and reliable service.',
        isAvailableNow: true,
        basePrice: basePrice,
        currency: 'BDT',
        verificationStatus: 'verified',
        addressLine: 'Road ${index + 2}, Block C',
        city: 'Dhaka',
        distanceKm: index == 0 ? nearestProviderDistanceKm : '${(double.tryParse(nearestProviderDistanceKm) ?? 1.5) + (index * 1.2)}',
        services: [service],
        averageRating: rating?.toString() ?? '4.5',
        reviewCount: (totalBookings * 2) + 3 + index,
        completedServiceRequestCount: totalBookings + index,
        providerLat: 23.8103 + (index * 0.01),
        providerLng: 90.4125 + (index * 0.01),
      );
    });
  }
}

class SelectableTypeEntity {
  final String serviceTypeId;
  final String name;
  final bool isActive;

  SelectableTypeEntity({
    required this.serviceTypeId,
    required this.name,
    required this.isActive,
  });
}

class ServiceDetailsEntity {
  final String serviceItemId;
  final String serviceItemName;
  final String? serviceItemDescription;
  final int? durationMinutes;
  final String basePrice;
  final String? serviceItemImageUrl;
  final String? serviceTypeId;
  final String? serviceCategoryId;
  final String? serviceCategoryName;
  final List<String> whatsIncluded;
  final double? rating;
  final int totalBookings;
  final String startingPrice;
  final String nearestProviderDistanceKm;
  final int totalAvailableProviders;
  final List<SelectableTypeEntity> selectableTypes;

  ServiceDetailsEntity({
    required this.serviceItemId,
    required this.serviceItemName,
    this.serviceItemDescription,
    this.durationMinutes,
    required this.basePrice,
    this.serviceItemImageUrl,
    this.serviceTypeId,
    this.serviceCategoryId,
    this.serviceCategoryName,
    required this.whatsIncluded,
    this.rating,
    required this.totalBookings,
    required this.startingPrice,
    required this.nearestProviderDistanceKm,
    required this.totalAvailableProviders,
    required this.selectableTypes,
  });
}

class SearchTechnicianEntity {
  final String providerId;
  final String providerName;
  final String? avatarUrl;
  final String providerProfileId;
  final String providerServiceId;
  final int experienceYears;
  final String serviceCategoryName;
  final String servicePrice;
  final double? rating;
  final int totalJobs;
  final bool isTopRated;
  final String distanceKm;
  final String distanceTag;

  SearchTechnicianEntity({
    required this.providerId,
    required this.providerName,
    this.avatarUrl,
    required this.providerProfileId,
    required this.providerServiceId,
    required this.experienceYears,
    required this.serviceCategoryName,
    required this.servicePrice,
    this.rating,
    required this.totalJobs,
    required this.isTopRated,
    required this.distanceKm,
    required this.distanceTag,
  });
}

extension ServiceDetailsMapping on ServiceDetailsEntity {
  SearchServiceEntity toSearchServiceEntity() {
    return SearchServiceEntity(
      isActive: true,
      categoryId: serviceCategoryId ?? '',
      categoryName: serviceCategoryName ?? '',
      priceOverride: double.tryParse(startingPrice) ?? (double.tryParse(basePrice) ?? 0.0),
      serviceType: serviceCategoryName ?? '',
      experienceYears: 5,
      title: serviceItemName,
      serviceId: serviceItemId,
      serviceImageUrl: serviceItemImageUrl,
      durationMinutes: durationMinutes,
      serviceDescription: serviceItemDescription,
      serviceFeatures: whatsIncluded,
    );
  }
}


