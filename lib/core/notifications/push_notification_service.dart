import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:digv/core/router/app_router.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  developer.log(
    'Handling a background message: ${message.messageId}',
    name: 'PushNotificationService',
  );
}

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  bool _isFirebaseInitialized = false;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initializes Firebase and Push Notification configurations.
  /// If native configuration files (google-services.json / GoogleService-Info.plist)
  /// are missing, it will gracefully catch the error and fall back.
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      _isFirebaseInitialized = true;
      print('[NOTIF_DEBUG] ✅ Firebase initialized successfully');

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      print('[NOTIF_DEBUG] ✅ Background message handler registered');

      // Initialize local notifications for foreground messages
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('ic_notification');
      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );
      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
          );

      await _flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print('[NOTIF_DEBUG] Local notification tapped: ${response.payload}');
          if (response.payload != null && response.payload!.isNotEmpty) {
            try {
              final Map<String, dynamic> data = jsonDecode(response.payload!) as Map<String, dynamic>;
              String? serviceRequestId = data['serviceRequestId'] as String?;
              String? serviceRequestNumber = data['serviceRequestNumber'] as String?;

              if (serviceRequestId == null && data['clickAction'] != null) {
                final clickAction = data['clickAction'] as String;
                final uriParts = clickAction.split('/');
                if (uriParts.isNotEmpty) {
                  final lastPart = uriParts.last;
                  if (lastPart.length >= 32) {
                    serviceRequestId = lastPart;
                  }
                }
              }

              // Fallback to scan values for SBR ID
              if (serviceRequestNumber == null) {
                final sbrRegex = RegExp(r'\bSBR\d+\b');
                for (final val in data.values) {
                  if (val is String) {
                    final match = sbrRegex.firstMatch(val);
                    if (match != null) {
                      serviceRequestNumber = match.group(0);
                      break;
                    }
                  }
                }
              }

              if (serviceRequestId != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  appRouter.push('/order_tracking', extra: serviceRequestId);
                });
              } else if (serviceRequestNumber != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  appRouter.push('/order_tracking', extra: serviceRequestNumber);
                });
              }
            } catch (e) {
              print('[NOTIF_DEBUG] Error handling local notification tap: $e');
            }
          }
        },
      );
      print('[NOTIF_DEBUG] ✅ Local notifications plugin initialized');

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

      print('[NOTIF_DEBUG] ✅ Permission status: ${settings.authorizationStatus}');

      if (Platform.isAndroid) {
        // Create Android Notification Channel
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'high_importance_channel_v3',
          'High Importance Notifications',
          description: 'This channel is used for important notifications.',
          importance: Importance.max,
        );

        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.createNotificationChannel(channel);
        print('[NOTIF_DEBUG] ✅ Android notification channel created');
      }

      // Handle initial message (terminated state)
      RemoteMessage? initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initialMessage != null) {
        print('[NOTIF_DEBUG] App opened from terminated state notification: ${initialMessage.notification?.title}');
        final data = initialMessage.data;
        String? serviceRequestId = data['serviceRequestId'] as String?;
        String? serviceRequestNumber = data['serviceRequestNumber'] as String?;

        if (serviceRequestId == null && data['clickAction'] != null) {
          final clickAction = data['clickAction'] as String;
          final uriParts = clickAction.split('/');
          if (uriParts.isNotEmpty) {
            final lastPart = uriParts.last;
            if (lastPart.length >= 32) {
              serviceRequestId = lastPart;
            }
          }
        }

        if (serviceRequestNumber == null) {
          final sbrRegex = RegExp(r'\bSBR\d+\b');
          final title = initialMessage.notification?.title ?? '';
          final body = initialMessage.notification?.body ?? '';
          final match = sbrRegex.firstMatch(title) ?? sbrRegex.firstMatch(body);
          if (match != null) {
            serviceRequestNumber = match.group(0);
          }
        }

        if (serviceRequestId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            appRouter.push('/order_tracking', extra: serviceRequestId);
          });
        } else if (serviceRequestNumber != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            appRouter.push('/order_tracking', extra: serviceRequestNumber);
          });
        }
      }

      // Get and print the FCM token immediately during init
      final token = await FirebaseMessaging.instance.getToken();
      print('[NOTIF_DEBUG] ✅ FCM Token: $token');

      // Set foreground presentation options for iOS
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );

      // Listen to foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('[NOTIF_DEBUG] 🔔 FOREGROUND MESSAGE RECEIVED!');
        print('[NOTIF_DEBUG]   Title: ${message.notification?.title}');
        print('[NOTIF_DEBUG]   Body: ${message.notification?.body}');
        print('[NOTIF_DEBUG]   Data: ${message.data}');

        RemoteNotification? notification = message.notification;

        if (notification != null) {
          print('[NOTIF_DEBUG] Showing local notification...');
          _flutterLocalNotificationsPlugin.show(
            id: notification.hashCode,
            title: notification.title,
            body: notification.body,
            notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                'high_importance_channel_v3',
                'High Importance Notifications',
                channelDescription:
                    'This channel is used for important notifications.',
                icon: 'ic_notification',
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            payload: jsonEncode(message.data),
          );
          print('[NOTIF_DEBUG] ✅ Local notification show() called');
        } else {
          print('[NOTIF_DEBUG] ⚠️ notification object is null — data-only message?');
        }
      });
      print('[NOTIF_DEBUG] ✅ Foreground message listener registered');

      // Handle message clicks when app is opened from a notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('[NOTIF_DEBUG] User tapped on notification: ${message.notification?.title}');
        final data = message.data;
        String? serviceRequestId = data['serviceRequestId'] as String?;
        String? serviceRequestNumber = data['serviceRequestNumber'] as String?;

        if (serviceRequestId == null && data['clickAction'] != null) {
          final clickAction = data['clickAction'] as String;
          final uriParts = clickAction.split('/');
          if (uriParts.isNotEmpty) {
            final lastPart = uriParts.last;
            if (lastPart.length >= 32) {
              serviceRequestId = lastPart;
            }
          }
        }

        if (serviceRequestNumber == null) {
          final sbrRegex = RegExp(r'\bSBR\d+\b');
          final title = message.notification?.title ?? '';
          final body = message.notification?.body ?? '';
          final match = sbrRegex.firstMatch(title) ?? sbrRegex.firstMatch(body);
          if (match != null) {
            serviceRequestNumber = match.group(0);
          }
        }

        if (serviceRequestId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            appRouter.push('/order_tracking', extra: serviceRequestId);
          });
        } else if (serviceRequestNumber != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            appRouter.push('/order_tracking', extra: serviceRequestNumber);
          });
        }
      });

      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        print('[NOTIF_DEBUG] 🔄 FCM Token REFRESHED: $newToken');
      });

      print('[NOTIF_DEBUG] ✅✅✅ Push notification service fully initialized');
    } catch (e, stackTrace) {
      _isFirebaseInitialized = false;
      print('[NOTIF_DEBUG] ❌ INITIALIZATION FAILED: $e');
      print('[NOTIF_DEBUG] ❌ Stack trace: $stackTrace');
    }
  }

  /// Gets the Firebase Cloud Messaging device token with a fallback.
  Future<String?> getDeviceToken() async {
    if (!_isFirebaseInitialized) {
      developer.log(
        'Firebase not initialized. Returning null device token.',
        name: 'PushNotificationService',
      );
      return null;
    }

    try {
      // On iOS, it's highly recommended to retrieve the APNs token first before getting the FCM token.
      if (Platform.isIOS) {
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken == null) {
          developer.log(
            'APNs Token is null. The FCM token may fail to fetch or be invalid.',
            name: 'PushNotificationService',
          );
          // We can delay briefly to allow APNs to register, though usually it happens automatically.
          await Future.delayed(const Duration(seconds: 2));
        } else {
          developer.log(
            'APNs Token successfully retrieved.',
            name: 'PushNotificationService',
          );
        }
      }

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        developer.log(
          'Retrieved FCM Device Token successfully: $token',
          name: 'PushNotificationService',
        );
        print(
          '\n\n========== FCM DEVICE TOKEN ==========\n$token\n======================================\n\n',
        );
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
      developer.log(
        'Failed to fetch package info version. Returning default app version.',
        name: 'PushNotificationService',
        error: e,
      );
    }
    return '1.0.0';
  }
}
