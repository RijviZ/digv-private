import 'package:digv/features/home_discovery/domain/entities/service_category_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Service Type Selection and Inclusions Test', () {
    final plumbingCategory = ServiceCategoryEntity(
      categoryId: '60ad4ef3-a0a3-43ff-a2a3-1464e95bef51',
      name: 'Plumbing Service',
      iconUrl: 'https://cdn.example.com/plumbing.svg',
      isActive: true,
      serviceTypes: [
        CategoryTypeEntity(
          serviceTypeId: 'ebcdd38c-0144-42b2-8c20-8432ec6683c7',
          name: 'Wash Basin',
          isActive: true,
          items: [
            CategoryItemEntity(
              serviceItemId: '8d338b7e-7bac-415d-b928-c3860657bb4c',
              name: 'Regular Service',
              basePrice: '400.00',
              features: ['Filter cleaning', 'Cooling test', 'Gas pressure check'],
            ),
          ],
        ),
        CategoryTypeEntity(
          serviceTypeId: '8496a303-6eb4-4934-85f0-bac1b9d21202',
          name: 'Toilet & Commode',
          isActive: true,
          items: [
            CategoryItemEntity(
              serviceItemId: '1b72e8df-19d7-4263-a495-3e613548f490',
              name: 'Regular Service',
              basePrice: '500.00',
              features: ['Cleaning', 'Cooling test', 'Dry wash'],
            ),
          ],
        ),
        CategoryTypeEntity(
          serviceTypeId: '62c2bd84-eae3-47fd-ad21-937edf91f8c8',
          name: 'Water Line',
          isActive: true,
          items: [
            CategoryItemEntity(
              serviceItemId: '012a87e3-9560-49e5-ade0-565e3558e2d0',
              name: 'Regular Service',
              basePrice: '500.00',
              features: ['Filter cleaning'],
            ),
          ],
        ),
      ],
    );

    CategoryItemEntity? findItemForType(
      String typeName,
      String currentItemName,
      ServiceCategoryEntity category,
    ) {
      final typeLower = typeName.toLowerCase().trim();
      CategoryTypeEntity? targetType;
      for (final t in category.serviceTypes) {
        if (t.name.toLowerCase().trim() == typeLower) {
          targetType = t;
          break;
        }
      }

      if (targetType == null || targetType.items.isEmpty) return null;

      final currentItemLower = currentItemName.toLowerCase().trim();
      for (final item in targetType.items) {
        if (item.name.toLowerCase().trim() == currentItemLower) {
          return item;
        }
      }

      for (final item in targetType.items) {
        final nameLower = item.name.toLowerCase().trim();
        if (nameLower.contains(currentItemLower) || currentItemLower.contains(nameLower)) {
          return item;
        }
      }

      return targetType.items.first;
    }

    test('Selecting Toilet & Commode changes included items to Cleaning, Cooling test, Dry wash and price to 500', () {
      final item = findItemForType('Toilet & Commode', 'Regular Service', plumbingCategory);

      expect(item, isNotNull);
      expect(item!.serviceItemId, '1b72e8df-19d7-4263-a495-3e613548f490');
      expect(item.basePrice, '500.00');
      expect(item.features, ['Cleaning', 'Cooling test', 'Dry wash']);
    });

    test('Selecting Water Line changes included items to Filter cleaning and price to 500', () {
      final item = findItemForType('Water Line', 'Regular Service', plumbingCategory);

      expect(item, isNotNull);
      expect(item!.serviceItemId, '012a87e3-9560-49e5-ade0-565e3558e2d0');
      expect(item.basePrice, '500.00');
      expect(item.features, ['Filter cleaning']);
    });

    test('Selecting Wash Basin changes included items to Filter cleaning, Cooling test, Gas pressure check and price to 400', () {
      final item = findItemForType('Wash Basin', 'Regular Service', plumbingCategory);

      expect(item, isNotNull);
      expect(item!.serviceItemId, '8d338b7e-7bac-415d-b928-c3860657bb4c');
      expect(item.basePrice, '400.00');
      expect(item.features, ['Filter cleaning', 'Cooling test', 'Gas pressure check']);
    });
  });
}
