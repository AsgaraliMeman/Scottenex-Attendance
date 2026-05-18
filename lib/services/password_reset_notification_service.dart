import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PasswordResetNotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Send password reset notification to employee
  /// This creates a notification record that the employee can listen to
  static Future<void> sendPasswordResetNotification({
    required String employeeUid,
    required String employeeEmail,
    required String employeeName,
    required String resetLink,
  }) async {
    try {
      debugPrint('📤 Sending notification to employee: $employeeUid');

      final notificationRef = await _firestore
          .collection('notifications')
          .doc(employeeUid)
          .collection('messages')
          .add({
            'type': 'password_reset_approved',
            'title': 'Password Reset Approved',
            'message':
                'Your password reset request has been approved. Click to set a new password.',
            'recipientUid': employeeUid,
            'recipientEmail': employeeEmail,
            'recipientName': employeeName,
            'resetLink': resetLink,
            'createdAt': Timestamp.now(),
            'read': false,
          });

      debugPrint('✅ Notification created with ID: ${notificationRef.id}');
      debugPrint(
        '   Path: notifications/$employeeUid/messages/${notificationRef.id}',
      );
    } catch (e) {
      debugPrint('❌ Error sending notification: $e');
      rethrow;
    }
  }

  /// Get notifications for a user
  static Stream<QuerySnapshot> getUserNotifications(String uid) {
    debugPrint('🔄 Setting up notification stream for user: $uid');
    return _firestore
        .collection('notifications')
        .doc(uid)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          debugPrint(
            '📨 Stream update for $uid: ${snapshot.docs.length} notifications',
          );
          return snapshot;
        });
  }

  /// Mark notification as read
  static Future<void> markNotificationAsRead(
    String uid,
    String notificationId,
  ) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(uid)
          .collection('messages')
          .doc(notificationId)
          .update({'read': true});
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Delete notification
  static Future<void> deleteNotification(
    String uid,
    String notificationId,
  ) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(uid)
          .collection('messages')
          .doc(notificationId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }


}
