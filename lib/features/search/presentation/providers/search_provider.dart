import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../domain/entities/search_result.dart';

class SearchFilters {
  final String? q;
  final String? categoryId;
  final String? serviceTypeId;
  final bool? isAvailableNow;
  final int page;
  final int limit;

  const SearchFilters({
    this.q,
    this.categoryId,
    this.serviceTypeId,
    this.isAvailableNow,
    this.page = 1,
    this.limit = 10,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchFilters &&
          runtimeType == other.runtimeType &&
          q == other.q &&
          categoryId == other.categoryId &&
          serviceTypeId == other.serviceTypeId &&
          isAvailableNow == other.isAvailableNow &&
          page == other.page &&
          limit == other.limit;

  @override
  int get hashCode =>
      q.hashCode ^
      categoryId.hashCode ^
      serviceTypeId.hashCode ^
      isAvailableNow.hashCode ^
      page.hashCode ^
      limit.hashCode;
}


final searchResultsProvider = FutureProvider.family<SearchResponseEntity, SearchFilters>((ref, filters) async {
  final repository = ref.watch(searchRepositoryProvider);
  return await repository.globalSearch(
    q: filters.q,
    categoryId: filters.categoryId,
    serviceTypeId: filters.serviceTypeId,
    isAvailableNow: filters.isAvailableNow,
    page: filters.page,
    limit: filters.limit,
  );
});

final serviceDetailsProvider = FutureProvider.family<ServiceDetailsEntity, String>((ref, serviceItemId) async {
  final repository = ref.watch(searchRepositoryProvider);
  return await repository.getServiceDetails(serviceItemId);
});

class ProvidersFilters {
  final String serviceItemId;
  final String filterType;
  final int page;
  final int limit;

  const ProvidersFilters({
    required this.serviceItemId,
    this.filterType = 'ALL',
    this.page = 1,
    this.limit = 10,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProvidersFilters &&
          runtimeType == other.runtimeType &&
          serviceItemId == other.serviceItemId &&
          filterType == other.filterType &&
          page == other.page &&
          limit == other.limit;

  @override
  int get hashCode =>
      serviceItemId.hashCode ^
      filterType.hashCode ^
      page.hashCode ^
      limit.hashCode;
}

final serviceProvidersProvider = FutureProvider.family<List<SearchTechnicianEntity>, ProvidersFilters>((ref, filters) async {
  final repository = ref.watch(searchRepositoryProvider);
  return await repository.getServiceProviders(
    filters.serviceItemId,
    filterType: filters.filterType,
    page: filters.page,
    limit: filters.limit,
  );
});
