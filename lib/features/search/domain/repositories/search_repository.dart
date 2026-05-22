import '../entities/search_result.dart';

abstract class SearchRepository {
  Future<SearchResponseEntity> globalSearch({
    String? q,
    String? categoryId,
    String? serviceType,
    bool? isAvailableNow,
    int page = 1,
    int limit = 10,
  });
}
