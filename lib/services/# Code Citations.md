# Code Citations

## License: unknown
https://github.com/mandarini/shop-start/blob/d4d75a0201e013ec13de27faed424fa57119b0d4/tutorial/Step06.md

```
## The Problem

Your Firestore security rules need to be updated to allow employees to submit password reset requests. Here are the **correct security rules** you need to add to your Firebase Console:

**Go to: Firebase Console → Firestore Database → Rules**

Replace your security rules with these:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Password reset requests - employees can create, admins can read/update
    match /password_reset_requests/{document=**} {
      allow create: if request.auth != null;
      allow read, update: if exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Notifications collection - only user
```


## License: unknown
https://github.com/mandarini/shop-start/blob/d4d75a0201e013ec13de27faed424fa57119b0d4/tutorial/Step06.md

```
## The Problem

Your Firestore security rules need to be updated to allow employees to submit password reset requests. Here are the **correct security rules** you need to add to your Firebase Console:

**Go to: Firebase Console → Firestore Database → Rules**

Replace your security rules with these:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Password reset requests - employees can create, admins can read/update
    match /password_reset_requests/{document=**} {
      allow create: if request.auth != null;
      allow read, update: if exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Notifications collection - only user
```


## License: unknown
https://github.com/mandarini/shop-start/blob/d4d75a0201e013ec13de27faed424fa57119b0d4/tutorial/Step06.md

```
## The Problem

Your Firestore security rules need to be updated to allow employees to submit password reset requests. Here are the **correct security rules** you need to add to your Firebase Console:

**Go to: Firebase Console → Firestore Database → Rules**

Replace your security rules with these:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Password reset requests - employees can create, admins can read/update
    match /password_reset_requests/{document=**} {
      allow create: if request.auth != null;
      allow read, update: if exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Notifications collection - only user
```


## License: unknown
https://github.com/mandarini/shop-start/blob/d4d75a0201e013ec13de27faed424fa57119b0d4/tutorial/Step06.md

```
## The Problem

Your Firestore security rules need to be updated to allow employees to submit password reset requests. Here are the **correct security rules** you need to add to your Firebase Console:

**Go to: Firebase Console → Firestore Database → Rules**

Replace your security rules with these:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Password reset requests - employees can create, admins can read/update
    match /password_reset_requests/{document=**} {
      allow create: if request.auth != null;
      allow read, update: if exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Notifications collection - only user
```


## License: unknown
https://github.com/mandarini/shop-start/blob/d4d75a0201e013ec13de27faed424fa57119b0d4/tutorial/Step06.md

```
## The Problem

Your Firestore security rules need to be updated to allow employees to submit password reset requests. Here are the **correct security rules** you need to add to your Firebase Console:

**Go to: Firebase Console → Firestore Database → Rules**

Replace your security rules with these:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Password reset requests - employees can create, admins can read/update
    match /password_reset_requests/{document=**} {
      allow create: if request.auth != null;
      allow read, update: if exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Notifications collection - only user
```


## License: unknown
https://github.com/mandarini/shop-start/blob/d4d75a0201e013ec13de27faed424fa57119b0d4/tutorial/Step06.md

```
## The Problem

Your Firestore security rules need to be updated to allow employees to submit password reset requests. Here are the **correct security rules** you need to add to your Firebase Console:

**Go to: Firebase Console → Firestore Database → Rules**

Replace your security rules with these:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Password reset requests - employees can create, admins can read/update
    match /password_reset_requests/{document=**} {
      allow create: if request.auth != null;
      allow read, update: if exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Notifications collection - only user
```


## License: unknown
https://github.com/mandarini/shop-start/blob/d4d75a0201e013ec13de27faed424fa57119b0d4/tutorial/Step06.md

```
## The Problem

Your Firestore security rules need to be updated to allow employees to submit password reset requests. Here are the **correct security rules** you need to add to your Firebase Console:

**Go to: Firebase Console → Firestore Database → Rules**

Replace your security rules with these:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Password reset requests - employees can create, admins can read/update
    match /password_reset_requests/{document=**} {
      allow create: if request.auth != null;
      allow read, update: if exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Notifications collection - only user
```


## License: unknown
https://github.com/YuiBlog/Ohtsuki/blob/7da537771c058bf422b896cc2129774f20987529/firestore.rules

```
## The Problem

Your Firestore security rules need to be updated to allow employees to submit password reset requests. Here are the **correct security rules** you need to add to your Firebase Console:

**Go to: Firebase Console → Firestore Database → Rules**

Replace your security rules with these:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Password reset requests - employees can create, admins can read/update
    match /password_reset_requests/{document=**} {
      allow create: if request.auth != null;
      allow read, update: if exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Notifications collection - only user can read their own
    match /notifications/{userId}/messages/{messageId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Users collection - basic access
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId || 
                      (request.auth != null && 
                       exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Attendance
```


## License: unknown
https://github.com/YuiBlog/Ohtsuki/blob/7da537771c058bf422b896cc2129774f20987529/firestore.rules

