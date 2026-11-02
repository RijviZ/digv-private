import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/models/service_category_model.dart';
import '../../domain/entities/service_category_entity.dart';

final serviceCategoriesProvider = FutureProvider<List<ServiceCategoryEntity>>((
  ref,
) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get(
    '/service-categories',
    queryParameters: {'limit': 100},
  );

  if (response.statusCode == 200) {
    final dynamic rawData = response.data['data'];
    final List dataList;
    if (rawData is List) {
      dataList = rawData;
    } else if (rawData is Map && rawData['dataList'] is List) {
      dataList = rawData['dataList'] as List;
    } else {
      dataList = [];
    }

    // Filter to only include active categories (and totalItemsCount >= 1 if provided)
    final filteredList = dataList.where((item) {
      final map = item as Map<String, dynamic>;
      final isActive = map['isActive'] ?? true;
      if (!isActive) return false;
      if (map.containsKey('totalItemsCount') && map['totalItemsCount'] != null) {
        return (map['totalItemsCount'] as num) >= 1;
      }
      return true;
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

    final categories = await Future.wait(detailFutures);
    final activeCategories = categories.where((cat) => cat.isActive).toList();
    activeCategories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return activeCategories;
  } else {
    throw Exception('Failed to load service categories');
  }
});

