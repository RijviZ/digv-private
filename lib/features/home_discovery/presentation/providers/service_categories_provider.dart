import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/models/service_category_model.dart';
import '../../domain/entities/service_category_entity.dart';

final serviceCategoriesProvider = FutureProvider<List<ServiceCategoryEntity>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/service-categories?isActive=true');

  if (response.statusCode == 200) {
    final data = response.data['data']['items'] as List;
    return data.map((json) => ServiceCategoryModel.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load service categories');
  }
});

