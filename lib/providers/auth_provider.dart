import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

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
    _auth.authStateChanges().listen((User? user) async {
      _user = user;

      if (user != null) {
        await _loadUserData(user.uid);
      } else {
        _userModel = null;
      }

      _isLoading = false;

      notifyListeners();
    });
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        _userModel = UserModel.fromMap(doc.data()!, uid);

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
      } else {
        final query = await _firestore
            .collection('users')
            .where('email', isEqualTo: _user!.email)
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          final data = query.docs.first.data();

          _userModel = UserModel.fromMap(data, uid);

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
        }
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

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;

      if (_user != null) {
        await _loadUserData(_user!.uid);

        notifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ================= ADMIN LOGIN =================

  Future<void> signInAdmin(String email, String password) async {
    try {
      await signIn(email, password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        final query = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .where('role', isEqualTo: 'admin')
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          throw e;
        }

        final doc = query.docs.first;

        final data = doc.data();

        if (data['password'] != password) {
          throw FirebaseAuthException(
            code: 'wrong-password',
            message: 'Admin password is incorrect.',
          );
        }

        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

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

        await _firestore
            .collection('users')
            .doc(userModel.uid)
            .set(userModel.toMap());

        _userModel = userModel;

        notifyListeners();

        return;
      }

      throw e;
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
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        role: role,
        name: name,
        employeeId: employeeId,
        designation: designation,
        isFirstLogin: true,
      );

      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      throw e;
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

  // ================= SIGN OUT =================

  Future<void> signOut() async {
    await _auth.signOut();

    _user = null;
    _userModel = null;

    notifyListeners();
  }
}
