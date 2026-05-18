# Password Reset Notification System Implementation

## Overview
Implemented a real-time notification system where employees receive notifications when their password reset requests are approved by admins. This includes in-app notifications with password reset links.

## Components Implemented

### 1. **Firebase Cloud Messaging Setup**
- Added `firebase_messaging: ^14.7.9` to `pubspec.yaml`
- Service initializes FCM and requests user permissions on app startup

### 2. **Files Created/Modified**

#### New Files:
- `lib/services/notification_service.dart` - Manages FCM initialization and token management
- `lib/services/password_reset_notification_service.dart` - Handles password reset notifications
- `lib/widget/notification_banner.dart` - UI widget to display notifications to employees

#### Modified Files:
- `lib/models/user_model.dart` - Added `fcmToken` field to store device token
- `lib/providers/auth_provider.dart` - Initialize FCM and save FCM tokens for users
- `lib/screens/admin/password_approvals_screen.dart` - Send notifications when password requests are approved
- `lib/screens/employee/employee_dashboard_screen.dart` - Display notifications to employees
- `pubspec.yaml` - Added firebase_messaging dependency

## How It Works

### 1. **FCM Token Generation & Storage**
When a user logs in:
- `AuthProvider._initializeAuth()` initializes `NotificationService`
- `NotificationService.getToken()` gets the device's unique FCM token
- Token is saved to Firestore under `users/{uid}/fcmToken`
- Token is updated on each login to keep it current

### 2. **Password Reset Approval Flow**
When admin approves a password reset request:
1. Admin clicks "Approve" on the request in Password Approvals screen
2. `_updateRequestStatus()` is called:
   - Updates request status to "approved"
   - Sends password reset email via Firebase Auth
   - Retrieves employee's UID and name
   - Creates a notification record in Firestore:
     ```
     /notifications/{employeeUid}/messages/{messageId}
     ```
   - Notification includes:
     - `type`: 'password_reset_approved'
     - `title`: 'Password Reset Approved'
     - `message`: Notification message
     - `resetLink`: Password reset link
     - `createdAt`: Timestamp
     - `read`: false (unread status)

### 3. **Employee Notification Display**
When employee opens the app:
1. `NotificationBanner` widget appears on employee dashboard
2. Listens to `notifications/{uid}/messages` collection
3. Displays unread notifications at the top of the dashboard
4. Shows:
   - Notification title and message
   - "Set New Password" button
5. Employee can:
   - Click button to view password reset link
   - Close notification (marks as read)

### 4. **Notification Lifecycle**
- **Created**: When admin approves the request
- **Displayed**: On employee's dashboard
- **Read**: When employee clicks or dismisses
- **Deleted**: Automatically cleaned up after reading

## Data Structure

### Firestore Collections

#### notifications/{userId}/messages
```json
{
  "type": "password_reset_approved",
  "title": "Password Reset Approved",
  "message": "Your password reset request has been approved...",
  "recipientUid": "uid",
  "recipientEmail": "employee@email.com",
  "recipientName": "Employee Name",
  "resetLink": "https://...",
  "createdAt": Timestamp,
  "read": false
}
```

#### password_reset_requests
```json
{
  "uid": "employee_uid",
  "email": "employee@email.com",
  "status": "approved",
  "requestedAt": Timestamp,
  "processedAt": Timestamp
}
```

#### users/{uid}
```json
{
  "email": "employee@email.com",
  "name": "Employee Name",
  "role": "employee",
  "fcmToken": "device_token_here",
  ...
}
```

## Security Considerations

1. **FCM Token Storage**: Tokens are stored per user and automatically updated on login
2. **Token Deletion**: Tokens are deleted when user logs out
3. **Firestore Rules**: Ensure employees can only read/write their own notifications
4. **Email Verification**: Only admins can approve password resets

## Firestore Security Rules (Recommended)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Notifications collection - only user can read their own
    match /notifications/{userId}/messages/{messageId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Password reset requests - only admins can manage
    match /password_reset_requests/{document=**} {
      allow read, write: if exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Users collection - updated by system
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId || 
                      (exists(/databases/$(database)/documents/users/$(request.auth.uid))
                       && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
  }
}
```

## Testing the Implementation

### Admin Side:
1. Log in as admin
2. Go to Password Approvals screen
3. Click "Approve" on a pending request
4. Verify:
   - Approval notification shown
   - Reset email sent
   - In-app notification created in Firestore

### Employee Side:
1. Log out and log in with employee account
2. Dashboard should show:
   - Notification banner at top (if any approved requests)
   - Employee can click "Set New Password" button
   - Can dismiss notification

## Future Enhancements

1. **Push Notifications**: Use Firebase Admin SDK to send actual push notifications
2. **Notification History**: Add page to view all past notifications
3. **Email Notifications**: Add email notification alongside in-app notification
4. **Rich Notifications**: Add images, buttons, and actions to notifications
5. **Notification Settings**: Allow employees to configure notification preferences
6. **Analytics**: Track notification delivery and engagement

## Testing Checklist

- [ ] Notification banner appears on employee dashboard
- [ ] Closing notification marks it as read
- [ ] Clicking "Set New Password" shows password reset link
- [ ] Multiple notifications stack correctly
- [ ] Notifications persist after app close and reopen
- [ ] Token updates on each login
- [ ] Token deleted on logout
- [ ] Admin approval triggers notification creation
- [ ] Password reset email sent correctly
- [ ] Firestore rules prevent unauthorized access
