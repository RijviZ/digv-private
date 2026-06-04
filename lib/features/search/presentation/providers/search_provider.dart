import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../domain/entities/search_result.dart';

class SearchFilters {
  final String? q;
  final String? categoryId;
  final String? serviceType;
  final bool? isAvailableNow;
  final int page;
  final int limit;

  const SearchFilters({
    this.q,
    this.categoryId,
    this.serviceType,
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
          serviceType == other.serviceType &&
          isAvailableNow == other.isAvailableNow &&
          page == other.page &&
          limit == other.limit;

  @override
  int get hashCode =>
      q.hashCode ^
      categoryId.hashCode ^
      serviceType.hashCode ^
      isAvailableNow.hashCode ^
      page.hashCode ^
      limit.hashCode;
}


final searchResultsProvider = FutureProvider.family<SearchResponseEntity, SearchFilters>((ref, filters) async {
  final repository = ref.watch(searchRepositoryProvider);
  return await repository.globalSearch(
    q: filters.q,
    categoryId: filters.categoryId,
    serviceType: filters.serviceType,
    isAvailableNow: filters.isAvailableNow,
    page: filters.page,
    limit: filters.limit,
  );
});
