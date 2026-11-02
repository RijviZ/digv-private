import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/secure_storage_provider.dart';
import '../../domain/entities/saved_upi.dart';

class UpiNotifier extends Notifier<List<SavedUpi>> {
  static const String _storageKey = 'saved_upi_list';

  @override
  List<SavedUpi> build() {
    _loadFromStorage();
    return const [];
  }

  Future<void> _loadFromStorage() async {
    try {
      final storage = ref.read(secureStorageProvider);
      final rawJson = await storage.read(key: _storageKey);
      if (rawJson != null && rawJson.isNotEmpty) {
        final decoded = jsonDecode(rawJson) as List<dynamic>;
        state = decoded
            .where((item) => item != null && item is Map)
            .map((item) => SavedUpi.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Keep empty on error
    }
  }

  Future<void> _persist() async {
    try {
      final storage = ref.read(secureStorageProvider);
      final encoded = jsonEncode(state.map((u) => u.toJson()).toList());
      await storage.write(key: _storageKey, value: encoded);
    } catch (_) {}
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

    _persist();
  }

  void deleteUpi(String id) {
    state = state.where((u) => u.id != id).toList();
    if (state.isNotEmpty && !state.any((u) => u.isDefault)) {
      state = [
        state.first.copyWith(isDefault: true),
        ...state.sublist(1),
      ];
    }
    _persist();
  }

  void setDefaultUpi(String id) {
    state = state.map((u) {
      return u.copyWith(isDefault: u.id == id);
    }).toList();
    _persist();
  }
}

final upiListProvider = NotifierProvider<UpiNotifier, List<SavedUpi>>(() {
  return UpiNotifier();
});
