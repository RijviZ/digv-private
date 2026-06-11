import 'package:dio/dio.dart';
import '../models/search_result_model.dart';

abstract class SearchRemoteDataSource {
  Future<SearchResponseModel> globalSearch({
    String? q,
    String? categoryId,
    String? serviceTypeId,
    bool? isAvailableNow,
    int page = 1,
    int limit = 10,
  });

  Future<ServiceDetailsModel> getServiceDetails(String serviceItemId);

  Future<List<SearchTechnicianModel>> getServiceProviders(
    String serviceItemId, {
    String filterType = 'ALL',
    int page = 1,
    int limit = 10,
  });
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final Dio _dio;

  SearchRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<SearchResponseModel> globalSearch({
    String? q,
    String? categoryId,
    String? serviceTypeId,
    bool? isAvailableNow,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/search/global',
        queryParameters: {
          if (q != null) 'q': q,
          if (categoryId != null) 'categoryId': categoryId,
          if (serviceTypeId != null) 'serviceTypeId': serviceTypeId,
          if (isAvailableNow != null) 'isAvailableNow': isAvailableNow,
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        return SearchResponseModel.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch search results');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return SearchResponseModel(
          services: [],
          total: 0,
          page: page,
          limit: limit,
          totalPages: 0,
        );
      }
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  @override
  Future<ServiceDetailsModel> getServiceDetails(String serviceItemId) async {
    try {
      final response = await _dio.get(
        '/search/service-details',
        queryParameters: {
          'serviceItemId': serviceItemId,
        },
      );
      if (response.statusCode == 200) {
        return ServiceDetailsModel.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch service details');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  @override
  Future<List<SearchTechnicianModel>> getServiceProviders(
    String serviceItemId, {
    String filterType = 'ALL',
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/search/providers',
        queryParameters: {
          'serviceItemId': serviceItemId,
          'filterType': filterType,
          'page': page,
          'limit': limit,
        },
      );
      if (response.statusCode == 200) {
        final data = response.data['data'];
        final list = data['technicians'] as List<dynamic>?;
        return list?.map((e) => SearchTechnicianModel.fromJson(e as Map<String, dynamic>)).toList() ?? [];
      } else {
        throw Exception('Failed to fetch service providers');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }
}
