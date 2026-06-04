import '../models/chat.dart';
import '../models/chat_message.dart';

abstract class ChatRepository {
  Future<List<Chat>> getMyChats({required String userId});
  
  Future<Chat> createOrGetPersonalChat({
    required String userId,
    required String peerUserId,
  });

  Future<List<ChatMessage>> getMessages({
    required String userId,
    required String chatId,
    int limit = 30,
    String? olderThan,
  });

  Future<ChatMessage> sendMessage({
    required String userId,
    required String peerUserId,
    String? content,
    String type = 'text',
    List<String>? attachmentUrls,
  });

  Future<void> markRead({
    required String userId,
    required String chatId,
    required String messageId,
  });
}
