import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../data/repositories/disputes_repository_impl.dart';
import '../../data/sources/disputes_remote_data_source.dart';
import '../../domain/entities/dispute_entity.dart';
import '../../domain/repositories/disputes_repository.dart';

final disputesRemoteDataSourceProvider =
    Provider<DisputesRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return DisputesRemoteDataSourceImpl(dio: dio);
});

final disputesRepositoryProvider = Provider<DisputesRepository>((ref) {
  final remoteDataSource = ref.watch(disputesRemoteDataSourceProvider);
  return DisputesRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Watch disputes specifically linked to a service request ID
final disputesForOrderProvider =
    FutureProvider.family<List<DisputeEntity>, String>(
        (ref, serviceRequestId) async {
  if (serviceRequestId.isEmpty) return [];
  final repo = ref.watch(disputesRepositoryProvider);
  return repo.getMyDisputes(serviceRequestId: serviceRequestId);
});

// Watch all user disputes
final myDisputesProvider = FutureProvider<List<DisputeEntity>>((ref) async {
  final repo = ref.watch(disputesRepositoryProvider);
  return repo.getMyDisputes();
});

// Watch disputes filtered by status (null for All)
final myDisputesFilteredProvider =
    FutureProvider.family<List<DisputeEntity>, String?>((ref, status) async {
  final repo = ref.watch(disputesRepositoryProvider);
  return repo.getMyDisputes(status: status);
});

// Fast lookup map from serviceRequestId and serviceRequestNumber to DisputeEntity
final disputesMapProvider = Provider<Map<String, DisputeEntity>>((ref) {
  final disputesAsync = ref.watch(myDisputesProvider);
  final map = <String, DisputeEntity>{};
  final list = disputesAsync.value ?? [];
  for (final d in list) {
    if (d.serviceRequestId.isNotEmpty) {
      map[d.serviceRequestId] = d;
    }
    if (d.serviceRequestNumber != null && d.serviceRequestNumber!.isNotEmpty) {
      map[d.serviceRequestNumber!] = d;
    }
  }
  return map;
});

class DisputeNotifier extends Notifier<AsyncValue<DisputeEntity?>> {
  @override
  AsyncValue<DisputeEntity?> build() => const AsyncValue.data(null);

  Future<DisputeEntity> submitDispute({
    required String serviceRequestId,
    required double amountInDispute,
    required String reason,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(disputesRepositoryProvider);
      final dispute = await repo.createDispute(
        serviceRequestId: serviceRequestId,
        amountInDispute: amountInDispute,
        reason: reason,
      );
      ref.invalidate(disputesForOrderProvider(serviceRequestId));
      ref.invalidate(myDisputesProvider);
      state = AsyncValue.data(dispute);
      return dispute;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final disputeNotifierProvider =
    NotifierProvider<DisputeNotifier, AsyncValue<DisputeEntity?>>(
  DisputeNotifier.new,
);
