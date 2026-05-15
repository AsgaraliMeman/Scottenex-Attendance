import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scottenex_attendance/providers/auth_provider.dart';
import 'package:scottenex_attendance/providers/employee_profile_provider.dart';
import 'package:scottenex_attendance/utils/app_colors.dart';


/// Employee Profile Screen Widget
///
/// This screen displays the employee's profile information including:
/// - Employee name and designation
/// - Email address
/// - Sign out button with confirmation dialog
///
/// All business logic is handled by EmployeeProfileProvider (separation of concerns)
class EmployeeProfileScreen extends StatelessWidget {
  final String userName;

  // ============ UI Constants ============
  static const double avatarSize = 120;
  static const double avatarBorderWidth = 4;
  static const double avatarIconSize = 58;
  static const double profileNameFontSize = 28;
  static const double profileDesignationFontSize = 15;
  static const double horizontalPadding = 22;
  static const double verticalPadding = 18;
  static const double sectionGap = 36;
  static const double smallGap = 8;
  static const double mediumGap = 22;
  static const double largeGap = 40;
  static const double bottomPadding = 100;
  static const double containerPadding = 16;
  static const double containerBorderRadius = 16;
  static const double iconBoxSize = 44;
  static const double iconBoxBorderRadius = 12;
  static const double iconBoxOpacity = 0.12;
  static const double signOutButtonHeight = 56;
  static const double dialogBorderRadius = 18;

  const EmployeeProfileScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    // Get auth provider to access user data
    final authProvider = Provider.of<AuthProvider>(context);

    // Create profile provider with auth provider dependency
    final profileProvider = EmployeeProfileProvider(authProvider: authProvider);

    // Get data from provider
    final designation = profileProvider.getDesignation();
    final employeeEmail = profileProvider.getEmail();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ============ Header with Close Button ============
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: sectionGap),

                // ============ Profile Avatar & Info Section ============
                _buildProfileAvatarSection(userName, designation),
                SizedBox(height: sectionGap),

                // ============ Email Information Card ============
                _buildEmailCard(employeeEmail),
                SizedBox(height: largeGap),

                // ============ Sign Out Button ============
                _buildSignOutButton(context, profileProvider),
                SizedBox(height: bottomPadding),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the profile avatar and information section
  /// Displays circular avatar with employee icon, name, and designation
  Widget _buildProfileAvatarSection(String name, String designation) {
    return Column(
      children: [
        // Circular avatar with gradient background
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            border: Border.all(
              color: AppColors.accent,
              width: avatarBorderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowMid,
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.person,
            size: avatarIconSize,
            color: Colors.white,
          ),
        ),
        SizedBox(height: mediumGap),

        // Employee name
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: profileNameFontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: smallGap),

        // Employee designation
        Text(
          designation,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: profileDesignationFontSize,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  /// Builds the email information card
  /// Displays email icon and employee email address
  Widget _buildEmailCard(String email) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: containerPadding,
        vertical: containerPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(containerBorderRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Email icon with background
          Container(
            width: iconBoxSize,
            height: iconBoxSize,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(iconBoxOpacity),
              borderRadius: BorderRadius.circular(iconBoxBorderRadius),
            ),
            child: const Icon(Icons.email_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 14),

          // Email label and value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label
                const Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),

                // Email value
                Text(
                  email,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the sign out button
  /// When pressed, shows a confirmation dialog before signing out
  Widget _buildSignOutButton(
    BuildContext context,
    EmployeeProfileProvider profileProvider,
  ) {
    return SizedBox(
      height: signOutButtonHeight,
      child: ElevatedButton.icon(
        onPressed: () {
          // Delegate to provider's logic
          profileProvider.showLogoutConfirmation(context);
        },
        icon: const Icon(Icons.logout),
        label: const Text(
          'Sign Out',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(containerBorderRadius),
          ),
        ),
      ),
    );
  }
}
