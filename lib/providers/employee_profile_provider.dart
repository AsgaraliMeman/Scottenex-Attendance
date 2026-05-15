import 'package:flutter/material.dart';
import 'auth_provider.dart';
import '../screens/login_screen.dart';
import '../utils/app_colors.dart';

/// Employee Profile Provider (ViewModel)
///
/// Handles all business logic and data management for the Employee Profile Screen.
/// Separates UI concerns from business logic.
class EmployeeProfileProvider extends ChangeNotifier {
  final AuthProvider authProvider;

  // ============ Constants ============
  static const String defaultDesignation = 'Employee';
  static const String defaultEmail = 'employee@company.com';

  EmployeeProfileProvider({required this.authProvider});

  // ============ Getters for UI Data ============

  /// Gets the user's designation from auth provider or returns default
  String getDesignation() {
    return authProvider.userModel?.designation ?? defaultDesignation;
  }

  /// Gets the user's email from Firebase or returns default
  String getEmail() {
    return authProvider.firebaseUser?.email ?? defaultEmail;
  }

  /// Checks if user data is available
  bool isUserDataLoaded() {
    return authProvider.firebaseUser != null;
  }

  // ============ Business Logic Methods ============

  /// Handles the sign out process
  ///
  /// Steps:
  /// 1. Sign out from authentication provider
  /// 2. Navigate to login screen
  /// 3. Clear all previous routes from navigation stack
  Future<void> handleSignOut(BuildContext context) async {
    try {
      // Perform sign out
      await authProvider.signOut();

      // Navigate to login screen and remove all previous routes
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      // Handle error if needed
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }

  /// Shows confirmation dialog before signing out
  ///
  /// Parameters:
  /// - context: BuildContext for showing the dialog
  void showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return _buildLogoutDialog(dialogContext);
      },
    );
  }

  /// Builds the logout confirmation dialog
  ///
  /// Returns an AlertDialog with confirmation options
  AlertDialog _buildLogoutDialog(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text(
        'Sign Out',
        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent),
      ),
      content: const Text(
        'Do you want to sign out?',
        style: TextStyle(fontSize: 14, color: AppColors.secondaryText),
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'No',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Confirm sign out button
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await handleSignOut(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Yes'),
        ),
      ],
    );
  }
}
