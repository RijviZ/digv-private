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

  Future<void> submitFeedback({required String faqId, required bool isHelpful}) async {
    final repository = ref.read(faqRepositoryProvider);
    await repository.submitFeedback(faqId: faqId, isHelpful: isHelpful);
    
    // Refresh the FAQ data to update the counts in the UI
    final updatedData = await repository.getFaqs();
    state = AsyncValue.data(updatedData);
  }
}
