import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/dio_provider.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../data/sources/booking_remote_data_source.dart';
import '../../domain/repositories/booking_repository.dart';

final bookingRemoteDataSourceProvider = Provider<BookingRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return BookingRemoteDataSourceImpl(dio: dio);
});

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final dataSource = ref.watch(bookingRemoteDataSourceProvider);
  return BookingRepositoryImpl(remoteDataSource: dataSource);
});

final createBookingProvider = StateNotifierProvider<CreateBookingNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  return CreateBookingNotifier(repository: repository);
});

final availableSlotsProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>((ref, arg) async {
  final repository = ref.watch(bookingRepositoryProvider);
  final parts = arg.split('|');
  final providerId = parts[0];
  final scheduledDate = parts.length > 1 ? parts[1] : '';
  return await repository.getAvailableSlots(providerId, scheduledDate);
});

final providerAvailabilityDatesProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>((ref, providerId) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return await repository.getProviderAvailabilityDates(providerId);
});

class CreateBookingNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final BookingRepository _repository;

  CreateBookingNotifier({required BookingRepository repository})
      : _repository = repository,
        super(const AsyncValue.data({}));

  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> payload) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.createServiceRequest(payload);
      state = AsyncValue.data(result);
      return result;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}
