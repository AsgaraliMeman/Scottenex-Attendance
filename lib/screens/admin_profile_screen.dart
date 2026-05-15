import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/admin_profile_provider.dart';
import '../utils/app_colors.dart';

/// Admin Profile Screen Widget
///
/// This screen displays the admin's profile information including:
/// - Admin name and designation
/// - Email address
/// - Sign out button with confirmation dialog
///
/// All business logic is handled by AdminProfileProvider (separation of concerns)
class AdminProfileScreen extends StatelessWidget {
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

  const AdminProfileScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    // Get auth provider from context
    final authProvider = Provider.of<AuthProvider>(context);

    // Wait for user data to load
    if (authProvider.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Create profile provider with auth provider dependency
    final profileProvider = AdminProfileProvider(authProvider: authProvider);

    // Get data from provider (ADMIN specific data only)
    final designation = profileProvider.getDesignation();
    final adminEmail = profileProvider.getEmail();

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
                // ============ Header Title ============
                const Text(
                  'Admin Profile',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: sectionGap),

                // ============ Profile Avatar & Info Section ============
                _buildProfileAvatarSection(userName, designation),
                SizedBox(height: sectionGap),

                // ============ Email Information Card ============
                _buildEmailCard(adminEmail),
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
  /// Displays circular avatar with admin icon, name, and designation
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
            Icons.admin_panel_settings,
            size: avatarIconSize,
            color: Colors.white,
          ),
        ),
        SizedBox(height: mediumGap),

        // Admin name
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

        // Admin designation
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
  /// Displays email icon and admin email address
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
                  'Admin Email',
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
  Widget _buildSignOutButton(BuildContext context, AdminProfileProvider profileProvider) {
    return SizedBox(
      height: signOutButtonHeight,
      child: ElevatedButton.icon(
        onPressed: () {
          _showLogoutDialog(context, profileProvider);
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

  /// Shows confirmation dialog before signing out
  ///
  /// This dialog prompts the user to confirm their sign out action.
  /// If confirmed, it will:
  /// 1. Sign out from authentication provider
  /// 2. Navigate to login screen
  /// 3. Remove all previous routes from navigation stack
  void _showLogoutDialog(BuildContext context, AdminProfileProvider profileProvider) {
    profileProvider.showLogoutConfirmation(context);
  }
}
