import 'package:digv/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:digv/features/orders/data/sources/orders_remote_data_source.dart';
import 'package:digv/features/orders/domain/models/order_item.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeOrdersRemoteDataSource implements OrdersRemoteDataSource {
  final Map<String, dynamic> mockDetail;
  FakeOrdersRemoteDataSource({this.mockDetail = const {}});

  @override
  Future<List<Map<String, dynamic>>> getServiceRequests({String? status, int page = 1, int limit = 100}) async => [];

  @override
  Future<Map<String, dynamic>> cancelServiceRequest({required String id, required String reason}) async => {};

  @override
  Future<Map<String, dynamic>?> getGivenReviewByServiceRequestId({required String serviceRequestId}) async => null;

  @override
  Future<Map<String, dynamic>> getOrderTracking({required String id}) async => {'data': {'serviceRequestId': id, 'logs': []}};

  @override
  Future<Map<String, dynamic>> rescheduleServiceRequest({required String id, required String scheduledDate, required List<String> availabilitySlotIds}) async => {};

  @override
  Future<Map<String, dynamic>> submitReview({required String serviceRequestId, required String targetType, required int rating, required String comment, required List<String> tags, required List<String> photos}) async => {};

  @override
  Future<Map<String, dynamic>> updateReview({required String id, required int rating, required String comment, required List<String> tags, required List<String> photos}) async => {};

  @override
  Future<Map<String, dynamic>> getServiceRequestById(String id) async => mockDetail;
}

void main() {
  group('OrdersRepositoryImpl and OrderItem Rebooking tests', () {
    test('Correctly maps cancellationReason, description, and derives serviceName', () {
      final fakeRemote = FakeOrdersRemoteDataSource();
      final repository = OrdersRepositoryImpl(remoteDataSource: fakeRemote);

      final rawOrderMap = {
        "serviceRequestId": "7a938c96-013d-4be0-b0d4-22dbae3878c2",
        "customerId": "908f394c-1fce-47ee-a98f-3d003152eed4",
        "providerId": "095879a2-49d5-45f7-81e2-9c141746e6fa",
        "providerServiceId": "a485c9ba-1145-4cef-8c11-de441e8543b9",
        "quantity": 1,
        "unitPrice": 500,
        "subtotalAmount": 500,
        "currency": "INR",
        "description": "Need AC servicing for bedroom AC.",
        "status": "CANCELLED",
        "cancellationReason": "Technician is delayed / not responding",
        "serviceRequestNumber": "SBR515767"
      };

      final orderItem = repository.mapToOrderItem(rawOrderMap);

      expect(orderItem.id, equals("7a938c96-013d-4be0-b0d4-22dbae3878c2"));
      expect(orderItem.providerServiceId, equals("a485c9ba-1145-4cef-8c11-de441e8543b9"));
      expect(orderItem.cancelReason, equals("Technician is delayed / not responding"));
      expect(orderItem.description, equals("Need AC servicing for bedroom AC."));
      expect(orderItem.serviceName, equals("AC servicing"));
      expect(orderItem.status, equals(OrderBadgeStatus.cancelled));
    });

    test('Correctly calls getServiceRequestById', () async {
      final fakeRemote = FakeOrdersRemoteDataSource(mockDetail: {
        'serviceRequestId': '123',
        'serviceItemId': 'item-abc',
      });
      final repository = OrdersRepositoryImpl(remoteDataSource: fakeRemote);

      final detail = await repository.getServiceRequestById(id: '123');
      expect(detail['serviceItemId'], equals('item-abc'));
    });
  });
}