```
## The Problem

Your Firestore security rules need to be updated to allow employees to submit password reset requests. Here are the **correct security rules** you need to add to your Firebase Console:

**Go to: Firebase Console → Firestore Database → Rules**

Replace your security rules with these:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Password reset requests - employees can create, admins can read/update
    match /password_reset_requests/{document=**} {
      allow create: if request.auth != null;
      allow read, update: if exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Notifications collection - only user can read their own
    match /notifications/{userId}/messages/{messageId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Users collection - basic access
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId || 
                      (request.auth != null && 
                       exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Attendance
```


## License: unknown
https://github.com/DanimailEnglish/danimail-api/blob/e597234a91f226d7ae099c9775d6933cecefa0a9/firestore.rules

```
## The Problem

Your Firestore security rules need to be updated to allow employees to submit password reset requests. Here are the **correct security rules** you need to add to your Firebase Console:

**Go to: Firebase Console → Firestore Database → Rules**

Replace your security rules with these:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Password reset requests - employees can create, admins can read/update
    match /password_reset_requests/{document=**} {
      allow create: if request.auth != null;
      allow read, update: if exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Notifications collection - only user can read their own
    match /notifications/{userId}/messages/{messageId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Users collection - basic access
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId || 
                      (request.auth != null && 
                       exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Attendance collection
    match /attendance/{
```


## License: unknown
https://github.com/YuiBlog/Ohtsuki/blob/7da537771c058bf422b896cc2129774f20987529/firestore.rules

```
## The Problem

Your Firestore security rules need to be updated to allow employees to submit password reset requests. Here are the **correct security rules** you need to add to your Firebase Console:

**Go to: Firebase Console → Firestore Database → Rules**

Replace your security rules with these:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Password reset requests - employees can create, admins can read/update
    match /password_reset_requests/{document=**} {
      allow create: if request.auth != null;
      allow read, update: if exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Notifications collection - only user can read their own
    match /notifications/{userId}/messages/{messageId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Users collection - basic access
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId || 
                      (request.auth != null && 
                       exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Attendance
```


## License: unknown
https://github.com/DanimailEnglish/danimail-api/blob/e597234a91f226d7ae099c9775d6933cecefa0a9/firestore.rules

```
## The Problem

Your Firestore security rules need to be updated to allow employees to submit password reset requests. Here are the **correct security rules** you need to add to your Firebase Console:

**Go to: Firebase Console → Firestore Database → Rules**

Replace your security rules with these:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Password reset requests - employees can create, admins can read/update
    match /password_reset_requests/{document=**} {
      allow create: if request.auth != null;
      allow read, update: if exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Notifications collection - only user can read their own
    match /notifications/{userId}/messages/{messageId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Users collection - basic access
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId || 
                      (request.auth != null && 
                       exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Attendance collection
    match /attendance/{
```


## License: unknown
https://github.com/YuiBlog/Ohtsuki/blob/7da537771c058bf422b896cc2129774f20987529/firestore.rules

```
## The Problem

Your Firestore security rules need to be updated to allow employees to submit password reset requests. Here are the **correct security rules** you need to add to your Firebase Console:

**Go to: Firebase Console → Firestore Database → Rules**

Replace your security rules with these:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Password reset requests - employees can create, admins can read/update
    match /password_reset_requests/{document=**} {
      allow create: if request.auth != null;
      allow read, update: if exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Notifications collection - only user can read their own
    match /notifications/{userId}/messages/{messageId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Users collection - basic access
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId || 
                      (request.auth != null && 
                       exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Attendance
```


## License: unknown
https://github.com/DanimailEnglish/danimail-api/blob/e597234a91f226d7ae099c9775d6933cecefa0a9/firestore.rules

```
## The Problem

Your Firestore security rules need to be updated to allow employees to submit password reset requests. Here are the **correct security rules** you need to add to your Firebase Console:

**Go to: Firebase Console → Firestore Database → Rules**

Replace your security rules with these:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Password reset requests - employees can create, admins can read/update
    match /password_reset_requests/{document=**} {
      allow create: if request.auth != null;
      allow read, update: if exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Notifications collection - only user can read their own
    match /notifications/{userId}/messages/{messageId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Users collection - basic access
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId || 
                      (request.auth != null && 
                       exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Attendance collection
    match /attendance/{
```


## License: unknown
https://github.com/YuiBlog/Ohtsuki/blob/7da537771c058bf422b896cc2129774f20987529/firestore.rules

```
## The Problem

Your Firestore security rules need to be updated to allow employees to submit password reset requests. Here are the **correct security rules** you need to add to your Firebase Console:

**Go to: Firebase Console → Firestore Database → Rules**

Replace your security rules with these:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Password reset requests - employees can create, admins can read/update
    match /password_reset_requests/{document=**} {
      allow create: if request.auth != null;
      allow read, update: if exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Notifications collection - only user can read their own
    match /notifications/{userId}/messages/{messageId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Users collection - basic access
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId || 
                      (request.auth != null && 
                       exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Attendance
```


## License: unknown
https://github.com/DanimailEnglish/danimail-api/blob/e597234a91f226d7ae099c9775d6933cecefa0a9/firestore.rules

