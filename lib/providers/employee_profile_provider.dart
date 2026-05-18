import 'package:flutter/material.dart';
import 'auth_provider.dart';
import '../utils/app_colors.dart';

/// Employee Profile Provider (ViewModel)
///
/// Handles all business logic and data management for the Employee Profile Screen.
/// Separates UI concerns from business logic.
class EmployeeProfileProvider extends ChangeNotifier {
  final AuthProvider authProvider;

  // ============ Constants ============
  static const String defaultDesignation = 'Employee';
  static const String defaultEmail = 'employee@gmail.com';

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
  /// 1. Pop the profile screen from navigation stack (dialog already closed by caller)
  /// 2. Sign out from authentication provider
  /// 3. AuthWrapper will automatically show login screen when auth state changes
  Future<void> handleSignOut(BuildContext context) async {
    try {
      // Pop the profile screen from the navigation stack
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Now sign out - this will trigger auth state change
      // and AuthWrapper will show login screen
      await authProvider.signOut();

      debugPrint('User signed out successfully');
    } catch (e) {
      debugPrint('Sign out error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sign out error: $e')));
      }
      rethrow;
    }
  }

  /// Shows confirmation dialog before signing out
  ///
  /// Parameters:
  /// - context: BuildContext for showing the dialog (from profile screen)
  void showLogoutConfirmation(BuildContext profileScreenContext) {
    showDialog(
      context: profileScreenContext,
      builder: (dialogContext) {
        return _buildLogoutDialog(profileScreenContext);
      },
    );
  }

  /// Builds the logout confirmation dialog
  ///
  /// Returns an AlertDialog with confirmation options
  AlertDialog _buildLogoutDialog(BuildContext profileScreenContext) {
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
            Navigator.pop(profileScreenContext);
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
            Navigator.pop(profileScreenContext); // Close dialog first
            await handleSignOut(profileScreenContext);
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
