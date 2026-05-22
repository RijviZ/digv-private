import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_data_source.dart';

final searchRemoteDataSourceProvider = Provider<SearchRemoteDataSource>((ref) {
  return SearchRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepositoryImpl(
    remoteDataSource: ref.watch(searchRemoteDataSourceProvider),
  );
});

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  SearchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<SearchResponseEntity> globalSearch({
    String? q,
    String? categoryId,
    String? serviceType,
    bool? isAvailableNow,
    int page = 1,
    int limit = 10,
  }) async {
    return await remoteDataSource.globalSearch(
      q: q,
      categoryId: categoryId,
      serviceType: serviceType,
      isAvailableNow: isAvailableNow,
      page: page,
      limit: limit,
    );
  }
}
