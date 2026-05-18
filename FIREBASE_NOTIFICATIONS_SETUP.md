# Firebase Push Notifications Setup - Complete Guide

## Overview

This guide covers the complete Firebase Cloud Messaging (FCM) and local notifications setup for the Scottenex Attendance Flutter app. The system handles notifications in all app states:

- **Foreground** (app open): Local notification with sound/vibration
- **Background** (app minimized): FCM handles display
- **Terminated** (app closed): FCM handles display

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  Firebase Cloud (Backend)               │
│  - Cloud Functions: sendPasswordResetNotification       │
│  - Sends FCM messages to device FCM token              │
└──────────────────┬──────────────────────────────────────┘
                   │ FCM Message
                   ▼
┌─────────────────────────────────────────────────────────┐
│            Device (Android/iOS/Web)                     │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Firebase Cloud Messaging (FCM)                  │  │
│  │  - Receives notification from cloud             │  │
│  │  - Routes to app or displays directly           │  │
│  └──────────────────┬───────────────────────────────┘  │
│                     │                                    │
│  ┌──────────────────▼───────────────────────────────┐  │
│  │  Flutter App                                     │  │
│  │  ┌─────────────────────────────────────────┐    │  │
│  │  │ NotificationHandlerService              │    │  │
│  │  │ - Initializes FCM                       │    │  │
│  │  │ - Creates notification channels         │    │  │
│  │  │ - Handles foreground messages           │    │  │
│  │  │ - Shows local notifications             │    │  │
│  │  └─────────────────────────────────────────┘    │  │
│  │                                                  │  │
│  │  ┌─────────────────────────────────────────┐    │  │
│  │  │ flutter_local_notifications             │    │  │
│  │  │ - Displays notification in foreground   │    │  │
│  │  │ - Handles notification taps             │    │  │
│  │  └─────────────────────────────────────────┘    │  │
│  └──────────────────────────────────────────────────┘  │
│                     │                                    │
│                     ▼                                    │
│           Device Notification Tray                      │
└─────────────────────────────────────────────────────────┘
```

## Files Created/Modified

### 1. **lib/services/notification_handler_service.dart** (NEW)
Complete notification handler with:
- FCM initialization
- Android notification channel creation
- Local notification setup
- Foreground message handling
- Background message handler
- Notification tap handling
- FCM token management

### 2. **lib/main.dart** (MODIFIED)
Added:
- Import `notification_handler_service.dart` and `firebase_messaging`
- Call `NotificationHandlerService.initialize()` after Firebase init
- Register background message handler
- Proper initialization order

### 3. **lib/providers/auth_provider.dart** (MODIFIED)
Updated:
- Changed from `NotificationService` to `NotificationHandlerService`
- Updated `_saveFCMToken()` to use new handler
- Updated `signOut()` to delete token properly
- Removed redundant notification initialization

### 4. **pubspec.yaml** (MODIFIED)
Added:
- `flutter_local_notifications: ^17.1.0` - For foreground notifications
- Placed after `firebase_messaging` dependency

### 5. **android/app/src/main/AndroidManifest.xml** (MODIFIED)
Enhanced:
- Better comments explaining each permission
- POST_NOTIFICATIONS permission (already present)
- Default notification channel ID configuration
- All required permissions for notifications

## Notification Flow - Password Reset Example

```
1. Admin approves password reset request
   │
   └─► Admin Dashboard (password_approvals_screen.dart)
       │
       └─► Creates document in Firestore
           /notifications/{employeeUid}/messages/{messageId}
           │
           └─► Cloud Function triggers
               (functions/index.js - sendPasswordResetNotification)
               │
               ├─► Get employee FCM token from Firestore
               ├─► Create notification payload
               └─► Send via Firebase Cloud Messaging
                   │
                   ▼
2. Employee's device receives FCM message
   │
   ├─► If app is OPEN (Foreground)
   │   │
   │   └─► NotificationHandlerService.firebaseMessagingBackgroundHandler()
   │       │
   │       └─► Shows local notification via flutter_local_notifications
   │           │
   │           └─► User sees notification with sound/vibration
   │
   ├─► If app is CLOSED (Background/Terminated)
   │   │
   │   └─► FCM automatically displays notification
   │       │
   │       └─► Notification appears in system tray
   │
   └─► User taps notification
       │
       └─► _handleNotificationTap() called
           │
           └─► Navigate to password reset screen (TODO: implement deep linking)
