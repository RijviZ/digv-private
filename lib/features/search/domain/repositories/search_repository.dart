import '../entities/search_result.dart';

abstract class SearchRepository {
  Future<SearchResponseEntity> globalSearch({
    String? q,
    String? categoryId,
    String? serviceTypeId,
    bool? isAvailableNow,
    int page = 1,
    int limit = 10,
  });

  Future<ServiceDetailsEntity> getServiceDetails(String serviceItemId);

  Future<List<SearchTechnicianEntity>> getServiceProviders(
    String serviceItemId, {
    String filterType = 'ALL',
    int page = 1,
    int limit = 10,
  });
}
