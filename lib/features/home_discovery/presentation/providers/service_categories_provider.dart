import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/models/service_category_model.dart';
import '../../domain/entities/service_category_entity.dart';

final serviceCategoriesProvider = FutureProvider<List<ServiceCategoryEntity>>((
  ref,
) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/service-categories');

  if (response.statusCode == 200) {
    final dataList = response.data['data']['dataList'] as List;

    // Filter to only include categories where totalItemsCount >= 1
    final filteredList = dataList.where((item) {
      final map = item as Map<String, dynamic>;
      final totalItemsCount = map['totalItemsCount'] ?? 0;
      return totalItemsCount >= 1;
    }).toList();

    // Fetch detailed categories to get service types and items
    final detailFutures = filteredList.map((item) async {
      final categoryId = (item as Map<String, dynamic>)['categoryId'];
      try {
        final detailResponse = await dio.get('/service-categories/$categoryId');
        if (detailResponse.statusCode == 200) {
          final detailData = detailResponse.data['data'];
          return ServiceCategoryModel.fromJson(detailData);
        }
      } catch (e) {
        // Fallback to list item if detail fetch fails
      }
      return ServiceCategoryModel.fromJson(item);
    }).toList();

    return await Future.wait(detailFutures);
  } else {
    throw Exception('Failed to load service categories');
  }
});
