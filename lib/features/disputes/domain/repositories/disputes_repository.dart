import '../entities/dispute_entity.dart';

abstract class DisputesRepository {
  Future<DisputeEntity> createDispute({
    required String serviceRequestId,
    required double amountInDispute,
    required String reason,
  });

  Future<List<DisputeEntity>> getMyDisputes({
    String? serviceRequestId,
    String? status,
    int? page,
    int? limit,
    String? q,
    String? createdByUserType,
  });
}
