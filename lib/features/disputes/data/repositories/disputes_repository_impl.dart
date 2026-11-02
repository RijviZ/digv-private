import '../../domain/entities/dispute_entity.dart';
import '../../domain/repositories/disputes_repository.dart';
import '../sources/disputes_remote_data_source.dart';

class DisputesRepositoryImpl implements DisputesRepository {
  final DisputesRemoteDataSource remoteDataSource;

  DisputesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DisputeEntity> createDispute({
    required String serviceRequestId,
    required double amountInDispute,
    required String reason,
  }) {
    return remoteDataSource.createDispute(
      serviceRequestId: serviceRequestId,
      amountInDispute: amountInDispute,
      reason: reason,
    );
  }

  @override
  Future<List<DisputeEntity>> getMyDisputes({
    String? serviceRequestId,
    String? status,
    int? page,
    int? limit,
    String? q,
    String? createdByUserType,
  }) {
    return remoteDataSource.getMyDisputes(
      serviceRequestId: serviceRequestId,
      status: status,
      page: page,
      limit: limit,
      q: q,
      createdByUserType: createdByUserType,
    );
  }
}
