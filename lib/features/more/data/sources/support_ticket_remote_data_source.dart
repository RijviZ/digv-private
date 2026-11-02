import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../../../core/network/failure.dart';

class SupportSenderModel {
  final String userId;
  final String userType;
  final String fullName;
  final String? avatarUrl;

  SupportSenderModel({
    required this.userId,
    required this.userType,
    required this.fullName,
    this.avatarUrl,
  });

  factory SupportSenderModel.fromJson(Map<String, dynamic> json) {
    return SupportSenderModel(
      userId: json['userId']?.toString() ?? '',
      userType: json['userType']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }
}

typedef SupportTicketSender = SupportSenderModel;

class SupportMessageModel {
  final String messageId;
  final String ticketId;
  final String senderId;
  final String message;
  final String? attachmentUrl;
  final bool isRead;
  final String createdAt;
  final SupportSenderModel? sender;

  SupportMessageModel({
    required this.messageId,
    required this.ticketId,
    required this.senderId,
    required this.message,
    this.attachmentUrl,
    required this.isRead,
    required this.createdAt,
    this.sender,
  });

  factory SupportMessageModel.fromJson(Map<String, dynamic> json) {
    return SupportMessageModel(
      messageId: json['messageId']?.toString() ?? '',
      ticketId: json['ticketId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      attachmentUrl: json['attachmentUrl']?.toString(),
      isRead: json['isRead'] == true ||
          json['isRead'] == 1 ||
          json['isRead']?.toString().toLowerCase() == 'true',
      createdAt: json['createdAt']?.toString() ?? '',
      sender: json['sender'] != null && json['sender'] is Map
          ? SupportSenderModel.fromJson(json['sender'] as Map<String, dynamic>)
          : null,
    );
  }
}

typedef SupportTicketMessage = SupportMessageModel;

class SupportTicketModel {
  final String ticketId;
  final String userId;
  final String subject;
  final String supportTicketNo;
  final String? referenceNumber;
  final String ticketStatus;
  final String createdAt;
  final String updatedAt;
  final List<SupportMessageModel> messages;

  SupportTicketModel({
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

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    final list = json['messages'] as List? ?? [];
    return SupportTicketModel(
      ticketId: json['ticketId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      supportTicketNo: json['supportTicketNo']?.toString() ?? '',
      referenceNumber: json['referenceNumber']?.toString(),
      ticketStatus: json['ticketStatus']?.toString() ?? 'OPEN',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      messages: list
          .where((m) => m != null && m is Map)
          .map((m) => SupportMessageModel.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}

typedef SupportTicket = SupportTicketModel;

abstract class SupportTicketRemoteDataSource {
  Future<List<SupportTicketModel>> getTickets();
  Future<List<SupportTicketModel>> getMyTickets();
  Future<SupportTicketModel> getTicketDetails(String id);
  Future<SupportTicketModel> getTicketById(String id);
  Future<SupportTicketModel> createTicket({
    required String subject,
    String? referenceNumber,
    required String message,
    String? attachmentUrl,
  });
  Future<SupportMessageModel> replyTicket({
    required String id,
    required String message,
    String? attachmentUrl,
  });
  Future<SupportMessageModel> replyToTicket({
    required String ticketId,
    required String message,
    String? attachmentUrl,
  });
}

typedef SupportRemoteDataSource = SupportTicketRemoteDataSource;

class SupportTicketRemoteDataSourceImpl implements SupportTicketRemoteDataSource {
  final Dio dio;

  SupportTicketRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<SupportTicketModel>> getTickets() async {
    try {
      final response = await dio.get('/support-tickets/me');
      final data = response.data['data'] as List<dynamic>?;
      if (data == null) {
        throw Failure('Support tickets data not found');
      }
      return data
          .where((json) => json != null && json is Map)
          .map((json) => SupportTicketModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Failure.fromDioException(e, 'An error occurred while fetching support tickets');
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure(e.toString());
    }
  }

  @override
  Future<List<SupportTicketModel>> getMyTickets() => getTickets();

  @override
  Future<SupportTicketModel> getTicketDetails(String id) async {
    try {
      final response = await dio.get('/support-tickets/$id');
      final data = response.data['data'];
      if (data == null) {
        throw Failure('Support ticket details not found');
      }
      return SupportTicketModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Failure.fromDioException(e, 'An error occurred while fetching support ticket details');
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure(e.toString());
    }
  }

  @override
  Future<SupportTicketModel> getTicketById(String id) => getTicketDetails(id);

  @override
  Future<SupportTicketModel> createTicket({
    required String subject,
    String? referenceNumber,
    required String message,
    String? attachmentUrl,
  }) async {
    try {
      final payload = {
        'subject': subject,
        'message': message,
        if (referenceNumber != null && referenceNumber.trim().isNotEmpty)
          'referenceNumber': referenceNumber.trim(),
        if (attachmentUrl != null && attachmentUrl.trim().isNotEmpty)
          'attachmentUrl': attachmentUrl.trim(),
      };
      final response = await dio.post(
        '/support-tickets',
        data: payload,
      );
      final data = response.data['data'];
      if (data == null) {
        throw Failure('Failed to create support ticket');
      }
      return SupportTicketModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Failure.fromDioException(e, 'An error occurred while creating support ticket');
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure(e.toString());
    }
  }

  @override
  Future<SupportMessageModel> replyTicket({
    required String id,
    required String message,
    String? attachmentUrl,
  }) async {
    try {
      final payload = {
        'message': message,
        if (attachmentUrl != null && attachmentUrl.trim().isNotEmpty)
          'attachmentUrl': attachmentUrl.trim(),
      };
      final response = await dio.post(
        '/support-tickets/$id/reply',
        data: payload,
      );
      final data = response.data['data'];
      if (data == null) {
        throw Failure('Failed to reply to support ticket');
      }
      return SupportMessageModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Failure.fromDioException(e, 'An error occurred while replying to support ticket');
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure(e.toString());
    }
  }

  @override
  Future<SupportMessageModel> replyToTicket({
    required String ticketId,
    required String message,
    String? attachmentUrl,
  }) =>
      replyTicket(id: ticketId, message: message, attachmentUrl: attachmentUrl);
}

typedef SupportRemoteDataSourceImpl = SupportTicketRemoteDataSourceImpl;

final supportTicketRemoteDataSourceProvider = Provider<SupportTicketRemoteDataSource>((ref) {
  return SupportTicketRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

final supportRemoteDataSourceProvider = supportTicketRemoteDataSourceProvider;
final supportRepositoryProvider = supportTicketRemoteDataSourceProvider;

final mySupportTicketsProvider = FutureProvider<List<SupportTicketModel>>((ref) async {
  final dataSource = ref.watch(supportTicketRemoteDataSourceProvider);
  return dataSource.getTickets();
});

final supportTicketsProvider = mySupportTicketsProvider;

final supportTicketDetailProvider =
    FutureProvider.family<SupportTicketModel, String>((ref, ticketId) async {
  final dataSource = ref.watch(supportTicketRemoteDataSourceProvider);
  return dataSource.getTicketDetails(ticketId);
});

final supportTicketDetailsProvider = supportTicketDetailProvider;
