import '../../domain/entities/faq.dart';
import '../../domain/repositories/faq_repository.dart';
import '../sources/faq_remote_data_source.dart';

class FaqRepositoryImpl implements FaqRepository {
  final FaqRemoteDataSource remoteDataSource;

  FaqRepositoryImpl({required this.remoteDataSource});

  @override
  Future<FaqData> getFaqs() async {
    return await remoteDataSource.getFaqs();
  }

  @override
  Future<void> submitFeedback({required String faqId, required bool isHelpful}) async {
    return await remoteDataSource.submitFeedback(faqId: faqId, isHelpful: isHelpful);
  }
}
