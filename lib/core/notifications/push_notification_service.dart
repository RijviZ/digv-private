import 'dart:developer' as developer;
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  bool _isFirebaseInitialized = false;

  /// Initializes Firebase and Push Notification configurations.
  /// If native configuration files (google-services.json / GoogleService-Info.plist)
  /// are missing, it will gracefully catch the error and fall back.
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      _isFirebaseInitialized = true;
      developer.log('Firebase successfully initialized natively.', name: 'PushNotificationService');

      // Request notification permission
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      developer.log('User notification permission status: ${settings.authorizationStatus}', name: 'PushNotificationService');

      // Listen to foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        developer.log('Received foreground push notification: ${message.notification?.title}', name: 'PushNotificationService');
      });

      // Handle message clicks when app is opened from a notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        developer.log('User tapped on notification: ${message.notification?.title}', name: 'PushNotificationService');
      });
      
    } catch (e) {
      _isFirebaseInitialized = false;
      developer.log(
        'Firebase Core could not be initialized natively (likely missing native credential files). Using fallback integration mode.',
        name: 'PushNotificationService',
        error: e,
      );
    }
  }

  /// Gets the Firebase Cloud Messaging device token with a fallback.
  Future<String> getDeviceToken() async {
    if (!_isFirebaseInitialized) {
      developer.log('Firebase not initialized. Returning mock device token.', name: 'PushNotificationService');
      return 'e1F_A4xWRQe7d-V8G9H0I1J2K3L4M5N6O7P8Q9R0S1T2U3V4W5X6Y7Z8a9b0c1d2e3f4g5h6i7j8k9l0m1n2o3p4q5r6s7t8u9v0w1x2y3z4A5B6C7D8E9F0G1H2I3J4K5L6M7N8O9P';
    }

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        developer.log('Retrieved FCM Device Token successfully.', name: 'PushNotificationService');
        return token;
      }
    } catch (e) {
      developer.log(
        'Failed to fetch real FCM token. Returning fallback device token.',
        name: 'PushNotificationService',
        error: e,
      );
    }

    return 'f3JpA4xWRQe7d-V8G9H0I1J2K3L4M5N6O7P8Q9R0S1T2U3V4W5X6Y7Z8a9b0c1d2e3f4g5h6i7j8k9l0m1n2o3p4q5r6s7t8u9v0w1x2y3z4A5B6C7D8E9F0G1H2I3J4K5L6M7N8O9P';
  }

  /// Gets the current operating system platform.
  String getPlatform() {
    try {
      return Platform.operatingSystem.toLowerCase();
    } catch (e) {
      return 'android';
    }
  }

  /// Gets the application version.
  Future<String> getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (packageInfo.version.isNotEmpty) {
        return packageInfo.version;
      }
    } catch (e) {
      developer.log('Failed to fetch package info version. Returning default app version.', name: 'PushNotificationService', error: e);
    }
    return '1.0.0';
  }
}
