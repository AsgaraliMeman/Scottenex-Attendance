import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scottenex_attendance/utils/app_colors.dart';



class EmployeeDetailsScreen extends StatefulWidget {
  final String employeeId;
  final String employeeName;
  final String employeeDesignation;
  final String employeeEmail;

  const EmployeeDetailsScreen({
    super.key,
    required this.employeeId,
    required this.employeeName,
    required this.employeeDesignation,
    required this.employeeEmail,
  });

  @override
  State<EmployeeDetailsScreen> createState() => _EmployeeDetailsScreenState();
}

class _EmployeeDetailsScreenState extends State<EmployeeDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _checkInTime;
  String? _checkOutTime;
  List<Map<String, dynamic>> _attendanceHistory = [];

  @override
  void initState() {
    super.initState();
    _loadTodayAttendance();
    _loadAttendanceHistory();
  }

  Future<void> _loadTodayAttendance() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final doc = await _firestore
          .collection('attendance')
          .doc('${widget.employeeId}_$today')
          .get();

      if (doc.exists) {
        final data = doc.data()!;

        setState(() {
          if (data['checkInTime'] != null) {
            _checkInTime = DateFormat(
              'HH:mm a',
            ).format((data['checkInTime'] as Timestamp).toDate());
          }

          if (data['checkOutTime'] != null) {
            _checkOutTime = DateFormat(
              'HH:mm a',
            ).format((data['checkOutTime'] as Timestamp).toDate());
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading attendance: $e');
    }
  }

  /// LOAD ATTENDANCE HISTORY
  Future<void> _loadAttendanceHistory() async {
    try {
      debugPrint(
        'Loading attendance history for email: ${widget.employeeEmail}',
      );

      // First, get the user's UID from the users collection using email
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: widget.employeeEmail)
          .get();

      if (userQuery.docs.isEmpty) {
        debugPrint('User not found for email: ${widget.employeeEmail}');
        return;
      }

      final userId = userQuery.docs.first.id;

      debugPrint('Found userId: $userId');

      // Now query attendance without orderBy first to see if data exists
      final allDocs = await _firestore
          .collection('attendance')
          .where('userId', isEqualTo: userId)
          .get();

      debugPrint('Found ${allDocs.docs.length} attendance records for user');

      // Sort by date descending in code
      final history = allDocs.docs.map((doc) {
        final data = doc.data();

        debugPrint(
          'Record: date=${data['date']}, checkIn=${data['checkInTime']}, checkOut=${data['checkOutTime']}',
        );

        return {
          'date': data['date'] ?? '',
          'checkInTime': data['checkInTime']?.toDate(),
          'checkOutTime': data['checkOutTime']?.toDate(),
        };
      }).toList();

      // Sort by date descending
      history.sort(
        (a, b) => (b['date'] as String).compareTo(a['date'] as String),
      );

      setState(() {
        _attendanceHistory = history;
      });

      debugPrint('Loaded ${_attendanceHistory.length} records');
    } catch (e) {
      debugPrint('Error loading history: $e');
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
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),

        title: const Text(
          'Employee Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                /// PROFILE IMAGE
                Center(
                  child: Container(
                    width: 140,
                    height: 140,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,

                      border: Border.all(color: AppColors.accent, width: 3),

                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowMid,
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),

                    child: Center(
                      child: Text(
                        _initials(widget.employeeName),

                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                /// NAME
                Text(
                  widget.employeeName,

                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 8),

                /// DESIGNATION
                Text(
                  widget.employeeDesignation,

                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondary,
                  ),
                ),

                const SizedBox(height: 24),

                /// EMAIL CARD
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),

                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,

                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(color: AppColors.border),
                  ),

                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,

                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.12),

                          borderRadius: BorderRadius.circular(10),
                        ),

                        child: const Icon(
                          Icons.email_outlined,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            const Text(
                              'Email',

                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.secondaryText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              widget.employeeEmail,

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
                ),

                const SizedBox(height: 16),

                /// EMPLOYEE ID CARD
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),

                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,

                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(color: AppColors.border),
                  ),

                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,

                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.12),

                          borderRadius: BorderRadius.circular(10),
                        ),

                        child: const Icon(
                          Icons.badge_outlined,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            const Text(
                              'Employee ID',

                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.secondaryText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 4),

                            FutureBuilder<QuerySnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .where(
                                    'email',
                                    isEqualTo: widget.employeeEmail,
                                  )
                                  .get(),

                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text(
                                    'Loading...',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  );
                                }

                                if (!snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return const Text(
                                    'No ID Found',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  );
                                }

                                final data =
                                    snapshot.data!.docs.first.data()
                                        as Map<String, dynamic>;

                                final employeeId = data['employeeId'] ?? '';

                                return Text(
                                  employeeId,

                                  overflow: TextOverflow.ellipsis,

                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                /// TODAY STATUS TITLE
                Align(
                  alignment: Alignment.centerLeft,

                  child: Text(
                    'Today\'s Status',

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// STATUS CARD
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: AppColors.primary,

                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      _buildStatusRow(
                        label: 'CHECK IN TIME',

                        value: _checkInTime ?? '--:--',

                        icon: _checkInTime != null
                            ? Icons.check_circle
                            : Icons.schedule,
                      ),

                      const SizedBox(height: 20),

                      _buildStatusRow(
                        label: 'CHECK OUT TIME',

                        value: _checkOutTime ?? '--:--',

                        icon: _checkOutTime != null
                            ? Icons.check_circle
                            : Icons.schedule,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                /// ATTENDANCE HISTORY TITLE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text(
                      'Attendance History',

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _loadAttendanceHistory();
                      },

                      icon: const Icon(
                        Icons.refresh,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// ATTENDANCE HISTORY TABLE
                _buildAttendanceHistory(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ATTENDANCE HISTORY WIDGET
  Widget _buildAttendanceHistory() {
    if (_attendanceHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),

          child: Column(
            children: [
              Icon(Icons.history, size: 48, color: Colors.grey[400]),

              const SizedBox(height: 12),

              Text(
                'No attendance records',

                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(color: AppColors.border),
      ),

      child: Column(
        children: [
          /// HEADER ROW
          Container(
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: AppColors.primary,

              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),

            child: Row(
              children: [
                Expanded(
                  flex: 2,

                  child: Text(
                    'DATE',

                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                Expanded(
                  flex: 2,

                  child: Text(
                    'CHECK-IN',

                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                Expanded(
                  flex: 2,

                  child: Text(
                    'CHECK-OUT',

                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// ATTENDANCE ROWS
          ListView.separated(
            shrinkWrap: true,

            physics: const NeverScrollableScrollPhysics(),

            itemCount: _attendanceHistory.length,

            separatorBuilder: (context, index) => Divider(
              color: AppColors.border,
              height: 1,
              indent: 16,
              endIndent: 16,
            ),

            itemBuilder: (context, index) {
              final record = _attendanceHistory[index];

              final dateStr = record['date'] as String;

              final checkInTime = record['checkInTime'] as DateTime?;

              final checkOutTime = record['checkOutTime'] as DateTime?;

              /// Parse date to show day name
              final parsedDate = DateTime.parse(dateStr);

              final dayName = DateFormat('EEE').format(parsedDate);

              final displayDate = DateFormat('MMM dd').format(parsedDate);

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),

                child: Row(
                  children: [
                    Expanded(
                      flex: 2,

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            displayDate,

                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            dayName,

                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      flex: 2,

                      child: Text(
                        checkInTime != null
                            ? DateFormat('HH:mm a').format(checkInTime)
                            : '--:--',

                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 2,

                      child: Text(
                        checkOutTime != null
                            ? DateFormat('HH:mm a').format(checkOutTime)
                            : '--:--',

                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          label,

          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 18),

            const SizedBox(width: 8),

            Text(
              value,

              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
