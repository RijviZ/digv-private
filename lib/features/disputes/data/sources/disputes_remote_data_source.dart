import 'package:dio/dio.dart';
import '../../../../core/network/failure.dart';
import '../../domain/entities/dispute_entity.dart';

abstract class DisputesRemoteDataSource {
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

class DisputesRemoteDataSourceImpl implements DisputesRemoteDataSource {
  final Dio _dio;

  DisputesRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<DisputeEntity> createDispute({
    required String serviceRequestId,
    required double amountInDispute,
    required String reason,
  }) async {
    try {
      final payload = {
        'serviceRequestId': serviceRequestId,
        'amountInDispute': amountInDispute,
        'reason': reason,
      };

      final response = await _dio.post('/disputes', data: payload);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['data'] is Map<String, dynamic>) {
          return DisputeEntity.fromJson(data['data'] as Map<String, dynamic>);
        }
        return DisputeEntity.fromJson(data);
      }
      throw Failure('Invalid dispute creation response');
    } on DioException catch (e) {
      throw Failure.fromDioException(e, 'Failed to submit dispute');
    }
  }

  @override
  Future<List<DisputeEntity>> getMyDisputes({
    String? serviceRequestId,
    String? status,
    int? page,
    int? limit,
    String? q,
    String? createdByUserType,
  }) async {
    try {
      final query = <String, dynamic>{};
      if (serviceRequestId != null && serviceRequestId.isNotEmpty) {
        query['serviceRequestId'] = serviceRequestId;
      }
      if (status != null && status.isNotEmpty) {
        query['status'] = status;
      }
      if (page != null) query['page'] = page;
      if (limit != null) query['limit'] = limit;
      if (q != null && q.isNotEmpty) query['q'] = q;
      if (createdByUserType != null && createdByUserType.isNotEmpty) {
        query['createdByUserType'] = createdByUserType;
      }

      final response = await _dio.get('/disputes/my', queryParameters: query);
      final data = response.data;
      List? items;
      if (data is List) {
        items = data;
      } else if (data is Map<String, dynamic>) {
        if (data['data'] is List) {
          items = data['data'] as List;
        } else if (data['data'] is Map<String, dynamic>) {
          final inner = data['data'] as Map<String, dynamic>;
          if (inner['data'] is List) {
            items = inner['data'] as List;
          } else if (inner['items'] is List) {
            items = inner['items'] as List;
          } else if (inner['disputes'] is List) {
            items = inner['disputes'] as List;
          } else if (inner['results'] is List) {
            items = inner['results'] as List;
          } else if (inner['rows'] is List) {
            items = inner['rows'] as List;
          }
        } else if (data['items'] is List) {
          items = data['items'] as List;
        } else if (data['disputes'] is List) {
          items = data['disputes'] as List;
        } else if (data['results'] is List) {
          items = data['results'] as List;
        }
      }

      if (items != null) {
        return items
            .whereType<Map<String, dynamic>>()
            .map((item) => DisputeEntity.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw Failure.fromDioException(e, 'Failed to fetch disputes');
    } catch (_) {
      return [];
    }
  }
}
