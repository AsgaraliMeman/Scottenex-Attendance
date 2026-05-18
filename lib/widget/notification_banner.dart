import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scottenex_attendance/services/password_reset_notification_service.dart';
import 'package:scottenex_attendance/utils/app_colors.dart';

class NotificationBanner extends StatelessWidget {
  final String userId;

  const NotificationBanner({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    // Debug: Check if userId is empty
    if (userId.isEmpty) {
      debugPrint('⚠️ NotificationBanner: userId is empty!');
      return const SizedBox.shrink();
    }

    debugPrint(
      '📢 NotificationBanner: Listening for notifications from userId: $userId',
    );

    return StreamBuilder<QuerySnapshot>(
      stream: PasswordResetNotificationService.getUserNotifications(userId),
      builder: (context, snapshot) {
        // Debug stream states
        if (snapshot.connectionState == ConnectionState.waiting) {
          debugPrint('⏳ NotificationBanner: Waiting for stream...');
          return const SizedBox.shrink();
        }

        if (snapshot.hasError) {
          debugPrint('❌ NotificationBanner: Stream error: ${snapshot.error}');
          return const SizedBox.shrink();
        }

        if (!snapshot.hasData) {
          debugPrint('⚠️ NotificationBanner: No data from stream');
          return const SizedBox.shrink();
        }

        final docs = snapshot.data!.docs;
        debugPrint(
          '📬 NotificationBanner: Got ${docs.length} total notifications',
        );

        if (docs.isEmpty) {
          debugPrint('✅ NotificationBanner: No notifications (empty)');
          return const SizedBox.shrink();
        }

        final unreadNotifications = docs
            .where((doc) => doc['read'] != true)
            .toList();
        debugPrint(
          '📌 NotificationBanner: ${unreadNotifications.length} unread notifications',
        );

        if (unreadNotifications.isEmpty) {
          debugPrint('✅ NotificationBanner: All notifications are read');
          return const SizedBox.shrink();
        }

        final notifications = unreadNotifications;

        return Column(
          children: notifications.where((doc) => doc['read'] != true).map((
            doc,
          ) {
            final notificationData = doc.data() as Map<String, dynamic>;
            final type = notificationData['type'] ?? '';
            final title = notificationData['title'] ?? '';
            final message = notificationData['message'] ?? '';
            final resetLink = notificationData['resetLink'] ?? '';

            if (type == 'password_reset_approved') {
              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  border: Border.all(color: AppColors.accent, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.accent,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                message,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _markAsRead(userId, doc.id);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _openPasswordResetLink(context, resetLink);
                              _markAsRead(userId, doc.id);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.black,
                            ),
                            child: const Text('Set New Password'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          }).toList(),
        );
      },
    );
  }

  void _markAsRead(String uid, String notificationId) {
    PasswordResetNotificationService.markNotificationAsRead(
      uid,
      notificationId,
    );
  }

  void _openPasswordResetLink(BuildContext context, String link) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Password Reset Instructions'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your password reset request has been approved. Follow these steps:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              const Text(
                '1. Copy the link below\n'
                '2. Open it in your browser\n'
                '3. Enter your official email address\n'
                '4. Follow the password reset instructions',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reset Link:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      link,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        wordSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: link));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Link copied to clipboard!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Copy Link'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
