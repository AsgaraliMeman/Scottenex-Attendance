import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scottenex_attendance/utils/app_colors.dart';
import 'employee_details_screen.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All Staff';

  static const List<String> _categories = ['All Staff'];

  Stream<QuerySnapshot<Map<String, dynamic>>> get _employeeStream => _firestore
      .collection('users')
      .where('role', isEqualTo: 'employee')
      .snapshots();

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filterEmployees(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final search = _searchController.text.trim().toLowerCase();
    final filtered = snapshot.docs.where((doc) {
      final data = doc.data();
      final name = (data['name'] as String? ?? '').toLowerCase();
      final designation = (data['designation'] as String? ?? '').toLowerCase();
      final department = (data['department'] as String? ?? '').toLowerCase();
      final matchesSearch =
          search.isEmpty ||
          name.contains(search) ||
          designation.contains(search) ||
          department.contains(search);
      final matchesCategory =
          _selectedCategory == 'All Staff' ||
          department == _selectedCategory.toLowerCase();
      return matchesSearch && matchesCategory;
    }).toList();

    filtered.sort((a, b) {
      final nameA = (a.data()['name'] as String? ?? '').toLowerCase();
      final nameB = (b.data()['name'] as String? ?? '').toLowerCase();
      return nameA.compareTo(nameB);
    });

    return filtered;
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'on leave':
        return Colors.amber.shade700;
      case 'remote':
        return Colors.blue.shade700;
      case 'off duty':
        return Colors.grey.shade700;
      default:
        return Colors.green.shade700;
    }
  }

  String _initials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundAlt,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Staff Directory',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Manage and monitor your team’s real-time status.',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildSearchField(),
                  const SizedBox(height: 16),
                  _buildCategoryChips(),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildEmployeeList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintText: 'Search employees, roles, or department',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(Icons.search, color: Colors.black54),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((option) {
          final isSelected = option == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(option),
              selected: isSelected,
              selectedColor: Colors.black,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: (_) {
                setState(() {
                  _selectedCategory = option;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmployeeList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _employeeStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Failed to load employees. Please check your connection.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredDocs = _filterEmployees(snapshot.data!);
        if (filteredDocs.isEmpty) {
          return const Center(
            child: Text(
              'No employees found.',
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          itemCount: filteredDocs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = filteredDocs[index].data();
            final name = data['name'] as String? ?? 'Unknown';
            final designation = data['designation'] as String? ?? 'Employee';
            final department = data['department'] as String? ?? 'General';
            final status = (data['status'] as String? ?? 'Active');
            final statusColor = _statusColor(status);
            final subtitle = data['location'] as String? ?? department;
            final stamp = data['lastCheckIn'] as String?;
            final details = stamp != null && stamp.isNotEmpty
                ? 'Clocked in at $stamp'
                : 'Status updated recently';

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmployeeDetailsScreen(
                      employeeId: filteredDocs[index].id,
                      employeeName: name,
                      employeeDesignation: designation,
                      employeeEmail: data['email'] as String? ?? 'N/A',
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.accent.withOpacity(0.15),
                            child: Text(
                              _initials(name),
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$designation • $department',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 16,
                            color: Colors.black45,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              details,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.place, size: 16, color: Colors.black45),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              subtitle,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
