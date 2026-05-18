import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'admin/admin_dashboard_screen.dart';
import 'employee/employee_dashboard_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    debugPrint(
      'AuthWrapper => '
      'Loading: ${authProvider.isLoading}, '
      'User: ${authProvider.user?.email}, '
      'Role: ${authProvider.userModel?.role}',
    );

    /// LOADING
    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    /// NOT LOGGED IN
    if (authProvider.user == null) {
      return const LoginScreen();
    }

    /// WAIT USER DATA
    if (authProvider.userModel == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final role = authProvider.userModel!.role.toLowerCase();

    /// ADMIN
    if (role == 'admin') {
      return const AdminDashboardScreen();
    }

    /// EMPLOYEE
    return const EmployeeDashboardScreen();
  }
}
