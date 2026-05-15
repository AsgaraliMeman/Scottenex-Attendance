import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scottenex_attendance/providers/auth_provider.dart';
import 'package:scottenex_attendance/utils/app_colors.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _nameController = TextEditingController();
  final _designationController = TextEditingController();
  final _emailController =
      TextEditingController(); // Admin input for email/username

  bool _isLoading = false;

  String _usedEmail = '';
  String _generatedPassword = '';
  String _generatedEmployeeId = '';

  @override
  void dispose() {
    _nameController.dispose();
    _designationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Generates a random Employee ID
  String _generateEmployeeId() {
    final random = Random();
    return 'EMP${1000 + random.nextInt(9000)}';
  }

  // Generates a random 8-character password
  String _generatePassword() {
    final random = Random();
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(
      8,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  Future<void> _addEmployee() async {
    final name = _nameController.text.trim();
    final designation = _designationController.text.trim();
    final email = _emailController.text.trim();

    // Basic Validation: Just check if empty
    if (name.isEmpty || designation.isEmpty || email.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final generatedPassword = _generatePassword();
      final generatedEmployeeId = _generateEmployeeId();

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Call your signUp method using the admin-provided string
      await authProvider.signUp(
        email,
        generatedPassword,
        name,
        'employee',
        employeeId: generatedEmployeeId,
        designation: designation,
      );

      setState(() {
        _usedEmail = email;
        _generatedPassword = generatedPassword;
        _generatedEmployeeId = generatedEmployeeId;
      });

      _showSnackBar('Employee created successfully');

      // Clear input fields for next entry
      _nameController.clear();
      _designationController.clear();
      _emailController.clear();
    } catch (e) {
      _showSnackBar('Failed to create employee: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1,
          color: AppColors.primaryText,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
      ),
    );
  }

  Widget _buildGeneratedBox(String title, String value, IconData icon) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.accent,
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                SelectableText(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ============ ROLE VALIDATION ============
    // Ensure only admins can add employees
    final authProvider = Provider.of<AuthProvider>(context);

    // Wait for user data to be loaded before checking role
    if (authProvider.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundAlt,
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Debug: Check if user data exists
    debugPrint('UserModel: ${authProvider.userModel}');
    debugPrint('User Role: ${authProvider.userModel?.role}');
    debugPrint('User Email: ${authProvider.userModel?.email}');

    final userRole = (authProvider.userModel?.role ?? '').toLowerCase();

    if (userRole != 'admin') {
      return Scaffold(
        backgroundColor: AppColors.backgroundAlt,
        appBar: AppBar(
          title: const Text('Unauthorized'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Only admins can add employees',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Your role: ${authProvider.userModel?.role ?? "Not set"}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Text(
                  'Email: ${authProvider.userModel?.email ?? "Not loaded"}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Add New Employee',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.surface,
                    child: Icon(
                      Icons.person_add,
                      size: 42,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Create Employee Account',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Manually enter the login ID. Password and Employee ID will be generated automatically.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildLabel('Full Name'),
            _buildTextField(_nameController, 'Enter employee name'),

            const SizedBox(height: 18),

            _buildLabel('Designation'),
            _buildTextField(_designationController, 'Enter designation'),

            const SizedBox(height: 18),

            _buildLabel('Login ID / Email'),
            _buildTextField(_emailController, 'Enter login ID for employee'),

            const SizedBox(height: 28),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _addEmployee,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),

            const SizedBox(height: 28),

            // Results Section: Shows the credentials to copy after creation
            if (_generatedEmployeeId.isNotEmpty) ...[
              const Divider(height: 40),
              const Text(
                'Account Credentials (Copy these)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 16),
              _buildGeneratedBox(
                'EMPLOYEE ID',
                _generatedEmployeeId,
                Icons.badge,
              ),
              _buildGeneratedBox('LOGIN ID', _usedEmail, Icons.person),
              _buildGeneratedBox('PASSWORD', _generatedPassword, Icons.lock),
            ],
          ],
        ),
      ),
    );
  }
}
