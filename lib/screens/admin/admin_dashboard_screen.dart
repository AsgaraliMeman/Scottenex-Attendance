import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scottenex_attendance/providers/auth_provider.dart';
import 'package:scottenex_attendance/utils/app_colors.dart';
import 'add_employee_screen.dart';
import '../employee/employee_list_screen.dart';
import 'password_approvals_screen.dart';
import 'admin_profile_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _selectedIndex = 0;

  /// TODAY DATE
  String _todayDateString() =>
      DateTime.now().toIso8601String().split('T').first;

  /// TOTAL EMPLOYEES
  Stream<int> _employeeCountStream() => _firestore
      .collection('users')
      .where('role', isEqualTo: 'employee')
      .snapshots()
      .map((snapshot) => snapshot.size);

  /// CURRENT CHECK-INS
  Stream<int> _currentCheckInsStream() => _firestore
      .collection('attendance')
      .where('date', isEqualTo: _todayDateString())
      .snapshots()
      .map((snapshot) {
        int count = 0;

        for (var doc in snapshot.docs) {
          final data = doc.data();

          /// COUNT USER ONLY IF CHECKED IN
          if (data['checkInTime'] != null) {
            count++;
          }
        }

        return count;
      });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    final userName = authProvider.userModel?.name ?? 'Administrator';

    // ============ ROLE VALIDATION ============
    // Wait for user data to be loaded before checking role
    if (authProvider.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundAlt,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,

      body: _selectedIndex == 1
          ? AdminProfileScreen(userName: userName)
          : _buildDashboardBody(userName),

      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDashboardBody(String userName) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Attendance',

                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Welcome, $userName',

                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),

                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) => AdminProfileScreen(userName: userName),
                      ),
                    );
                  },

                  icon: CircleAvatar(
                    radius: 18,

                    backgroundColor: AppColors.accent,

                    child: const Icon(Icons.person, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,

                children: [
                  const SizedBox(height: 8),

                  _buildOverviewRow(),

                  const SizedBox(height: 18),

                  _buildQuickActions(),

                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewRow() {
    return Row(
      children: [
        Expanded(
          child: StreamBuilder<int>(
            stream: _employeeCountStream(),

            builder: (context, snapshot) {
              final value = snapshot.hasData ? snapshot.data!.toString() : '--';

              return _InfoCard(
                title: 'Total Employees',

                value: value,

                caption: 'Updated now',
              );
            },
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: StreamBuilder<int>(
            stream: _currentCheckInsStream(),

            builder: (context, snapshot) {
              final value = snapshot.hasData ? snapshot.data!.toString() : '--';

              return _InfoCard(
                title: 'Current Check-ins',

                value: value,

                caption: 'Today',

                highlighted: true,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,

      children: [
        _ActionCard(
          icon: Icons.person_add,

          label: 'Add Employee',

          onTap: () {
            Navigator.push(
              context,

              MaterialPageRoute(builder: (_) => const AddEmployeeScreen()),
            );
          },
        ),

        _ActionCard(
          icon: Icons.group,

          label: 'Employees',

          onTap: () {
            Navigator.push(
              context,

              MaterialPageRoute(builder: (_) => const EmployeeListScreen()),
            );
          },
        ),

        _ActionCard(
          icon: Icons.lock_reset,

          label: 'Password Requests',

          onTap: () {
            Navigator.push(
              context,

              MaterialPageRoute(
                builder: (_) => const PasswordApprovalsScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),

            blurRadius: 20,

            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),

        child: BottomNavigationBar(
          currentIndex: _selectedIndex,

          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },

          type: BottomNavigationBarType.fixed,

          elevation: 0,

          backgroundColor: Colors.white,

          selectedItemColor: AppColors.accent,

          unselectedItemColor: Colors.grey,

          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),

          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),

              label: 'Dashboard',
            ),

            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String caption;
  final bool highlighted;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.caption,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: highlighted ? AppColors.accent : Colors.white,

        borderRadius: BorderRadius.circular(24),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            title,

            style: TextStyle(
              fontSize: 12,

              fontWeight: FontWeight.bold,

              color: highlighted ? Colors.black : Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            value,

            style: TextStyle(
              fontSize: 32,

              fontWeight: FontWeight.bold,

              color: highlighted ? Colors.black : Colors.black,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            caption,

            style: TextStyle(
              color: highlighted ? Colors.black87 : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionCard({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.43,

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(22),

        child: Container(
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(22),
          ),

          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2),

                  shape: BoxShape.circle,
                ),

                child: Icon(icon, size: 28, color: Colors.black),
              ),

              const SizedBox(height: 12),

              Text(
                label,

                textAlign: TextAlign.center,

                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
