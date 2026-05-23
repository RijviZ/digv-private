import '../entities/faq.dart';

abstract class FaqRepository {
  Future<FaqData> getFaqs();
  Future<void> submitFeedback({required String faqId, required bool isHelpful});
}
