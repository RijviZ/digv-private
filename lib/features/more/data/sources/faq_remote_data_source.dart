import 'package:dio/dio.dart';
import '../models/faq_model.dart';

abstract class FaqRemoteDataSource {
  Future<FaqDataModel> getFaqs();
  Future<void> submitFeedback({required String faqId, required bool isHelpful});
}

class FaqRemoteDataSourceImpl implements FaqRemoteDataSource {
  final Dio _dio;

  FaqRemoteDataSourceImpl(this._dio);

  @override
  Future<FaqDataModel> getFaqs() async {
    try {
      final response = await _dio.get('/faqs', queryParameters: {
        'isActive': 'true',
        'page': 1,
        'limit': 100,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['success'] == true) {
          return FaqDataModel.fromJson(data['data'] as Map<String, dynamic>);
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch FAQs');
        }
      } else {
        throw Exception('Failed to load FAQs: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  @override
  Future<void> submitFeedback({required String faqId, required bool isHelpful}) async {
    try {
      final response = await _dio.patch('/faqs/$faqId/feedback', data: {
        'isHelpful': isHelpful,
      });

      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to submit feedback');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }
}
