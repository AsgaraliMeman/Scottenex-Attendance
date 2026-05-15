import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/employee/employee_dashboard_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';

import 'providers/auth_provider.dart';
import 'utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
        // Show splash/loading while checking auth state
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is logged in, navigate to appropriate dashboard
        if (authProvider.firebaseUser != null &&
            authProvider.userModel != null) {
          if (authProvider.userModel!.role == 'admin') {
            return const AdminDashboardScreen();
          } else {
            return const EmployeeDashboardScreen();
          }
        }

        // If not logged in, show login screen
        return const LoginScreen();
      },
    );
  }
}
