import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/user_model.dart';
import '../services/notification_handler_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  UserModel? _userModel;
  bool _isLoading = true;

  User? get user => _user;

  User? get firebaseUser => _auth.currentUser;

  UserModel? get userModel => _userModel;

  bool get isLoading => _isLoading;

  AuthProvider() {
    _initializeAuth();
  }

  /// Initialize auth listener and sign out any existing session
  /// This ensures login screen is always shown on app startup
  void _initializeAuth() {
    // Notification service is initialized in main.dart before login
    // No need to initialize here

    // First, sign out any existing session without waiting
    // to ensure fresh login state
    _auth.signOut().catchError((e) {
      debugPrint('Error signing out on init: $e');
    });

    // Then set up auth state listener
    _auth.authStateChanges().listen((User? user) async {
      _user = user;

      if (user != null) {
        // Only load from Firestore if user model hasn't been set yet
        // (e.g., signInAdmin() sets it before this listener fires)
        if (_userModel == null) {
          await _loadUserData(user.uid);
        } else {
          debugPrint('User model already loaded, skipping Firestore read');
        }

        // Save FCM token for this user
        await _saveFCMToken(user.uid);
      } else {
        _userModel = null;
      }

      _isLoading = false;

      notifyListeners();
    });
  }

  Future<void> _loadUserData(String uid) async {
    try {
      debugPrint('Loading user data for UID: $uid, Email: ${_user?.email}');

      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        _userModel = UserModel.fromMap(doc.data()!, uid);
        debugPrint('User data found in Firestore - Role: ${_userModel?.role}');

        // IMPORTANT: If this is the admin email but role is wrong, fix it
        final isAdmin =
            _user!.email?.toLowerCase() == 'adminscottenex@gmail.com';

        if (isAdmin && _userModel!.role != 'admin') {
          debugPrint('Correcting admin role for ${_user!.email}');

          _userModel = _userModel!.copyWith(role: 'admin');

          // Update in Firestore
          await _firestore.collection('users').doc(uid).update({
            'role': 'admin',
          });
        }

        debugPrint('Final user role: ${_userModel?.role}');
      } else {
        debugPrint('User document not found by UID, searching by email...');

        final query = await _firestore
            .collection('users')
            .where('email', isEqualTo: _user!.email)
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          final data = query.docs.first.data();

          _userModel = UserModel.fromMap(data, uid);
          debugPrint('User data found by email - Role: ${_userModel?.role}');

          // IMPORTANT: If this is the admin email but role is wrong, fix it
          final isAdmin =
              _user!.email?.toLowerCase() == 'adminscottenex@gmail.com';

          if (isAdmin && _userModel!.role != 'admin') {
            debugPrint('Correcting admin role for ${_user!.email}');

            _userModel = _userModel!.copyWith(role: 'admin');

            // Update in Firestore
            await _firestore.collection('users').doc(uid).update({
              'role': 'admin',
            });
          }

          await _firestore
              .collection('users')
              .doc(uid)
              .set(_userModel!.toMap());
        } else {
          // Check if this is the admin email - if so, create as admin
          final isAdmin =
              _user!.email?.toLowerCase() == 'adminscottenex@gmail.com';

          debugPrint(
            'Creating new user - IsAdmin: $isAdmin, Email: ${_user!.email}',
          );

          _userModel = UserModel(
            uid: uid,
            email: _user!.email!,
            role: isAdmin ? 'admin' : 'employee',
            name: isAdmin ? 'Administrator' : '',
            isFirstLogin: true,
          );

          await _firestore
              .collection('users')
              .doc(uid)
              .set(_userModel!.toMap());

          debugPrint('New user created - Role: ${_userModel?.role}');
        }
      }
    } on FirebaseException catch (e) {
      // If Firestore access is denied, but user model already exists, keep it
      // This handles permission-denied errors gracefully
      if (e.code == 'permission-denied' && _userModel != null) {
        debugPrint(
          'Firestore permission denied, but keeping existing user model with role: ${_userModel?.role}',
        );
      } else if (e.code == 'permission-denied') {
        debugPrint(
          'Firestore permission denied and no user model available: $e',
        );
        // For admin users, create a default admin model if Firestore fails
        final isAdmin =
            _user?.email?.toLowerCase() == 'adminscottenex@gmail.com';
        if (isAdmin) {
          debugPrint(
            'Creating default admin model due to Firestore permission error',
          );
          _userModel = UserModel(
            uid: uid,
            email: _user!.email!,
            role: 'admin',
            name: 'Administrator',
            isFirstLogin: false,
          );
        }
      } else {
        debugPrint('Error loading user data: $e');
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  // ================= SIGN IN =================

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Just perform the Firebase authentication
      // The auth state listener will handle loading user data
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('User signed in: $email, UID: ${result.user?.uid}');
      // Don't set _isLoading to false here - let the listener handle it
      // when auth state changes
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Sign in error: ${e.code}');
      throw FirebaseAuthException(code: e.code, message: e.message);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Sign in unexpected error: $e');
      rethrow;
    }
  }

  // ================= ADMIN LOGIN =================

  Future<void> signInAdmin(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      debugPrint('Admin sign in attempt: $email');

      // Try standard Firebase sign in first
      try {
        await signIn(email, password);
        debugPrint('Admin found in Firebase, standard sign in used');
        return; // If successful, listener will handle the rest
      } on FirebaseAuthException catch (e) {
        // Only handle user-not-found case
        if (e.code != 'user-not-found') {
          debugPrint('Firebase sign in error: ${e.code}');
          rethrow; // Re-throw other Firebase errors
        }
        debugPrint('Admin not found in Firebase, checking Firestore');
      }

      // Handle the admin-specific user-not-found case
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Admin account not found in system.',
        );
      }

      final doc = query.docs.first;
      final data = doc.data();

      if (data['password'] != password) {
        throw FirebaseAuthException(
          code: 'wrong-password',
          message: 'Admin password is incorrect.',
        );
      }

      debugPrint('Admin credentials verified, creating Firebase account');

      // Create Firebase user and sign them in
      // This will trigger the auth state listener
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to create user');
      }

      debugPrint('Firebase user created: ${userCredential.user?.uid}');

      // Create the user model
      final userModel = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        role: 'admin',
        name: data['name'] ?? '',
        employeeId: data['employeeId'] as String?,
        designation: data['designation'] as String?,
        isFirstLogin: data['isFirstLogin'] ?? true,
        createdAt: data['createdAt'] is Timestamp
            ? (data['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
      );

      // Save to Firestore immediately
      await _firestore
          .collection('users')
          .doc(userModel.uid)
          .set(userModel.toMap());

      debugPrint('Admin user saved to Firestore with role: admin');

      // Set the user model immediately for faster UI updates
      // The listener might also set it, but this ensures it's available
      _user = userCredential.user;
      _userModel = userModel;
      _isLoading = false;

      notifyListeners();
      debugPrint('Admin user model set and listeners notified');
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Admin sign in Firebase error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Admin sign in error: $e');
      rethrow;
    }
  }

  // ================= SIGN UP =================

  Future<void> signUp(
    String email,
    String password,
    String name,
    String role, {
    String? employeeId,
    String? designation,
  }) async {
    try {
      _isLoading = true;

      notifyListeners();

      /// CREATE SECONDARY FIREBASE APP
      final secondaryApp = await Firebase.initializeApp(
        name: 'Secondary-${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );

      /// SECONDARY AUTH
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      /// CREATE EMPLOYEE ACCOUNT
      final userCredential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final createdUser = userCredential.user;

      if (createdUser != null) {
        final user = UserModel(
          uid: createdUser.uid,
          email: email,
          role: role,
          name: name,
          employeeId: employeeId,
          designation: designation,
          isFirstLogin: true,
        );

        await _firestore.collection('users').doc(user.uid).set(user.toMap());
      }

      /// IMPORTANT:
      /// SIGN OUT ONLY SECONDARY USER
      await secondaryAuth.signOut();

      /// DELETE SECONDARY APP
      await secondaryApp.delete();
    } catch (e) {
      throw e;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ================= UPDATE PASSWORD =================

  Future<void> updatePassword(String newPassword) async {
    try {
      await _user!.updatePassword(newPassword);

      if (_userModel != null) {
        await _firestore.collection('users').doc(_userModel!.uid).update({
          'isFirstLogin': false,
        });

        _userModel = _userModel!.copyWith(isFirstLogin: false);

        notifyListeners();
      }
    } catch (e) {
      throw e;
    }
  }

  // ================= SAVE FCM TOKEN =================

  Future<void> _saveFCMToken(String uid) async {
    try {
      debugPrint('Attempting to get and save FCM token for user: $uid');

      // Get FCM token from NotificationHandlerService
      final token = await NotificationHandlerService.getToken();

      if (token == null) {
        debugPrint('❌ FCM token is null - cannot save');
        return;
      }

      debugPrint('Got FCM token: ${token.substring(0, 20)}...');

      // Use set with merge to ensure it works even if document doesn't fully exist
      await _firestore.collection('users').doc(uid).set({
        'fcmToken': token,
      }, SetOptions(merge: true));

      debugPrint('✅ FCM token saved successfully for user: $uid');
    } on FirebaseException catch (e) {
      debugPrint('❌ Firebase error saving FCM token: ${e.code} - ${e.message}');

      // If it's a permission error, try one more time with a delay
      if (e.code == 'permission-denied') {
        debugPrint('Permission denied, retrying after 2 seconds...');
        await Future.delayed(const Duration(seconds: 2));

        try {
          final token = await NotificationHandlerService.getToken();
          if (token != null) {
            await _firestore.collection('users').doc(uid).set({
              'fcmToken': token,
            }, SetOptions(merge: true));
            debugPrint('✅ FCM token saved on retry');
          }
        } catch (retryError) {
          debugPrint('❌ Retry failed: $retryError');
        }
      }
    } catch (e) {
      debugPrint('❌ Unexpected error saving FCM token: $e');
    }
  }

  // ================= SIGN OUT =================

  Future<void> signOut() async {
    // Delete FCM token when logging out
    await NotificationHandlerService.deleteToken();
    
    // Sign out from Firebase
    await _auth.signOut();

    _user = null;
    _userModel = null;

    notifyListeners();
  }
}
