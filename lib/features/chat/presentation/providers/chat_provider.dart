import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/network/failure.dart';
import '../../../../core/storage/secure_storage_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/message_model.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/sources/chat_remote_data_source.dart';
import '../../data/sources/chat_socket_service.dart';
import '../../domain/models/chat.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

class ApiClient {
  final Dio dio;
  ApiClient(this.dio);
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});

extension SecureStorageTokenExt on FlutterSecureStorage {
  Future<String?> getToken() => read(key: 'accessToken');
}

// Chat Data Source
final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return ChatRemoteDataSourceImpl(dio: dio);
});

// Chat Repository
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final dataSource = ref.watch(chatRemoteDataSourceProvider);
  return ChatRepositoryImpl(remoteDataSource: dataSource);
});

// Chat Socket Service Singleton
final chatSocketServiceProvider = Provider<ChatSocketService>((ref) {
  final service = ChatSocketService();
  ref.onDispose(() {
    service.disconnect();
  });
  return service;
});

// Active Chat State class
class ActiveChatState {
  final Chat? chat;
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isPeerTyping;
  final String? errorMessage;

  ActiveChatState({
    this.chat,
    this.messages = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isPeerTyping = false,
    this.errorMessage,
  });

  ActiveChatState copyWith({
    Chat? chat,
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isPeerTyping,
    String? errorMessage,
  }) {
    return ActiveChatState(
      chat: chat ?? this.chat,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isPeerTyping: isPeerTyping ?? this.isPeerTyping,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Active Chat Room Notifier
// It handles connecting to socket, joining chat, fetching REST history, and real-time syncing.
final activeChatNotifierProvider =
    StateNotifierProvider.family<ActiveChatNotifier, ActiveChatState, String>((
      ref,
      peerUserId,
    ) {
      final repository = ref.watch(chatRepositoryProvider);
      final socketService = ref.watch(chatSocketServiceProvider);
      return ActiveChatNotifier(
        ref: ref,
        repository: repository,
        socketService: socketService,
        peerUserId: peerUserId,
      );
    });

class ActiveChatNotifier extends StateNotifier<ActiveChatState> {
  final Ref ref;
  final ChatRepository repository;
  final ChatSocketService socketService;
  final String peerUserId;

  String? _currentUserId;
  Timer? _typingTimer;

  ActiveChatNotifier({
    required this.ref,
    required this.repository,
    required this.socketService,
    required this.peerUserId,
  }) : super(ActiveChatState(isLoading: true)) {
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      // 1. Get authenticated user profile to get currentUserId
      final user = await ref.read(profileProvider.future);
      _currentUserId = user.userId;

      // 2. Retrieve secure token for socket auth
      final storage = ref.read(secureStorageProvider);
      final token = await storage.read(key: 'accessToken') ?? '';

      // 3. Create or get the personal chat room via REST
      final chatRoom = await repository.createOrGetPersonalChat(
        userId: _currentUserId!,
        peerUserId: peerUserId,
      );

      // 4. Fetch initial message history via REST
      final history = await repository.getMessages(
        userId: _currentUserId!,
        chatId: chatRoom.chatId,
        limit: 30,
      );

      state = ActiveChatState(
        chat: chatRoom,
        messages: history,
        isLoading: false,
      );

      // 5. Connect and register Socket.IO listeners
      _setupSocketConnection(token, chatRoom.chatId);
    } catch (e, stack) {
      print('Error initializing chat: $e\n$stack');
      state = ActiveChatState(
        isLoading: false,
        errorMessage: 'Failed to load chat: $e',
      );
    }
  }

  void _setupSocketConnection(String token, String chatId) {
    // Register socket service event callbacks
    socketService.onConnectionSuccessCallback = (data) {
      print('Socket connection success: $data');
      // Join the chat room room as soon as we are auth success
      socketService.joinChat(chatId);
    };

    socketService.onChatHistoryCallback = (data) {
      final List<ChatMessage> receivedMessages = data
          .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList();

      // If we got history, let's merge or replace
      if (receivedMessages.isNotEmpty) {
        state = state.copyWith(messages: receivedMessages);
      }
    };

    socketService.onNewMessageCallback = (data) {
      final message = ChatMessage.fromJson(data);
      if (message.chatId == chatId) {
        // Prevent duplicate appends if we already added it via socket ack or REST
        if (!state.messages.any((m) => m.messageId == message.messageId)) {
          state = state.copyWith(messages: [...state.messages, message]);
        }

        // Auto-emit markRead if the sheet is open
        if (message.senderId != _currentUserId) {
          socketService.markRead(chatId: chatId, messageId: message.messageId);
        }
      }
    };

    socketService.onMessageReadCallback = (data) {
      // payload: { userId, messageId, chatId }
      final String readUserId = data['userId'] as String? ?? '';
      if (readUserId == peerUserId) {
        // Optional: Update locally marked read states
      }
    };

    socketService.onTypingCallback = (data) {
      // payload: { userId, chatId, isTyping }
      final String typingChatId = data['chatId'] as String? ?? '';
      final String typingUserId = data['userId'] as String? ?? '';
      final bool isTyping = data['isTyping'] as bool? ?? false;

      if (typingChatId == chatId && typingUserId == peerUserId) {
        state = state.copyWith(isPeerTyping: isTyping);
      }
    };

    socketService.onConnectErrorCallback = (error) {
      print('Socket connection error: $error');
    };

    // If socket isn't connected, connect it now.
    // Base API URL is dev-service-api.roketbus.com
    const String baseUrl = 'https://dev-service-api.roketbus.com';
    socketService.connect(baseUrl: baseUrl, accessToken: token);

    // If already connected, immediately join chat
    if (socketService.isConnected) {
      socketService.joinChat(chatId);
    }
  }

  // Load older messages for infinite scroll
  Future<void> loadMoreMessages() async {
    if (state.chat == null || state.isLoadingMore || _currentUserId == null)
      return;
    if (state.messages.isEmpty) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      // Use the first (oldest) message's createdAt to fetch older items
      final oldestCreatedAt = state.messages.first.createdAt.toIso8601String();
      final olderMessages = await repository.getMessages(
        userId: _currentUserId!,
        chatId: state.chat!.chatId,
        limit: 30,
        olderThan: oldestCreatedAt,
      );

      if (olderMessages.isNotEmpty) {
        // Prepend the older messages and remove potential duplicates
        final existingIds = state.messages.map((m) => m.messageId).toSet();
        final filteredOlder = olderMessages
            .where((m) => !existingIds.contains(m.messageId))
            .toList();
        state = state.copyWith(messages: [...filteredOlder, ...state.messages]);
      }
    } catch (e) {
      print('Error loading older messages: $e');
    } finally {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  // Send a message
  Future<void> sendMessage(
    String content, {
    String type = 'text',
    List<String>? attachmentUrls,
  }) async {
    if (state.chat == null || _currentUserId == null) return;

    // Send through WebSocket for real-time responsiveness
    if (socketService.isConnected) {
      socketService.sendMessage(
        peerUserId: peerUserId,
        content: content,
        type: type,
        attachmentUrls: attachmentUrls,
      );
    } else {
      // REST API fallback if socket is disconnected
      try {
        final message = await repository.sendMessage(
          userId: _currentUserId!,
          peerUserId: peerUserId,
          content: content,
          type: type,
          attachmentUrls: attachmentUrls,
        );
        state = state.copyWith(messages: [...state.messages, message]);
      } catch (e) {
        print('REST sendMessage fallback failed: $e');
      }
    }
  }

  // Notify peer of typing status
  void notifyTyping(bool isTyping) {
    if (state.chat == null) return;

    // Emit socket typing event
    socketService.typing(chatId: state.chat!.chatId, isTyping: isTyping);

    // If isTyping is true, schedule an auto-stop after 3 seconds of no keypress
    if (isTyping) {
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 3), () {
        socketService.typing(chatId: state.chat!.chatId, isTyping: false);
      });
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    // Notify peer we stopped typing
    if (state.chat != null && socketService.isConnected) {
      socketService.typing(chatId: state.chat!.chatId, isTyping: false);
    }
    super.dispose();
  }
}

final chatListProvider = FutureProvider<List<ChatModel>>((ref) async {
  final profile = ref.watch(profileProvider).value;
  String? userId = profile?.userId;

  if (userId == null) {
    final secureStorage = ref.read(secureStorageProvider);
    final token = await secureStorage.getToken();
    if (token != null) {
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          var payload = parts[1];
          final remainder = payload.length % 4;
          if (remainder > 0) {
            payload += '=' * (4 - remainder);
          }
          final decoded = utf8.decode(base64Url.decode(payload));
          final Map<String, dynamic> claims = jsonDecode(decoded);
          userId = claims['sub'] as String? ??
              claims['userId'] as String? ??
              claims['id'] as String?;
        }
      } catch (_) {}
    }
  }

  if (userId == null) {
    throw Failure('User not logged in');
  }

  final apiClient = ref.watch(apiClientProvider);
  try {
    final response = await apiClient.dio.get(
      '/messages/my',
      queryParameters: {'userId': userId},
    );

    final list = response.data as List? ?? [];
    return list
        .map((item) => ChatModel.fromJson(item as Map<String, dynamic>))
        .toList();
  } on DioException catch (e) {
    final message = e.response?.data?['error']?['message'] ??
        e.response?.data?['message'] ??
        e.message ??
        'An error occurred while fetching chats';
    throw Failure(message, statusCode: e.response?.statusCode ?? 500);
  } catch (e) {
    throw Failure(e.toString());
  }
});

