import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/saved_upi.dart';

class UpiNotifier extends Notifier<List<SavedUpi>> {
  @override
  List<SavedUpi> build() {
    return const [
      SavedUpi(
        id: 'upi_1',
        name: 'Google Pay',
        upiId: 'rahul@okaxis',
        emoji: '🪙',
        isDefault: true,
      ),
    ];
  }

  void addUpi({
    required String name,
    required String upiId,
    bool isDefault = false,
  }) {
    String emoji = '🪙';
    final lowerName = name.toLowerCase();
    if (lowerName.contains('google')) {
      emoji = '🪙';
    } else if (lowerName.contains('phonepe')) {
      emoji = '🟣';
    } else if (lowerName.contains('paytm')) {
      emoji = '🔷';
    } else if (lowerName.contains('bhim')) {
      emoji = '🇮🇳';
    }

    final newUpi = SavedUpi(
      id: 'upi_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      upiId: upiId,
      emoji: emoji,
      isDefault: isDefault || state.isEmpty,
    );

    if (isDefault) {
      state = [
        ...state.map((u) => u.copyWith(isDefault: false)),
        newUpi,
      ];
    } else {
      state = [...state, newUpi];
    }
  }

  void deleteUpi(String id) {
    state = state.where((u) => u.id != id).toList();
    if (state.isNotEmpty && !state.any((u) => u.isDefault)) {
      state = [
        state.first.copyWith(isDefault: true),
        ...state.sublist(1),
      ];
    }
  }

  void setDefaultUpi(String id) {
    state = state.map((u) {
      return u.copyWith(isDefault: u.id == id);
    }).toList();
  }
}

final upiListProvider = NotifierProvider<UpiNotifier, List<SavedUpi>>(() {
  return UpiNotifier();
});
