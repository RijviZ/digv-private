import '../../domain/models/chat.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../sources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Chat>> getMyChats({required String userId}) async {
    final list = await remoteDataSource.getMyChats(userId: userId);
    return list.map((map) => Chat.fromJson(map)).toList();
  }

  @override
  Future<Chat> createOrGetPersonalChat({
    required String userId,
    required String peerUserId,
  }) async {
    final map = await remoteDataSource.createOrGetPersonalChat(
      userId: userId,
      peerUserId: peerUserId,
    );
    return Chat.fromJson(map);
  }

  @override
  Future<List<ChatMessage>> getMessages({
    required String userId,
    required String chatId,
    int limit = 30,
    String? olderThan,
  }) async {
    final list = await remoteDataSource.getMessages(
      userId: userId,
      chatId: chatId,
      limit: limit,
      olderThan: olderThan,
    );
    return list.map((map) => ChatMessage.fromJson(map)).toList();
  }

  @override
  Future<ChatMessage> sendMessage({
    required String userId,
    required String peerUserId,
    String? content,
    String type = 'text',
    List<String>? attachmentUrls,
  }) async {
    final res = await remoteDataSource.sendMessage(
      userId: userId,
      peerUserId: peerUserId,
      content: content,
      type: type,
      attachmentUrls: attachmentUrls,
    );
    
    // In our REST API response structure: { chatId, message }
    // If it returns a top-level message, parse it directly, or parse the nested message structure.
    if (res['message'] != null) {
      return ChatMessage.fromJson(res['message'] as Map<String, dynamic>);
    }
    
    return ChatMessage.fromJson(res);
  }

  @override
  Future<void> markRead({
    required String userId,
    required String chatId,
    required String messageId,
  }) async {
    await remoteDataSource.markRead(
      userId: userId,
      chatId: chatId,
      messageId: messageId,
    );
  }
}
