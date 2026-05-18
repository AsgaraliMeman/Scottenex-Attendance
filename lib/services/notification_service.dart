import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  /// Initialize Firebase Messaging
  static Future<void> initialize() async {
    try {
      // Request user permission for iOS
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint(
        'User granted notification permission: ${settings.authorizationStatus}',
      );

      // Handle foreground messages (all platforms)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        debugPrint('Message data: ${message.data}');

        if (message.notification != null) {
          debugPrint(
            'Message also contained a notification: ${message.notification}',
          );
          _handleNotification(message);
        }
      });

      // Handle background message
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle notification tap (iOS)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Message opened from background: ${message.data}');
        _handleNotificationTap(message);
      });

      // Check if app was opened from notification
      final RemoteMessage? initialMessage =
          await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      // Get the token
      String? token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');
    } catch (e) {
      debugPrint('Error initializing Firebase Messaging: $e');
      rethrow;
    }
  }

  /// Handle notification when it arrives in foreground
  static void _handleNotification(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] ?? '';

    debugPrint('Handling notification of type: $type');

    if (type == 'password_reset_approved') {
      // Trigger refresh of notifications in the UI
      // This can be done via a stream, event bus, or provider
      debugPrint('Password reset notification received');
    }
  }

  /// Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] ?? '';
    final resetLink = data['resetLink'] ?? '';

    debugPrint('Notification tapped - Type: $type, Link: $resetLink');

    // Navigate to password reset screen or open link
    if (type == 'password_reset_approved' && resetLink.isNotEmpty) {
      // TODO: Implement deep linking to password reset screen
      debugPrint('Opening password reset link: $resetLink');
    }
  }

  /// Get FCM Token
  static Future<String?> getToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Delete token (for logout)
  static Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      debugPrint('FCM token deleted');
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
    }
  }
}

/// Handle notification when app is in background/terminated
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
  debugPrint('Message data: ${message.data}');
  debugPrint('Message notification: ${message.notification}');
}
