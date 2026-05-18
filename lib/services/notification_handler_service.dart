import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

/// Handles all Firebase Cloud Messaging and local notification setup
/// This service manages:
/// - FCM initialization and permissions
/// - Local notification channel creation
/// - Foreground message handling
/// - Background message handling
/// - Notification tap handling
class NotificationHandlerService {
  static final NotificationHandlerService _instance =
      NotificationHandlerService._internal();

  factory NotificationHandlerService() {
    return _instance;
  }

  NotificationHandlerService._internal();

  /// Firebase Messaging instance
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  /// Flutter Local Notifications plugin
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Flag to track if notification service is initialized
  static bool _isInitialized = false;

  /// Initialize all notification services
  /// This should be called in main.dart before runApp()
  static Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('📢 Notification service already initialized');
      return;
    }

    try {
      debugPrint('📢 Initializing notification service...');

      // Step 1: Create Android notification channel (required for Android 8+)
      await _createAndroidNotificationChannel();

      // Step 2: Initialize flutter_local_notifications
      await _initializeLocalNotifications();

      // Step 3: Request notification permissions
      await _requestNotificationPermissions();

      // Step 4: Get and store FCM token
      await _initializeFCMToken();

      // Step 5: Set up foreground message handler
      _setupForegroundMessageHandler();

      // Step 6: Set up background message handler (must be top-level function)
      // This is done separately in main.dart

      _isInitialized = true;
      debugPrint('✅ Notification service initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing notification service: $e');
      rethrow;
    }
  }

  /// Create Android notification channel (required for Android 8+)
  /// High importance channel allows notifications to appear with sound and heads-up
  static Future<void> _createAndroidNotificationChannel() async {
    try {
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin == null) {
        debugPrint('⚠️ Android notifications not available on this platform');
        return;
      }

      // Create high importance channel for password reset notifications
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'password_reset',
          'Password Reset Notifications',
          description:
              'Notifications for password reset requests approved by admin',
          importance: Importance.max,
          enableVibration: true,
          enableLights: true,
          showBadge: true,
        ),
      );

      debugPrint('✅ Android notification channel created');
    } catch (e) {
      debugPrint('❌ Error creating Android notification channel: $e');
      rethrow;
    }
  }

  /// Initialize flutter_local_notifications plugin
  /// This is required to display local notifications on Android and iOS
  static Future<void> _initializeLocalNotifications() async {
    try {
      const AndroidInitializationSettings androidInitSettings =
          AndroidInitializationSettings(
            '@mipmap/ic_launcher', // App icon
          );

      const DarwinInitializationSettings iosInitSettings =
          DarwinInitializationSettings(
            requestSoundPermission: true,
            requestBadgePermission: true,
            requestAlertPermission: true,
          );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidInitSettings,
        iOS: iosInitSettings,
      );

      // Initialize the plugin
      await _flutterLocalNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _handleNotificationTap,
        onDidReceiveBackgroundNotificationResponse: _handleNotificationTap,
      );

      debugPrint('✅ Local notifications initialized');
    } catch (e) {
      debugPrint('❌ Error initializing local notifications: $e');
      rethrow;
    }
  }

  /// Request notification permissions from user
  /// On iOS 13+, this shows the permission prompt
  /// On Android 13+, this requests POST_NOTIFICATIONS permission
  static Future<void> _requestNotificationPermissions() async {
    try {
      // Request iOS permissions
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Request Android permissions (via flutter_local_notifications)
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      await androidPlugin?.requestNotificationsPermission();

      debugPrint('✅ Notification permissions requested');
    } catch (e) {
      debugPrint('⚠️ Error requesting notification permissions: $e');
      // Don't rethrow - permissions might not be available on all platforms
    }
  }

  /// Get and store FCM token for this device
  /// The token is saved to Firestore by the auth provider
  static Future<void> _initializeFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();

      if (token != null) {
        debugPrint('🔑 FCM Token obtained: ${token.substring(0, 20)}...');
        // Token will be saved to Firestore by the auth provider on login
      } else {
        debugPrint('⚠️ Failed to get FCM token');
      }
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      // Don't rethrow - app can continue without token
    }
  }

  /// Set up handler for foreground messages
  /// This displays a notification even when the app is in foreground
  static void _setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📬 Foreground message received');
      debugPrint('   Title: ${message.notification?.title}');
      debugPrint('   Body: ${message.notification?.body}');
      debugPrint('   Data: ${message.data}');

      // Display the notification in the foreground using local notifications
      _displayLocalNotification(message);
    });

    debugPrint('✅ Foreground message handler set up');
  }

  /// Display a local notification
  /// Used for showing notifications when app is in foreground
  static Future<void> _displayLocalNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      if (notification == null) return;

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'password_reset',
            'Password Reset Notifications',
            channelDescription:
                'Notifications for password reset requests approved by admin',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            sound: RawResourceAndroidNotificationSound('notification'),
            playSound: true,
            enableVibration: true,
            fullScreenIntent: true,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        sound: 'notification.aiff',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Show the notification
      await _flutterLocalNotificationsPlugin.show(
        message.hashCode,
        notification.title,
        notification.body,
        notificationDetails,
        payload: _encodeNotificationPayload(message.data),
      );

      debugPrint('✅ Local notification displayed');
    } catch (e) {
      debugPrint('❌ Error displaying local notification: $e');
    }
  }

  /// Handle notification tap (foreground and background)
  static void _handleNotificationTap(
    NotificationResponse notificationResponse,
  ) {
    debugPrint('👆 Notification tapped');

    final payload = notificationResponse.payload;
    if (payload == null || payload.isEmpty) {
      debugPrint('   No payload found');
      return;
    }

    final data = _decodeNotificationPayload(payload);
    final type = data['type'] ?? '';
    final resetLink = data['resetLink'] ?? '';

    debugPrint('   Type: $type');
    debugPrint('   Reset Link: $resetLink');

    // Handle different notification types
    if (type == 'password_reset_approved' && resetLink.isNotEmpty) {
      _openPasswordResetLink(resetLink);
    }
  }

  /// Open password reset link in browser
  static Future<void> _openPasswordResetLink(String resetLink) async {
    try {
      final Uri url = Uri.parse(resetLink);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        debugPrint('✅ Password reset link opened: $resetLink');
      } else {
        debugPrint('❌ Could not launch password reset link: $resetLink');
      }
    } catch (e) {
      debugPrint('❌ Error opening password reset link: $e');
    }
  }

  /// Encode notification data to string payload
  static String _encodeNotificationPayload(Map<String, dynamic> data) {
    return data.entries.map((e) => '${e.key}=${e.value}').join('&');
  }

  /// Decode notification string payload to map
  static Map<String, String> _decodeNotificationPayload(String payload) {
    final result = <String, String>{};
    payload.split('&').forEach((pair) {
      final parts = pair.split('=');
      if (parts.length == 2) {
        result[parts[0]] = parts[1];
      }
    });
    return result;
  }

  /// Get FCM token (can be called by auth provider or other services)
  static Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Delete token (called on logout)
  static Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      debugPrint('✅ FCM token deleted on logout');
    } catch (e) {
      debugPrint('❌ Error deleting FCM token: $e');
    }
  }

  /// Show a test notification (for testing purposes)
  static Future<void> showTestNotification({
    String title = 'Test Notification',
    String body = 'This is a test notification from Scottenex Attendance',
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'password_reset',
            'Password Reset Notifications',
            channelDescription:
                'Notifications for password reset requests approved by admin',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            fullScreenIntent: true,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        notificationDetails,
      );

      debugPrint('✅ Test notification displayed');
    } catch (e) {
      debugPrint('❌ Error displaying test notification: $e');
    }
  }
}

/// Background message handler (must be a top-level function)
/// This is called when a message is received while the app is in background/terminated
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📬 Background message received');
  debugPrint('   Title: ${message.notification?.title}');
  debugPrint('   Body: ${message.notification?.body}');
  debugPrint('   Data: ${message.data}');

  // Firebase Cloud Messaging automatically displays notifications
  // in the background/terminated state if they have notification payload
}
