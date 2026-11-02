import 'package:dio/dio.dart';

class Failure implements Exception {
  final String message;
  final int? statusCode;

  Failure(this.message, {this.statusCode});

  factory Failure.fromDioException(
    DioException e, [
    String defaultMessage = 'An unexpected error occurred',
  ]) {
    final int? code = e.response?.statusCode;
    String? serverMessage;

    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      if (data.containsKey('message')) {
        final msg = data['message'];
        if (msg is List && msg.isNotEmpty) {
          serverMessage = msg.map((item) => item.toString()).join('\n');
        } else if (msg is String && msg.isNotEmpty) {
          serverMessage = msg;
        }
      } else if (data.containsKey('error')) {
        final err = data['error'];
        if (err is String && err.isNotEmpty) {
          serverMessage = err;
        } else if (err is Map<String, dynamic> && err.containsKey('message')) {
          serverMessage = err['message']?.toString();
        }
      }
    } else if (data is String && data.isNotEmpty) {
      serverMessage = data;
    }

    if (serverMessage != null && serverMessage.isNotEmpty) {
      return Failure(serverMessage, statusCode: code);
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Failure(
          'Connection timed out. Please check your internet connection.',
          statusCode: code,
        );
      case DioExceptionType.connectionError:
        return Failure(
          'No internet connection. Please verify your network.',
          statusCode: code,
        );
      case DioExceptionType.badResponse:
        return Failure(
          'Request failed (${code ?? 400}): $defaultMessage',
          statusCode: code,
        );
      case DioExceptionType.cancel:
        return Failure('Request was cancelled.', statusCode: code);
      default:
        return Failure(defaultMessage, statusCode: code);
    }
  }

  @override
  String toString() => message;
}