```

## Setup Steps for Development

### Step 1: Get Dependencies
```bash
cd e:\Scottenex_Attendance\scottenex_attendence
flutter pub get
```

### Step 2: Ensure Firebase Project is Blaze Plan
Required for Cloud Functions to send notifications:
- Go to: https://console.firebase.google.com/project/scottenex-attendance/usage/details
- Upgrade to Blaze (pay-as-you-go) plan
- Then deploy Cloud Functions:
  ```bash
  cd functions
  npm run deploy
  ```

### Step 3: Build the App
```bash
flutter clean
flutter pub get
flutter build apk    # For Android
flutter build ios    # For iOS
flutter build web    # For Web
```

### Step 4: Test the Setup

#### Test Foreground Notifications
1. Install app on device/emulator
2. Login with employee account
3. On admin device/dashboard, approve a password reset request
4. Employee's app (if open) should show notification immediately
5. Notification should play sound and vibrate

#### Test Background Notifications
1. Install app on device
2. Login with employee account
3. Minimize/background the app
4. On admin device, approve a password reset request
5. Notification should appear in system tray even with app backgrounded

#### Test Terminated Notifications
1. Install app on device
2. Login with employee account
3. Force quit the app
4. On admin device, approve a password reset request
5. Notification should appear in system tray
6. Tap notification - app opens from notification

## Notification States and Handling

### Foreground (App Open)
```
FCM Message → NotificationHandlerService._setupForegroundMessageHandler()
           → _displayLocalNotification()
           → flutter_local_notifications shows notification
           → User sees/hears notification
```

**Files Involved:**
- `lib/services/notification_handler_service.dart` (lines 113-131)
- `lib/services/notification_handler_service.dart` (lines 133-170)

### Background (App Minimized)
```
FCM Message → firebaseMessagingBackgroundHandler() (top-level function)
           → FCM automatically displays notification
           → Notification appears in system tray
           → User can tap to open app
```

**Files Involved:**
- `lib/services/notification_handler_service.dart` (lines 238-247)
- Android: Handled by FCM native implementation

### Terminated (App Closed)
```
FCM Message → Device receives notification via FCM
           → FCM stores notification until app launches
           → Notification appears in system tray
           → User can tap to open app
           → App launches and processes notification