class ChatMessagesState {
  final AsyncValue<List<MessageModel>> messages;
  final String? userId;
  final bool isSending;

  ChatMessagesState({
    required this.messages,
    this.userId,
    this.isSending = false,
  });

  ChatMessagesState copyWith({
    AsyncValue<List<MessageModel>>? messages,
    String? userId,
    bool? isSending,
  }) {
    return ChatMessagesState(
      messages: messages ?? this.messages,
      userId: userId ?? this.userId,
      isSending: isSending ?? this.isSending,
    );
  }
}

class ChatMessagesNotifier extends StateNotifier<ChatMessagesState> {
  final ApiClient apiClient;
  final FlutterSecureStorage secureStorage;
  final String chatId;
  final String initialUserId;

  ChatMessagesNotifier({
    required this.apiClient,
    required this.secureStorage,
    required this.chatId,
    required this.initialUserId,
  }) : super(ChatMessagesState(messages: const AsyncValue.loading())) {
    fetchMessages();
  }

  Future<String> _getUserId() async {
    if (state.userId != null &&
        state.userId != 'mock_user_id' &&
        state.userId!.isNotEmpty) {
      return state.userId!;
    }
    if (initialUserId != 'mock_user_id' && initialUserId.isNotEmpty) {
      return initialUserId;
    }

    try {
      final token = await secureStorage.getToken();
      if (token != null) {
        final parts = token.split('.');
        if (parts.length == 3) {
          var payload = parts[1];
          final remainder = payload.length % 4;
          if (remainder > 0) {
            payload += '=' * (4 - remainder);
          }
          final decoded = utf8.decode(base64Url.decode(payload));
          final Map<String, dynamic> claims = jsonDecode(decoded);
          final resolved = claims['sub'] as String? ??
              claims['userId'] as String? ??
              claims['id'] as String?;
          if (resolved != null && resolved.isNotEmpty) {
            return resolved;
          }
        }
      }
    } catch (_) {}

    return 'mock_user_id';
  }