```
## The Problem

Your Firestore security rules need to be updated to allow employees to submit password reset requests. Here are the **correct security rules** you need to add to your Firebase Console:

**Go to: Firebase Console → Firestore Database → Rules**

Replace your security rules with these:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Password reset requests - employees can create, admins can read/update
    match /password_reset_requests/{document=**} {
      allow create: if request.auth != null;
      allow read, update: if exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Notifications collection - only user can read their own
    match /notifications/{userId}/messages/{messageId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Users collection - basic access
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId || 
                      (request.auth != null && 
                       exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Attendance collection
    match /attendance/{
```


## License: unknown
https://github.com/YuiBlog/Ohtsuki/blob/7da537771c058bf422b896cc2129774f20987529/firestore.rules

```
## The Problem

Your Firestore security rules need to be updated to allow employees to submit password reset requests. Here are the **correct security rules** you need to add to your Firebase Console:

**Go to: Firebase Console → Firestore Database → Rules**

Replace your security rules with these:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Password reset requests - employees can create, admins can read/update
    match /password_reset_requests/{document=**} {
      allow create: if request.auth != null;
      allow read, update: if exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Notifications collection - only user can read their own
    match /notifications/{userId}/messages/{messageId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Users collection - basic access
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId || 
                      (request.auth != null && 
                       exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Attendance
```


## License: unknown
https://github.com/DanimailEnglish/danimail-api/blob/e597234a91f226d7ae099c9775d6933cecefa0a9/firestore.rules

```
## The Problem

Your Firestore security rules need to be updated to allow employees to submit password reset requests. Here are the **correct security rules** you need to add to your Firebase Console:

**Go to: Firebase Console → Firestore Database → Rules**

Replace your security rules with these:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Password reset requests - employees can create, admins can read/update
    match /password_reset_requests/{document=**} {
      allow create: if request.auth != null;
      allow read, update: if exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Notifications collection - only user can read their own
    match /notifications/{userId}/messages/{messageId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Users collection - basic access
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId || 
                      (request.auth != null && 
                       exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Attendance collection
    match /attendance/{
```


## License: unknown
https://github.com/YuiBlog/Ohtsuki/blob/7da537771c058bf422b896cc2129774f20987529/firestore.rules

```
## The Problem

Your Firestore security rules need to be updated to allow employees to submit password reset requests. Here are the **correct security rules** you need to add to your Firebase Console:

**Go to: Firebase Console → Firestore Database → Rules**

Replace your security rules with these:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Password reset requests - employees can create, admins can read/update
    match /password_reset_requests/{document=**} {
      allow create: if request.auth != null;
      allow read, update: if exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Notifications collection - only user can read their own
    match /notifications/{userId}/messages/{messageId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Users collection - basic access
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId || 
                      (request.auth != null && 
                       exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Attendance
```


## License: unknown
https://github.com/DanimailEnglish/danimail-api/blob/e597234a91f226d7ae099c9775d6933cecefa0a9/firestore.rules

```
## The Problem

Your Firestore security rules need to be updated to allow employees to submit password reset requests. Here are the **correct security rules** you need to add to your Firebase Console:

**Go to: Firebase Console → Firestore Database → Rules**

Replace your security rules with these:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Password reset requests - employees can create, admins can read/update
    match /password_reset_requests/{document=**} {
      allow create: if request.auth != null;
      allow read, update: if exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Notifications collection - only user can read their own
    match /notifications/{userId}/messages/{messageId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Users collection - basic access
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId || 
                      (request.auth != null && 
                       exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Attendance collection
    match /attendance/{
```


## License: unknown
https://github.com/YuiBlog/Ohtsuki/blob/7da537771c058bf422b896cc2129774f20987529/firestore.rules

```
## The Problem

Your Firestore security rules need to be updated to allow employees to submit password reset requests. Here are the **correct security rules** you need to add to your Firebase Console:

**Go to: Firebase Console → Firestore Database → Rules**

Replace your security rules with these:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Password reset requests - employees can create, admins can read/update
    match /password_reset_requests/{document=**} {
      allow create: if request.auth != null;
      allow read, update: if exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Notifications collection - only user can read their own
    match /notifications/{userId}/messages/{messageId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Users collection - basic access
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId || 
                      (request.auth != null && 
                       exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Attendance collection
    match /attendance/{
```


## License: unknown
https://github.com/DanimailEnglish/danimail-api/blob/e597234a91f226d7ae099c9775d6933cecefa0a9/firestore.rules

```
## The Problem

Your Firestore security rules need to be updated to allow employees to submit password reset requests. Here are the **correct security rules** you need to add to your Firebase Console:

**Go to: Firebase Console → Firestore Database → Rules**

Replace your security rules with these:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Password reset requests - employees can create, admins can read/update
    match /password_reset_requests/{document=**} {
      allow create: if request.auth != null;
      allow read, update: if exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Notifications collection - only user can read their own
    match /notifications/{userId}/messages/{messageId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Users collection - basic access
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId || 
                      (request.auth != null && 
                       exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Attendance collection
    match /attendance/{
```

