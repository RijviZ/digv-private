import 'package:dio/dio.dart';

abstract class ChatRemoteDataSource {
  Future<List<Map<String, dynamic>>> getMyChats({required String userId});
  
  Future<Map<String, dynamic>> createOrGetPersonalChat({
    required String userId,
    required String peerUserId,
  });

  Future<List<Map<String, dynamic>>> getMessages({
    required String userId,
    required String chatId,
    int limit = 30,
    String? olderThan,
  });

  Future<Map<String, dynamic>> sendMessage({
    required String userId,
    required String peerUserId,
    String? content,
    String type = 'text',
    List<String>? attachmentUrls,
  });

  Future<Map<String, dynamic>> markRead({
    required String userId,
    required String chatId,
    required String messageId,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio _dio;

  ChatRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<Map<String, dynamic>>> getMyChats({required String userId}) async {
    final res = await _dio.get('/chat/my', queryParameters: {
      'userId': userId,
    });
    return (res.data as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> createOrGetPersonalChat({
    required String userId,
    required String peerUserId,
  }) async {
    final res = await _dio.post(
      '/chat/personal',
      queryParameters: {'userId': userId},
      data: {'peerUserId': peerUserId},
    );
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> getMessages({
    required String userId,
    required String chatId,
    int limit = 30,
    String? olderThan,
  }) async {
    final res = await _dio.get('/chat/messages', queryParameters: {
      'userId': userId,
      'chatId': chatId,
      'limit': limit,
      if (olderThan != null) 'olderThan': olderThan,
    });
    return (res.data as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> sendMessage({
    required String userId,
    required String peerUserId,
    String? content,
    String type = 'text',
    List<String>? attachmentUrls,
  }) async {
    final res = await _dio.post(
      '/chat/messages',
      queryParameters: {'userId': userId},
      data: {
        'peerUserId': peerUserId,
        if (content != null) 'content': content,
        'type': type,
        'attachmentUrls': attachmentUrls ?? [],
      },
    );
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> markRead({
    required String userId,
    required String chatId,
    required String messageId,
  }) async {
    final res = await _dio.post(
      '/chat/read',
      queryParameters: {'userId': userId},
      data: {
        'chatId': chatId,
        'messageId': messageId,
      },
    );
    return res.data as Map<String, dynamic>;
  }
}
