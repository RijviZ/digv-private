import 'dart:developer' as developer;
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  developer.log('Handling a background message: ${message.messageId}', name: 'PushNotificationService');
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  bool _isFirebaseInitialized = false;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Initializes Firebase and Push Notification configurations.
  /// If native configuration files (google-services.json / GoogleService-Info.plist)
  /// are missing, it will gracefully catch the error and fall back.
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      _isFirebaseInitialized = true;
      developer.log('Firebase successfully initialized natively.', name: 'PushNotificationService');

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Initialize local notifications for foreground messages
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          developer.log('Local notification tapped: ${response.payload}', name: 'PushNotificationService');
          // Handle navigation here if payload contains route info
        },
      );

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

      if (Platform.isAndroid) {
        // Create Android Notification Channel
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'high_importance_channel', // id
          'High Importance Notifications', // name
          description: 'This channel is used for important notifications.', // description
          importance: Importance.max,
        );

        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);
      }

      // Handle initial message (terminated state)
      RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        developer.log('App opened from terminated state by notification: ${initialMessage.notification?.title}', name: 'PushNotificationService');
      }

      // Set foreground presentation options for iOS
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Listen to foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        developer.log('Received foreground push notification: ${message.notification?.title}', name: 'PushNotificationService');
        
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        // If a notification is received while in the foreground, display it.
        // On iOS, setForegroundNotificationPresentationOptions handles this natively,
        // but we can still trigger local notifications if needed or let the system handle it.
        if (notification != null) {
          _flutterLocalNotificationsPlugin.show(
            id: notification.hashCode,
            title: notification.title,
            body: notification.body,
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                'high_importance_channel',
                'High Importance Notifications',
                channelDescription: 'This channel is used for important notifications.',
                icon: android?.smallIcon ?? '@mipmap/ic_launcher',
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              )
            ),
            payload: message.data.toString(),
          );
        }
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
  Future<String?> getDeviceToken() async {
    if (!_isFirebaseInitialized) {
      developer.log('Firebase not initialized. Returning null device token.', name: 'PushNotificationService');
      return null;
    }

    try {
      // On iOS, it's highly recommended to retrieve the APNs token first before getting the FCM token.
      if (Platform.isIOS) {
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken == null) {
          developer.log('APNs Token is null. The FCM token may fail to fetch or be invalid.', name: 'PushNotificationService');
          // We can delay briefly to allow APNs to register, though usually it happens automatically.
          await Future.delayed(const Duration(seconds: 2));
        } else {
          developer.log('APNs Token successfully retrieved.', name: 'PushNotificationService');
        }
      }

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        developer.log('Retrieved FCM Device Token successfully: $token', name: 'PushNotificationService');
        print('\n\n========== FCM DEVICE TOKEN ==========\n$token\n======================================\n\n');
        return token;
      }
    } catch (e) {
      developer.log(
        'Failed to fetch real FCM token. Returning null device token.',
        name: 'PushNotificationService',
        error: e,
      );
    }

    return null;
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
