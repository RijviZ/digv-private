import 'package:dio/dio.dart';
import '../models/search_result_model.dart';

abstract class SearchRemoteDataSource {
  Future<SearchResponseModel> globalSearch({
    String? q,
    String? categoryId,
    String? serviceType,
    bool? isAvailableNow,
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
    String? serviceType,
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
          if (serviceType != null) 'serviceType': serviceType,
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
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }
}
