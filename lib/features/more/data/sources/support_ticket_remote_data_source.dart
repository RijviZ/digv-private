import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';

class SupportTicketSender {
  final String userId;
  final String? userType;
  final String? fullName;
  final String? avatarUrl;
  final String? phoneNumber;
  final String? email;

  SupportTicketSender({
    required this.userId,
    this.userType,
    this.fullName,
    this.avatarUrl,
    this.phoneNumber,
    this.email,
  });

  factory SupportTicketSender.fromJson(Map<String, dynamic> json) {
    return SupportTicketSender(
      userId: json['userId'] ?? '',
      userType: json['userType'],
      fullName: json['fullName'],
      avatarUrl: json['avatarUrl'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
    );
  }
}

class SupportTicketMessage {
  final String messageId;
  final String ticketId;
  final String senderId;
  final String message;
  final String? attachmentUrl;
  final bool isRead;
  final String createdAt;
  final SupportTicketSender? sender;

  SupportTicketMessage({
    required this.messageId,
    required this.ticketId,
    required this.senderId,
    required this.message,
    this.attachmentUrl,
    required this.isRead,
    required this.createdAt,
    this.sender,
  });

  factory SupportTicketMessage.fromJson(Map<String, dynamic> json) {
    return SupportTicketMessage(
      messageId: json['messageId'] ?? '',
      ticketId: json['ticketId'] ?? '',
      senderId: json['senderId'] ?? '',
      message: json['message'] ?? '',
      attachmentUrl: json['attachmentUrl'],
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] ?? '',
      sender: json['sender'] != null ? SupportTicketSender.fromJson(json['sender']) : null,
    );
  }
}

class SupportTicket {
  final String ticketId;
  final String userId;
  final String subject;
  final String supportTicketNo;
  final String? referenceNumber;
  final String ticketStatus;
  final String createdAt;
  final String updatedAt;
  final List<SupportTicketMessage> messages;

  SupportTicket({
    required this.ticketId,
    required this.userId,
    required this.subject,
    required this.supportTicketNo,
    this.referenceNumber,
    required this.ticketStatus,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    var msgsJson = json['messages'] as List? ?? [];
    return SupportTicket(
      ticketId: json['ticketId'] ?? '',
      userId: json['userId'] ?? '',
      subject: json['subject'] ?? '',
      supportTicketNo: json['supportTicketNo'] ?? '',
      referenceNumber: json['referenceNumber'],
      ticketStatus: json['ticketStatus'] ?? 'OPEN',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      messages: msgsJson.map((m) => SupportTicketMessage.fromJson(m)).toList(),
    );
  }
}

abstract class SupportTicketRemoteDataSource {
  Future<SupportTicket> createTicket({
    required String subject,
    String? referenceNumber,
    required String message,
    String? attachmentUrl,
  });

  Future<List<SupportTicket>> getMyTickets();

  Future<SupportTicket> getTicketById(String id);

  Future<SupportTicketMessage> replyToTicket({
    required String ticketId,
    required String message,
    String? attachmentUrl,
  });
}

class SupportTicketRemoteDataSourceImpl implements SupportTicketRemoteDataSource {
  final Dio dio;

  SupportTicketRemoteDataSourceImpl({required this.dio});

  @override
  Future<SupportTicket> createTicket({
    required String subject,
    String? referenceNumber,
    required String message,
    String? attachmentUrl,
  }) async {
    final response = await dio.post(
      '/support-tickets',
      data: {
        'subject': subject,
        if (referenceNumber != null && referenceNumber.isNotEmpty) 'referenceNumber': referenceNumber,
        'message': message,
        if (attachmentUrl != null && attachmentUrl.isNotEmpty) 'attachmentUrl': attachmentUrl,
      },
    );

    final data = response.data;
    if (data != null && data['data'] != null) {
      return SupportTicket.fromJson(data['data']);
    }
    throw Exception('Failed to create support ticket');
  }

  @override
  Future<List<SupportTicket>> getMyTickets() async {
    final response = await dio.get('/support-tickets/me');
    final data = response.data;
    if (data != null && data['data'] is List) {
      final list = data['data'] as List;
      return list.map((item) => SupportTicket.fromJson(item)).toList();
    }
    return [];
  }

  @override
  Future<SupportTicket> getTicketById(String id) async {
    final response = await dio.get('/support-tickets/$id');
    final data = response.data;
    if (data != null && data['data'] != null) {
      return SupportTicket.fromJson(data['data']);
    }
    throw Exception('Failed to fetch ticket details');
  }

  @override
  Future<SupportTicketMessage> replyToTicket({
    required String ticketId,
    required String message,
    String? attachmentUrl,
  }) async {
    final response = await dio.post(
      '/support-tickets/$ticketId/reply',
      data: {
        'message': message,
        if (attachmentUrl != null && attachmentUrl.isNotEmpty) 'attachmentUrl': attachmentUrl,
      },
    );

    final data = response.data;
    if (data != null && data['data'] != null) {
      return SupportTicketMessage.fromJson(data['data']);
    }
    throw Exception('Failed to send reply');
  }
}

final supportTicketRemoteDataSourceProvider = Provider<SupportTicketRemoteDataSource>((ref) {
  return SupportTicketRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

final mySupportTicketsProvider = FutureProvider<List<SupportTicket>>((ref) async {
  final dataSource = ref.watch(supportTicketRemoteDataSourceProvider);
  return dataSource.getMyTickets();
});

final supportTicketDetailProvider = FutureProvider.family<SupportTicket, String>((ref, ticketId) async {
  final dataSource = ref.watch(supportTicketRemoteDataSourceProvider);
  return dataSource.getTicketById(ticketId);
});
