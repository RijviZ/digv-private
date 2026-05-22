import 'package:digv/features/notifications/data/models/notification_model.dart';
import 'package:dio/dio.dart';

abstract class NotificationRemoteDataSource {
  Future<NotificationDataModel> getNotifications(int page, int limit);
  Future<int> getUnreadCount();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio _dio;

  NotificationRemoteDataSourceImpl(this._dio);

  @override
  Future<NotificationDataModel> getNotifications(int page, int limit) async {
    try {
      final response = await _dio.get('/notifications', queryParameters: {
        'page': page,
        'limit': limit,
      });

      if (response.statusCode == 200) {
        return NotificationDataModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('/notifications/unread-count');

      if (response.statusCode == 200) {
        return response.data['data']['unreadCount'] ?? 0;
      } else {
        throw Exception('Failed to load unread count: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await _dio.patch('/notifications/$notificationId/read');

      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification as read: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final response = await _dio.patch('/notifications/read-all');

      if (response.statusCode != 200) {
        throw Exception('Failed to mark all notifications as read: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }
}
