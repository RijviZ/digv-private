import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dio_provider.dart';

final fileUploadServiceProvider = Provider<FileUploadService>((ref) {
  return FileUploadServiceImpl(dio: ref.watch(dioProvider));
});

abstract class FileUploadService {
  Future<String> uploadFile(String filePath, {required String category});
}

class FileUploadServiceImpl implements FileUploadService {
  final Dio dio;

  FileUploadServiceImpl({required this.dio});

  @override
  Future<String> uploadFile(String filePath, {required String category}) async {
    try {
      final fileName = filePath.split('/').last;

      final FormData formData = FormData.fromMap({
        "fileCategory": category,
        "files": await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      final response = await dio.post(
        '/files/upload',
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      // The API returns an array of uploaded files
      if (response.statusCode == 201 && response.data != null && response.data is List && response.data.isNotEmpty) {
        return response.data[0]['url'] as String;
      } else {
        throw Exception('Failed to upload file. Unexpected response format.');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final errorData = e.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          throw Exception(errorData['message']);
        }
      }
      throw Exception(e.message ?? 'An unknown error occurred during upload');
    }
  }
}
