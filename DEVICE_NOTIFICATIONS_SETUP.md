# Device Push Notifications Setup Guide

## Issue Fixed
✅ Removed broken client-side FCM sending code  
✅ Cloud Functions are now properly configured to send device notifications  
✅ Client-side is properly listening to incoming FCM messages

## How It Works Now

1. **Admin approves password reset** → Creates notification in Firestore
2. **Cloud Function triggers** → Reads employee's FCM token from Firestore
3. **Push notification sent to device** → Firebase Cloud Messaging delivers it
4. **Device displays notification** → Even if the app is closed/backgrounded
5. **User taps notification** → App opens with notification data

## Steps to Enable Device Notifications

### 1. Upgrade Firebase Project to Blaze Plan

Push notifications require Firebase Cloud Functions, which need a **Blaze (pay-as-you-go) plan**.

**Steps:**
1. Go to: https://console.firebase.google.com/project/scottenex-attendance/usage/details
2. Click "Upgrade to Blaze"
3. Set up your billing information

### 2. Deploy Cloud Functions

After upgrading to Blaze plan, run:

```bash
cd functions
npm run deploy
```

This will deploy two functions:
- `sendPasswordResetNotification`: Sends push notifications when a password reset is approved
- `sendBroadcastNotification`: Sends notifications to multiple users at once

### 3. Test the Setup

1. **On Employee Device:**
   - Install the app
   - Login to get FCM token (logged in console)
   - Go to employee dashboard
   - Keep the app open

2. **On Admin Device/Dashboard:**
   - Approve a password reset request for that employee
   - Check employee's device for push notification

3. **Test Background Notification:**
   - Close the app on employee device
   - Admin approves another password reset
   - Notification should appear even with app closed

## Notification Flow Diagram

```
Admin approves request
           ↓
notification document created in Firestore
           ↓
Cloud Function triggers (sendPasswordResetNotification)
           ↓
Function gets employee FCM token from /users/{uid}/fcmToken
           ↓
Sends push notification via Firebase Cloud Messaging
           ↓
Device receives notification
           ↓
Notification displayed on device
           ↓
User taps notification (optional)
           ↓
App opens with notification data
```

## Files Modified

1. **lib/services/password_reset_notification_service.dart**
   - Removed broken `sendPushNotification()` method
   - Kept `sendPasswordResetNotification()` which creates Firestore doc (triggers Cloud Function)

2. **lib/screens/admin/password_approvals_screen.dart**
   - Removed client-side FCM token lookup
   - Removed broken FCM sending code
   - Now only creates notification doc (Cloud Function handles the rest)

3. **functions/index.js**
   - Fixed indentation issues
   - Ready for deployment

## What Each Notification Type Includes

### Password Reset Approved
- **Title:** "Password Reset Approved"
- **Body:** Notification message
- **Data:**
  - `type`: "password_reset_approved"
  - `resetLink`: Password reset link
  - `recipientEmail`: Employee email
  - `recipientName`: Employee name
  - `notificationId`: Firestore message ID

## Troubleshooting

### Notifications not appearing?

1. **Check Cloud Functions are deployed:**
   ```bash
   firebase functions:list
   ```
   Should show `sendPasswordResetNotification` and `sendBroadcastNotification`

2. **Check FCM token is saved:**
   - Go to Firebase Console
   - Firestore → Collection `users` → Find your user document
   - Check if `fcmToken` field exists and has a value

3. **Check permissions on device:**
   - iOS: User must grant notification permission in app
   - Android: Check notification settings for the app

4. **View Cloud Function logs:**
   ```bash
   firebase functions:log
   ```

## Additional Notes

- FCM tokens are automatically saved when users login
- Tokens are updated on each login to stay current
- If a user has no FCM token, the notification is silently skipped (logged in Cloud Function)
- Notifications work across all platforms: Android, iOS, Web, macOS, Linux, Windows

## Next Steps (Future Enhancement)

To enhance the notification system, you can:

1. Add deep linking to navigate directly to password reset screen
2. Implement notification categories for different types of notifications
3. Add notification sounds and vibration patterns
4. Implement notification actions (e.g., "Set Password" button in notification)
5. Add expiry to old notifications
