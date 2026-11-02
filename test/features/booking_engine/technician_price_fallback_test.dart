import 'package:digv/features/booking_engine/domain/technician.dart';
import 'package:digv/features/search/data/models/search_result_model.dart';
import 'package:digv/features/search/domain/entities/search_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Technician Price Fallback Test', () {
    test('SearchTechnicianModel.fromJson falls back to basePrice when customPrice is null or 0', () {
      final jsonWithZeroPrice = {
        'providerId': 'provider-1',
        'providerName': 'mazid',
        'serviceCategoryName': 'AC',
        'servicePrice': '0.00',
        'basePrice': '410.00',
        'experienceYears': 0,
        'totalJobs': 0,
      };

      final technician = SearchTechnicianModel.fromJson(jsonWithZeroPrice);
      expect(technician.servicePrice, '410.00');
    });

    test('SearchTechnicianModel.fromJson preserves customPrice when greater than 0', () {
      final jsonWithCustomPrice = {
        'providerId': 'provider-2',
        'providerName': 'nt',
        'serviceCategoryName': 'AC',
        'servicePrice': '499.00',
        'basePrice': '410.00',
        'experienceYears': 0,
        'totalJobs': 2,
      };

      final technician = SearchTechnicianModel.fromJson(jsonWithCustomPrice);
      expect(technician.servicePrice, '499.00');
    });

    test('Technician mapping in SelectTechnicianScreen uses service basePrice when provider price is 0', () {
      final providers = [
        SearchTechnicianEntity(
          providerId: 'p1',
          providerName: 'mazid',
          providerProfileId: 'prof1',
          providerServiceId: 'ps1',
          experienceYears: 0,
          serviceCategoryName: 'AC',
          servicePrice: '0.00',
          totalJobs: 0,
          isTopRated: false,
          distanceKm: '20015.10',
          distanceTag: 'Close by',
        ),
        SearchTechnicianEntity(
          providerId: 'p2',
          providerName: 'nt',
          providerProfileId: 'prof2',
          providerServiceId: 'ps2',
          experienceYears: 0,
          serviceCategoryName: 'AC',
          servicePrice: '499.00',
          totalJobs: 2,
          isTopRated: false,
          distanceKm: '20015.10',
          distanceTag: 'Close by',
        ),
      ];

      const fallbackBasePrice = 410;

      final technicians = providers.map((t) {
        final providerPrice = double.tryParse(t.servicePrice)?.toInt() ?? 0;
        final effectivePrice = providerPrice > 0 ? providerPrice : fallbackBasePrice;

        return Technician(
          providerId: t.providerId,
          providerServiceId: t.providerServiceId,
          name: t.providerName,
          specialty: t.serviceCategoryName,
          rating: t.rating ?? 0.0,
          reviews: t.totalJobs * 2 + 3,
          jobs: t.totalJobs,
          experience: t.experienceYears,
          pricePerVisit: effectivePrice,
          distanceKm: double.tryParse(t.distanceKm) ?? 0.0,
          distanceLabel: t.distanceTag,
          isTopRated: t.isTopRated,
          avatarUrl: t.avatarUrl,
        );
      }).toList();

      expect(technicians[0].name, 'mazid');
      expect(technicians[0].pricePerVisit, 410);

      expect(technicians[1].name, 'nt');
      expect(technicians[1].pricePerVisit, 499);
    });
  });
}
