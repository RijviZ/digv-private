abstract class BookingRepository {
  Future<Map<String, dynamic>> createServiceRequest(Map<String, dynamic> payload);
  Future<List<Map<String, dynamic>>> getAvailableSlots(String providerId, String scheduledDate);
  Future<List<Map<String, dynamic>>> getProviderAvailabilityDates(String providerId);
}
