import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatSocketService {
  IO.Socket? _socket;
  IO.Socket? get socket => _socket;

  // Callback lists to register handlers dynamically
  void Function(Map<String, dynamic>)? onConnectionSuccessCallback;
  void Function(List<dynamic>)? onChatHistoryCallback;
  void Function(Map<String, dynamic>)? onNewMessageCallback;
  void Function(Map<String, dynamic>)? onMessageReadCallback;
  void Function(Map<String, dynamic>)? onTypingCallback;
  void Function(dynamic)? onConnectErrorCallback;
  void Function()? onDisconnectCallback;
  void Function()? onConnectCallback;

  bool get isConnected => _socket?.connected ?? false;

  void connect({
    required String baseUrl, // example: https://unwitty-insensately-rikki.ngrok-free.dev
    required String accessToken,
  }) {
    // If already connected or socket exists, disconnect first
    if (_socket != null) {
      disconnect();
    }

    // Clean base URL and append /chat namespace
    final String cleanUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final String socketUrl = '$cleanUrl/chat';

    _socket = IO.io(
      socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': accessToken})
          .build(),
    );

    _socket!.onConnect((_) {
      print('Chat socket connected');
      onConnectCallback?.call();
    });

    _socket!.on('connection_success', (data) {
      print('Socket auth success: $data');
      if (data is Map) {
        onConnectionSuccessCallback?.call(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('chatHistory', (data) {
      print('Socket received chatHistory: $data');
      if (data is List) {
        onChatHistoryCallback?.call(data);
      }
    });

    _socket!.on('newMessage', (data) {
      print('Socket received newMessage: $data');
      if (data is Map) {
        onNewMessageCallback?.call(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('messageRead', (data) {
      print('Socket received messageRead: $data');
      if (data is Map) {
        onMessageReadCallback?.call(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('typing', (data) {
      print('Socket received typing: $data');
      if (data is Map) {
        onTypingCallback?.call(Map<String, dynamic>.from(data));
      }
    });

    _socket!.onConnectError((error) {
      print('Socket connect error: $error');
      onConnectErrorCallback?.call(error);
    });

    _socket!.onDisconnect((_) {
      print('Chat socket disconnected');
      onDisconnectCallback?.call();
    });

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void joinChat(String chatId) {
    if (_socket != null && isConnected) {
      _socket!.emit('joinChat', {'chatId': chatId});
    } else {
      print('Cannot joinChat: socket is not connected');
    }
  }

  void sendMessage({
    required String peerUserId,
    String? content,
    String type = 'text',
    List<String>? attachmentUrls,
  }) {
    if (_socket != null && isConnected) {
      _socket!.emit('sendMessage', {
        'peerUserId': peerUserId,
        if (content != null) 'content': content,
        'type': type,
        'attachmentUrls': attachmentUrls ?? [],
      });
    } else {
      print('Cannot sendMessage: socket is not connected');
    }
  }

  void markRead({required String chatId, required String messageId}) {
    if (_socket != null && isConnected) {
      _socket!.emit('markRead', {
        'chatId': chatId,
        'messageId': messageId,
      });
    } else {
      print('Cannot markRead: socket is not connected');
    }
  }

  void typing({required String chatId, required bool isTyping}) {
    if (_socket != null && isConnected) {
      _socket!.emit('typing', {
        'chatId': chatId,
        'isTyping': isTyping,
      });
    } else {
      print('Cannot emit typing: socket is not connected');
    }
  }
}
