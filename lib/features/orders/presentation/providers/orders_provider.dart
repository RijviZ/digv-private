import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/repositories/orders_repository_impl.dart';
import '../../data/sources/orders_remote_data_source.dart';
import '../../domain/models/order_item.dart';
import '../../domain/models/order_tracking_data.dart';
import '../../domain/repositories/orders_repository.dart';

final ordersRemoteDataSourceProvider = Provider<OrdersRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return OrdersRemoteDataSourceImpl(dio: dio);
});

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  final dataSource = ref.watch(ordersRemoteDataSourceProvider);
  return OrdersRepositoryImpl(remoteDataSource: dataSource);
});

final ordersProvider = AsyncNotifierProvider.family<OrdersNotifier, List<OrderItem>, String?>((arg) {
  return OrdersNotifier(arg);
});

class OrdersNotifier extends AsyncNotifier<List<OrderItem>> {
  final String? statusStr;
  OrdersNotifier(this.statusStr);

  @override
  Future<List<OrderItem>> build() async {
    final repository = ref.watch(ordersRepositoryProvider);
    return await repository.getServiceRequests(status: statusStr);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(ordersRepositoryProvider);
      final list = await repository.getServiceRequests(status: statusStr);
      state = AsyncValue.data(list);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> rescheduleServiceRequest({
    required String id,
    required String scheduledDate,
    required List<String> availabilitySlotIds,
  }) async {
    final repository = ref.read(ordersRepositoryProvider);
    await repository.rescheduleServiceRequest(
      id: id,
      scheduledDate: scheduledDate,
      availabilitySlotIds: availabilitySlotIds,
    );
  }

  Future<void> cancelServiceRequest({
    required String id,
    required String reason,
  }) async {
    final repository = ref.read(ordersRepositoryProvider);
    await repository.cancelServiceRequest(
      id: id,
      reason: reason,
    );
  }
}


final orderTrackingProvider = FutureProvider.autoDispose.family<OrderTrackingData, String>((ref, id) async {
  final repository = ref.watch(ordersRepositoryProvider);
  return await repository.getOrderTracking(id: id);
});
