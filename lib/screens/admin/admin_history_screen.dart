import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scottenex_attendance/utils/app_colors.dart';


class AdminHistoryScreen extends StatefulWidget {
  const AdminHistoryScreen({super.key});

  @override
  State<AdminHistoryScreen> createState() => _AdminHistoryScreenState();
}

class _AdminHistoryScreenState extends State<AdminHistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _historySearchController =
      TextEditingController();
  String _historySearch = '';

  String _todayDateString() =>
      DateTime.now().toIso8601String().split('T').first;

  Stream<QuerySnapshot<Map<String, dynamic>>> _todayAttendanceStream() =>
      _firestore
          .collection('attendance')
          .where('date', isEqualTo: _todayDateString())
          .orderBy('timestamp', descending: true)
          .snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> _approvedLeavesStream() =>
      _firestore
          .collection('leaves')
          .where('status', isEqualTo: 'approved')
          .snapshots();

  Stream<int> _employeeCountStream() => _firestore
      .collection('users')
      .where('role', isEqualTo: 'employee')
      .snapshots()
      .map((snapshot) => snapshot.size);

  @override
  Widget build(BuildContext context) {
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
                      'Daily Report',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('MMMM d, yyyy').format(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.download, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _todayAttendanceStream(),
              builder: (context, attendanceSnapshot) {
                if (attendanceSnapshot.hasError) {
                  return Center(
                    child: Text(
                      'Unable to load attendance: ${attendanceSnapshot.error}',
                      style: const TextStyle(color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (!attendanceSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final attendanceDocs = attendanceSnapshot.data!.docs;
                final filteredAttendance = attendanceDocs.where((doc) {
                  final query = _historySearch.trim().toLowerCase();
                  if (query.isEmpty) return true;
                  final data = doc.data();
                  final name = (data['employeeName'] as String? ?? '')
                      .toLowerCase();
                  final department = (data['department'] as String? ?? '')
                      .toLowerCase();
                  final status = (data['status'] as String? ?? '')
                      .toLowerCase();
                  return name.contains(query) ||
                      department.contains(query) ||
                      status.contains(query);
                }).toList();

                final onTimeCount = attendanceDocs.where((doc) {
                  final status = (doc.data()['status'] as String? ?? '')
                      .toLowerCase();
                  return status == 'present' ||
                      status == 'on time' ||
                      status == 'checked-in';
                }).length;
                final lateCount = attendanceDocs.where((doc) {
                  return (doc.data()['status'] as String? ?? '')
                          .toLowerCase() ==
                      'late';
                }).length;
                final absentCount = attendanceDocs.where((doc) {
                  return (doc.data()['status'] as String? ?? '')
                          .toLowerCase() ==
                      'absent';
                }).length;
                final liveCount = attendanceDocs.where((doc) {
                  final data = doc.data();
                  return data['checkInTime'] != null &&
                      data['checkOutTime'] == null;
                }).length;

                return StreamBuilder<int>(
                  stream: _employeeCountStream(),
                  builder: (context, employeeSnapshot) {
                    final totalEmployees = employeeSnapshot.data ?? 0;
                    final effectiveTotal = totalEmployees > 0
                        ? totalEmployees
                        : attendanceDocs.length;
                    final capacity = effectiveTotal > 0
                        ? ((liveCount / effectiveTotal) * 100).round()
                        : 0;

                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _approvedLeavesStream(),
                      builder: (context, leavesSnapshot) {
                        final leaveDocs = leavesSnapshot.data?.docs ?? [];
                        final medicalLeaveCount = leaveDocs.where((doc) {
                          final data = doc.data();
                          final type = (data['type'] as String? ?? '')
                              .toLowerCase();
                          final start =
                              data['startDate']?.toDate() as DateTime?;
                          final end = data['endDate']?.toDate() as DateTime?;
                          final today = DateTime.now();
                          return start != null &&
                              end != null &&
                              !today.isBefore(start) &&
                              !today.isAfter(end) &&
                              type.contains('medical');
                        }).length;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 12),
                              _buildReportCards(
                                onTimeCount: onTimeCount,
                                totalEmployees: effectiveTotal,
                                lateCount: lateCount,
                                absentCount: absentCount,
                                medicalLeaveCount: medicalLeaveCount,
                                liveCount: liveCount,
                                capacity: capacity,
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: _historySearchController,
                                onChanged: (value) {
                                  setState(() {
                                    _historySearch = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search employee name',
                                  prefixIcon: const Icon(Icons.search),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: filteredAttendance.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'No attendance records found.',
                                          style: TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                      )
                                    : ListView.separated(
                                        padding: EdgeInsets.zero,
                                        itemCount: filteredAttendance.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 12),
                                        itemBuilder: (context, index) {
                                          final data = filteredAttendance[index]
                                              .data();
                                          final name =
                                              data['employeeName'] as String? ??
                                              'Unknown';
                                          final department =
                                              data['department'] as String? ??
                                              'Unknown';
                                          final status =
                                              (data['status'] as String? ??
                                                      'Unknown')
                                                  .toString();
                                          final checkInTime =
                                              data['checkInTime'];
                                          final checkOutTime =
                                              data['checkOutTime'];
                                          final timeText = checkOutTime != null
                                              ? _formatTimestamp(checkOutTime)
                                              : checkInTime != null
                                              ? _formatTimestamp(checkInTime)
                                              : data['time'] as String? ??
                                                    'N/A';

                                          return Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(22),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 16,
                                                  offset: const Offset(0, 8),
                                                ),
                                              ],
                                            ),
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 26,
                                                  backgroundColor: AppColors
                                                      .accent
                                                      .withOpacity(0.18),
                                                  child: Text(
                                                    _initials(name),
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 14),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        name,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        department,
                                                        style: const TextStyle(
                                                          color: Colors.black54,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 10,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: _statusColor(
                                                      status,
                                                    ).withOpacity(0.16),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          18,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    status,
                                                    style: TextStyle(
                                                      color: _statusColor(
                                                        status,
                                                      ),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  timeText,
                                                  style: const TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _historySearchController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'late':
        return Colors.yellow.shade700;
      case 'absent':
      case 'rejected':
        return Colors.red;
      case 'present':
      case 'on time':
      case 'checked-in':
        return Colors.green.shade700;
      default:
        return Colors.black87;
    }
  }

  String _formatTimestamp(Object timestamp) {
    if (timestamp is Timestamp) {
      return DateFormat('hh:mm a').format(timestamp.toDate());
    }
    if (timestamp is DateTime) {
      return DateFormat('hh:mm a').format(timestamp);
    }
    return timestamp.toString();
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Widget _buildReportCards({
    required int onTimeCount,
    required int totalEmployees,
    required int lateCount,
    required int absentCount,
    required int medicalLeaveCount,
    required int liveCount,
    required int capacity,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SmallMetricCard(
                title: 'On Time',
                value: '$onTimeCount/$totalEmployees',
                subtitle: 'Attendance rate',
                accentColor: AppColors.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SmallMetricCard(
                title: 'Late',
                value: '$lateCount',
                subtitle: 'Requires review',
                accentColor: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SmallMetricCard(
                title: 'Absent',
                value: '$absentCount',
                subtitle: '$medicalLeaveCount medical leave',
                accentColor: Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SmallMetricCard(
                title: 'Live Status',
                value: '$liveCount',
                subtitle: '$capacity% capacity',
                accentColor: Colors.black,
                inverted: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SmallMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color accentColor;
  final bool inverted;

  const _SmallMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.accentColor,
    this.inverted = false,
  });

  @override
  Widget build(BuildContext context) {
    final background = inverted ? Colors.black : Colors.white;
    final textColor = inverted ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.75)),
          ),
        ],
      ),
    );
  }
}
