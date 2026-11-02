import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../data/repositories/faq_repository_impl.dart';
import '../../data/sources/faq_remote_data_source.dart';
import '../../domain/entities/faq.dart';
import '../../domain/repositories/faq_repository.dart';

final faqRemoteDataSourceProvider = Provider<FaqRemoteDataSource>((ref) {
  return FaqRemoteDataSourceImpl(ref.watch(dioProvider));
});

final faqRepositoryProvider = Provider<FaqRepository>((ref) {
  return FaqRepositoryImpl(remoteDataSource: ref.watch(faqRemoteDataSourceProvider));
});

final faqProvider = AsyncNotifierProvider<FaqsNotifier, FaqData>(() {
  return FaqsNotifier();
});

class FaqsNotifier extends AsyncNotifier<FaqData> {
  @override
  FutureOr<FaqData> build() async {
    final repository = ref.watch(faqRepositoryProvider);
    return await repository.getFaqs();
  }

  Future<void> submitFeedback({
    required String faqId,
    required bool isHelpful,
    bool? previousVote, // null = first vote, true/false = switching from that vote
  }) async {
    // Optimistically update counts in state so the UI is instant
    final currentData = state.value;
    if (currentData != null) {
      final updatedItems = currentData.items.map((item) {
        if (item.faqId != faqId) return item;

        int newHelpful = item.helpfulCount;
        int newNotHelpful = item.notHelpfulCount;

        // Undo the previous vote
        if (previousVote == true) newHelpful = (newHelpful - 1).clamp(0, 999999);
        if (previousVote == false) newNotHelpful = (newNotHelpful - 1).clamp(0, 999999);

        // Apply the new vote
        if (isHelpful) {
          newHelpful += 1;
        } else {
          newNotHelpful += 1;
        }

        return item.copyWith(
          helpfulCount: newHelpful,
          notHelpfulCount: newNotHelpful,
        );
      }).toList();

      state = AsyncValue.data(FaqData(items: updatedItems, tabs: currentData.tabs));
    }

    // Persist to server
    final repository = ref.read(faqRepositoryProvider);
    await repository.submitFeedback(faqId: faqId, isHelpful: isHelpful);

    // Refresh from server to sync authoritative counts
    final updatedData = await repository.getFaqs();
    state = AsyncValue.data(updatedData);
  }
}