  Future<void> fetchMessages() async {
    try {
      final resolvedUserId = await _getUserId();
      state = state.copyWith(userId: resolvedUserId);

      final response = await apiClient.dio.get(
        '/messages/all',
        queryParameters: {
          'chatId': chatId,
          'userId': resolvedUserId,
          'limit': 50,
        },
      );
      final list = response.data as List? ?? [];
      final messagesList = list
          .map((item) => MessageModel.fromJson(item as Map<String, dynamic>))
          .toList();
      state = state.copyWith(messages: AsyncValue.data(messagesList));
    } catch (e, stack) {
      state = state.copyWith(messages: AsyncValue.error(e, stack));
    }
  }

  Future<bool> sendMessage(
    String content, {
    required String peerUserId,
    String type = 'text',
    List<String>? attachmentUrls,
  }) async {
    final resolvedUserId = await _getUserId();
    state = state.copyWith(userId: resolvedUserId);

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final tempMessage = MessageModel(
      messageId: tempId,
      chatId: chatId,
      senderId: resolvedUserId,
      type: type,
      content: content,
      attachmentUrls: attachmentUrls,
      createdAt: DateTime.now().toUtc().toIso8601String(),
      updatedAt: DateTime.now().toUtc().toIso8601String(),
    );

    final currentList = state.messages.value ?? [];
    state = state.copyWith(
      messages: AsyncValue.data([...currentList, tempMessage]),
    );

    try {
      final Map<String, dynamic> payload = {
        'peerUserId': peerUserId,
        'type': type,
        'content': content,
        'attachmentUrls': attachmentUrls ?? [],
      };

      final response = await apiClient.dio.post(
        '/messages/send-message',
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        final messageJson = resData is Map ? (resData['message'] ?? resData) : null;
        if (messageJson != null && messageJson is Map<String, dynamic>) {
          final actualMessage = MessageModel.fromJson(messageJson);
          final updatedList = (state.messages.value ?? []).map((msg) {
            return msg.messageId == tempId ? actualMessage : msg;
          }).toList();
          state = state.copyWith(messages: AsyncValue.data(updatedList));
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

final chatMessagesProvider = StateNotifierProvider.family.autoDispose<
    ChatMessagesNotifier, ChatMessagesState, String>((ref, chatId) {
  final apiClient = ref.watch(apiClientProvider);
  final secureStorage = ref.watch(secureStorageProvider);

  final profile = ref.watch(profileProvider).value;
  final userId = profile?.userId;

  return ChatMessagesNotifier(
    apiClient: apiClient,
    secureStorage: secureStorage,
    chatId: chatId,
    initialUserId: userId ?? 'mock_user_id',
  );
});
