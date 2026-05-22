import '../../domain/repositories/booking_repository.dart';
import '../sources/booking_remote_data_source.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Map<String, dynamic>> createServiceRequest(Map<String, dynamic> payload) async {
    return await remoteDataSource.createServiceRequest(payload);
  }

  @override
  Future<List<Map<String, dynamic>>> getAvailableSlots(String providerId, String scheduledDate) async {
    return await remoteDataSource.getAvailableSlots(providerId, scheduledDate);
  }
}