```

**Files Involved:**
- Cloud Functions (backend)
- Android: Built-in FCM handling

## Notification Payload Structure

When password reset is approved, the notification includes:

```json
{
  "notification": {
    "title": "Password Reset Approved",
    "body": "Your password reset request has been approved. Tap to set a new password."
  },
  "data": {
    "type": "password_reset_approved",
    "resetLink": "https://scottenex-attendance.firebaseapp.com/reset-password?email=...",
    "recipientEmail": "employee@example.com",
    "recipientName": "Employee Name",
    "notificationId": "messageId"
  },
  "android": {
    "priority": "high",
    "notification": {
      "sound": "default",
      "channelId": "password_reset"
    }
  },
  "apns": {
    "headers": {
      "apns-priority": "10"
    },
    "payload": {
      "aps": {
        "sound": "default",
        "badge": 1
      }
    }
  }
}
```

## Android Notification Channel

**Channel ID:** `password_reset`
**Name:** `Password Reset Notifications`
**Importance:** `MAX` (highest priority)
**Features:**
- Sound enabled
- Vibration enabled
- Badge enabled
- Shows as heads-up notification

Created in: `lib/services/notification_handler_service.dart` (lines 65-81)

## Permissions Explained

### Android Permissions (android/app/src/main/AndroidManifest.xml)

| Permission | Purpose | Minimum API |
|-----------|---------|------------|
| `INTERNET` | Required for Firebase Cloud Messaging | All |
| `POST_NOTIFICATIONS` | Required to send notifications | Android 13+ |
| `SCHEDULE_EXACT_ALARM` | Optional, for scheduled notifications | Android 12+ |

### Runtime Permissions (Flutter)

Requested in `NotificationHandlerService._requestNotificationPermissions()`:

| Platform | Permission | Impact |
|----------|-----------|--------|
| **iOS** | Alert | Shows notification prompt |
| **iOS** | Sound | Plays notification sound |
| **iOS** | Badge | Shows badge on app icon |
| **Android 13+** | POST_NOTIFICATIONS | Shows notifications |

## Troubleshooting

### Issue: Notifications not appearing in foreground
**Solution:**
1. Check `NotificationHandlerService.initialize()` is called in main.dart
2. Verify `FlutterLocalNotificationsPlugin` is properly initialized
3. Check Android notification channel is created
4. Enable debug logs: `debugPrint()` statements throughout service

**Debug:** Search for "✅ Local notifications initialized" in logs

### Issue: Notifications not appearing in background
**Solution:**
1. Verify Cloud Functions are deployed: `firebase functions:list`
2. Check FCM token is saved in Firestore: Firebase Console → Firestore → users/{uid}/fcmToken
3. Check Cloud Function logs: `firebase functions:log`
4. Ensure Android API 21+ for notification compatibility

**Debug:** Check Cloud Function logs for error messages

### Issue: Notifications not appearing when app is terminated
**Solution:**
1. Ensure app was properly quit (not just backgrounded)
2. Check notification was sent while app was closed
3. Verify FCM token exists and is valid
4. Clear app cache and data, then reinstall

**Debug:** Check Cloud Function logs

### Issue: Wrong notification channel or sound
**Solution:**
1. Verify channel ID matches in multiple places:
   - AndroidManifest.xml: `password_reset`
   - notification_handler_service.dart: `password_reset`
2. Clear app data: `adb shell pm clear com.scottenex.attendance`
3. Reinstall app
4. Check Android version (API 26+ for channels)

**Debug:** Channel created logs should appear at app startup

### Issue: FCM token not saved
**Solution:**
1. Verify `_saveFCMToken()` is called after login
2. Check user has write permission to `/users/{uid}` in Firestore
3. Verify FCM is initialized before token save
4. Check debug logs: "Got FCM token" and "FCM token saved successfully"

**Debug:** Look for "Attempting to get and save FCM token" in logs

## Common Issues and Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| Notifications silent/no sound | Notification channel not created | Reinstall app, check debug logs |
| Notification not vibrating | Vibration not enabled in channel | Check notification_handler_service.dart line 75 |
| App crashes on startup | NotificationHandlerService not initialized | Check main.dart initialization order |
| Foreground notification shows twice | Local notification + FCM both showing | This is correct - handled in code |
| Can't tap notification | Payload encoding wrong | Check _encodeNotificationPayload() |

## Performance Considerations

1. **FCM Initialization:** Done only once at app startup (singleton pattern)
2. **Local Notifications:** Only shown when app is in foreground
3. **Background Handler:** Top-level function, minimal overhead
4. **Token Management:** Saved on login, deleted on logout
5. **Memory:** Service uses weak references, doesn't keep app alive

## Security Considerations

1. **FCM Tokens:** Stored in Firestore, only accessed by Cloud Functions
2. **Notification Data:** Not encrypted (as per FCM design), only public data
3. **Permissions:** User grants at login (iOS) and runtime (Android 13+)
4. **Validation:** Cloud Functions verify user exists before sending
5. **Rate Limiting:** Cloud Functions limited to 10 concurrent instances

## Future Enhancements

1. **Deep Linking**
   - Implement navigation from notification tap
   - Pass resetLink to password reset screen
   - File: `lib/services/notification_handler_service.dart` (line 196)

2. **Notification Categories**
   - Add different notification channels for different types
   - Implement notification actions (approve/reject buttons)

3. **Notification History**
   - Keep notification history in app
   - Allow users to view past notifications
   - Implement in-app notification center

4. **Rich Notifications**
   - Add images/avatars to notifications
   - Big text for longer messages
   - Progress indicators for long operations

5. **Scheduled Notifications**
   - Use flutter_local_notifications for scheduled reminders
   - Implement notification scheduling

6. **Analytics**
   - Track notification delivery rates
   - Track notification tap rates
   - Measure notification effectiveness

## References

- [Firebase Cloud Messaging Documentation](https://firebase.flutter.dev/docs/messaging/overview)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [Android Notification Channels](https://developer.android.com/training/notify-user/channels)
- [Cloud Functions for Firebase](https://firebase.google.com/docs/functions)

## Testing Checklist

- [ ] FCM token saved after login
- [ ] Foreground notification shows with sound/vibration
- [ ] Background notification appears in system tray
- [ ] Terminated notification appears when app closes
- [ ] Notification tap opens app
- [ ] Logout deletes FCM token
- [ ] Admin can trigger notifications
- [ ] Employee receives notifications
- [ ] Multiple users get correct notifications
- [ ] Notification payload correctly decoded
