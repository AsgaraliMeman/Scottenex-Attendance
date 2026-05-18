import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/employee/employee_dashboard_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';

import 'providers/auth_provider.dart';
import 'utils/app_colors.dart';
import 'services/notification_handler_service.dart';

void main() async {
  // Ensure Flutter is initialized before any async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set up Firebase Cloud Messaging background handler
  // This must be a top-level function and is called when app is in background/terminated
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize notification service (FCM + local notifications)
  // This sets up foreground notification handling, permissions, and channels
  await NotificationHandlerService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        title: 'Scottenex Attendance',

        theme: ThemeData(
          primaryColor: AppColors.accent,
          scaffoldBackgroundColor: AppColors.background,
        ),

        /// ALWAYS OPEN AUTHWRAPPER - ROUTES BASED ON LOGIN STATUS
        home: const AuthWrapper(),
      ),
    );
  }
}

/// AFTER LOGIN NAVIGATION
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        debugPrint(
          'AuthWrapper rebuild - isLoading: ${authProvider.isLoading}, '
          'firebaseUser: ${authProvider.firebaseUser?.email}, '
          'userModel role: ${authProvider.userModel?.role}',
        );

        // Show loading while checking auth state
        if (authProvider.isLoading) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B4FBB)),
              ),
            ),
          );
        }

        // Check if user is logged in
        final isLoggedIn = authProvider.firebaseUser != null;
        final userModel = authProvider.userModel;

        if (!isLoggedIn || userModel == null) {
          debugPrint('No user logged in - showing LoginScreen');
          return const LoginScreen();
        }

        // User is logged in, route based on role
        final role = userModel.role.toLowerCase();
        debugPrint('Routing user with role: $role');

        if (role == 'admin') {
          return const AdminDashboardScreen();
        } else if (role == 'employee') {
          return const EmployeeDashboardScreen();
        } else {
          // Fallback if role is unknown
          debugPrint('Unknown role: $role - showing LoginScreen');
          return const LoginScreen();
        }
      },
    );
  }
}
