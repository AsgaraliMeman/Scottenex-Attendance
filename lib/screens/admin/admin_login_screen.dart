import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scottenex_attendance/providers/auth_provider.dart' as app_auth;
import 'package:scottenex_attendance/utils/app_colors.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  static const String _adminEmail = 'adminscottenex@gmail.com';

  final TextEditingController _adminIdController = TextEditingController(
    text: _adminEmail,
  );

  final TextEditingController _accessKeyController = TextEditingController();

  bool _isLoading = false;
  bool _obscureAccessKey = true;

  @override
  void dispose() {
    _adminIdController.dispose();
    _accessKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // HEADER
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 28,
                      horizontal: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.shield_outlined,
                                  color: Colors.black,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'ADMIN PANEL',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        Text(
                          'Attendance',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Central Command & Security',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // LOGIN CARD
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // EMAIL LABEL
                        const Text(
                          'ADMINISTRATOR EMAIL',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.2,
                            color: AppColors.primaryText,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // EMAIL FIELD
                        TextField(
                          controller: _adminIdController,
                          keyboardType: TextInputType.emailAddress,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: _adminEmail,
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: AppColors.primaryText,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 18,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ACCESS KEY TITLE
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'SECURE ACCESS KEY',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1.2,
                                color: AppColors.primaryText,
                              ),
                            ),
                            TextButton(
                              onPressed: _recoverKey,
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.secondaryText,
                              ),
                              child: const Text(
                                'RECOVER KEY',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),

                        // PASSWORD FIELD
                        TextField(
                          controller: _accessKeyController,
                          obscureText: _obscureAccessKey,
                          decoration: InputDecoration(
                            hintText: '••••••••••••••',
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: AppColors.primaryText,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureAccessKey
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureAccessKey = !_obscureAccessKey;
                                });
                              },
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 18,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // INFO BOX
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.shield_outlined,
                                color: AppColors.primaryText,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  'Multi-factor authentication (MFA) will be required upon successful primary credential validation.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primaryText,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // LOGIN BUTTON
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _secureLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: Colors.black,
                                  minimumSize: const Size.fromHeight(56),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Secure Login'),
                                    SizedBox(width: 10),
                                    Icon(Icons.arrow_forward, size: 20),
                                  ],
                                ),
                              ),

                        const SizedBox(height: 18),

                        const Text(
                          'AUTHORIZED PERSONNEL ONLY. ALL ATTEMPTS ARE LOGGED.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // LOGIN FUNCTION
  Future<void> _secureLogin() async {
    if (_adminIdController.text.trim().isEmpty ||
        _accessKeyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your administrator ID and access key.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final enteredEmail = _adminIdController.text.trim();
      final enteredPassword = _accessKeyController.text.trim();

      // CHECK ADMIN EMAIL
      if (enteredEmail.toLowerCase() != _adminEmail.toLowerCase()) {
        throw FirebaseAuthException(
          code: 'invalid-admin',
          message: 'This email is not configured as admin.',
        );
      }

      final authProvider = Provider.of<app_auth.AuthProvider>(
        context,
        listen: false,
      );
      await authProvider.signInAdmin(enteredEmail, enteredPassword);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Admin login successful')));

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Secure login failed';

      switch (e.code) {
        case 'user-not-found':
          message = 'Admin account not found';
          break;

        case 'wrong-password':
          message = 'Incorrect access key';
          break;

        case 'invalid-email':
          message = 'Invalid email address';
          break;

        case 'invalid-credential':
          message = 'Invalid email or password';
          break;

        case 'too-many-requests':
          message = 'Too many attempts. Try again later';
          break;

        case 'invalid-admin':
          message = e.message ?? 'Unauthorized admin';
          break;

        default:
          message = e.message ?? 'Authentication failed';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Secure login failed: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // RECOVER KEY
  void _recoverKey() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recover key flow is not configured yet.')),
    );
  }
}
