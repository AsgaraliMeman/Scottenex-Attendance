import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:scottenex_attendance/providers/auth_provider.dart';
import 'package:scottenex_attendance/utils/app_colors.dart';
import 'package:scottenex_attendance/widget/check_in_card.dart';
import 'package:scottenex_attendance/widget/notification_banner.dart';
import 'employee_profile_screen.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  State<EmployeeDashboardScreen> createState() =>
      _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState
    extends State<EmployeeDashboardScreen> {
  bool _isCheckedIn = false;

  DateTime? _checkInTime;
  DateTime? _checkOutTime;

  @override
  void initState() {
    super.initState();

    _loadTodayAttendance();
  }

  /// LOAD TODAY ATTENDANCE
  Future<void> _loadTodayAttendance() async {
    final user =
        Provider.of<AuthProvider>(
          context,
          listen: false,
        ).user;

    if (user == null) return;

    final today = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now());

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('attendance')
              .doc('${user.uid}_$today')
              .get();

      if (doc.exists) {
        final data = doc.data()!;

        setState(() {
          _checkInTime =
              data['checkInTime'] != null
                  ? (data['checkInTime']
                          as Timestamp)
                      .toDate()
                  : null;

          _checkOutTime =
              data['checkOutTime'] != null
                  ? (data['checkOutTime']
                          as Timestamp)
                      .toDate()
                  : null;

          /// IF CHECKED OUT TODAY
          if (_checkOutTime != null) {
            _isCheckedIn = false;
          }

          /// IF ONLY CHECKED IN
          else if (_checkInTime != null) {
            _isCheckedIn = true;
          }

          /// NEW DAY
          else {
            _isCheckedIn = false;
          }
        });
      } else {
        /// NEW DAY RESET
        setState(() {
          _isCheckedIn = false;
          _checkInTime = null;
          _checkOutTime = null;
        });
      }
    } catch (e) {
      debugPrint('Error loading attendance: $e');
    }
  }

  /// MARK ATTENDANCE
  Future<void> _markAttendance(
    bool isCheckIn,
  ) async {
    final user =
        Provider.of<AuthProvider>(
          context,
          listen: false,
        ).user;

    if (user == null) return;

    final now = DateTime.now();

    final today = DateFormat(
      'yyyy-MM-dd',
    ).format(now);

    final docRef = FirebaseFirestore.instance
        .collection('attendance')
        .doc('${user.uid}_$today');

    try {
      final existingDoc =
          await docRef.get();

      final existingData =
          existingDoc.data();

      /// PREVENT MULTIPLE ATTENDANCE
      /// AFTER CHECKOUT
      if (existingData != null &&
          existingData['checkOutTime'] !=
              null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            const SnackBar(
              content: Text(
                'Attendance already completed for today',
              ),
            ),
          );
        }

        return;
      }

      /// CHECK IN
      if (isCheckIn) {
        await docRef.set({
          'userId': user.uid,
          'date': today,
          'checkInTime': now,
          'checkOutTime': null,
        }, SetOptions(merge: true));

        setState(() {
          _isCheckedIn = true;
          _checkInTime = now;
          _checkOutTime = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            const SnackBar(
              content: Text(
                'Checked In Successfully',
              ),
            ),
          );
        }
      }

      /// CHECK OUT
      else {
        await docRef.update({
          'checkOutTime': now,
        });

        setState(() {
          /// SWITCH OFF AFTER CHECK OUT
          _isCheckedIn = false;

          _checkOutTime = now;
        });

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            const SnackBar(
              content: Text(
                'Checked Out Successfully',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
          ),
        );
      }
    }
  }

  /// GREETING
  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider =
        Provider.of<AuthProvider>(context);

    // Wait for user data to load
    if (authProvider.isLoading) {
      return Scaffold(
        backgroundColor:
            AppColors.background,
        appBar: AppBar(
          backgroundColor:
              AppColors.primary,
          title: const Text(
            'Attendance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
        body: const Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    // Only employees can access check-in screen
    final userRole =
        authProvider.userModel?.role ??
            '';

    if (userRole != 'employee') {
      return Scaffold(
        backgroundColor:
            AppColors.background,
        appBar: AppBar(
          backgroundColor:
              AppColors.primary,
          title: const Text(
            'Attendance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
        body: const Center(
          child: Text(
            'This feature is only for employees',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    final userModel =
        authProvider.userModel;

    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        backgroundColor:
            AppColors.primary,
        elevation: 0,

        title: const Text(
          'Attendance',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight:
                FontWeight.w600,
          ),
        ),

        leading: Container(
          margin:
              const EdgeInsets.all(8),

          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius:
                BorderRadius.circular(
                  8,
                ),
          ),

          child: const Icon(
            Icons.grid_view,
            color: Colors.white,
            size: 18,
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.person,
              color: Colors.white,
            ),

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EmployeeProfileScreen(
                        userName:
                            userModel
                                ?.name ??
                            'Employee',
                      ),
                ),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // Show notification banner if there are pending notifications
              NotificationBanner(
                userId: userModel?.uid ?? '',
              ),
              Text(
                _getGreeting(),
                style: const TextStyle(
                  color: AppColors
                      .secondaryText,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                userModel?.name ??
                    'Employee',

                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 32,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 32),

              /// FLIP SWITCH
              buildCheckInCard(
                isCheckedIn:
                    _isCheckedIn,

                checkOutTime:
                    _checkOutTime,

                /// DISABLE AFTER CHECKOUT
                canInteract:
                    _checkOutTime ==
                    null,

                onAttendance: (
                  value,
                ) async {
                  /// BLOCK RE-CHECKIN
                  if (_checkOutTime !=
                      null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Attendance already completed for today',
                        ),
                      ),
                    );

                    return;
                  }

                  await _markAttendance(
                    value,
                  );
                },
              ),

              const SizedBox(height: 24),

              _buildTodayStatusCard(),
            ],
          ),
        ),
      ),
    );
  }

  /// TODAY STATUS CARD
  Widget _buildTodayStatusCard() {
    String shiftStatus;
    Color statusColor;
    IconData statusIcon;

    if (_checkInTime == null) {
      shiftStatus = 'Not Started';
      statusColor = Colors.orange;
      statusIcon = Icons.schedule;
    } else if (_checkOutTime ==
        null) {
      shiftStatus = 'Active Shift';
      statusColor =
          Colors.greenAccent;
      statusIcon =
          Icons.check_circle;
    } else {
      shiftStatus = 'Shift Complete';
      statusColor =
          Colors.lightBlueAccent;
      statusIcon = Icons.task_alt;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,

        borderRadius:
            BorderRadius.circular(16),
      ),

      padding:
          const EdgeInsets.all(24),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,

            children: [
              const Text(
                'TODAY\'S STATUS',

                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w600,
                  color: Colors.white70,
                  letterSpacing: 0.5,
                ),
              ),

              Row(
                children: [
                  Icon(
                    statusIcon,
                    color:
                        statusColor,
                    size: 18,
                  ),

                  const SizedBox(
                    width: 6,
                  ),

                  Text(
                    shiftStatus,

                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight
                              .w600,
                      color:
                          statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,

            children: [
              _buildStatusItem(
                label:
                    'CHECK IN TIME',

                value:
                    _checkInTime !=
                            null
                        ? DateFormat(
                            'hh:mm a',
                          ).format(
                            _checkInTime!,
                          )
                        : '--:--',

                icon:
                    _checkInTime !=
                            null
                        ? Icons
                            .check_circle
                        : Icons.schedule,
              ),

              _buildStatusItem(
                label:
                    'CHECK OUT TIME',

                value:
                    _checkOutTime !=
                            null
                        ? DateFormat(
                            'hh:mm a',
                          ).format(
                            _checkOutTime!,
                          )
                        : '--:--',

                icon:
                    _checkOutTime !=
                            null
                        ? Icons
                            .check_circle
                        : Icons.schedule,
              ),
            ],
          ),

          if (_checkInTime != null &&
              _checkOutTime !=
                  null) ...[
            const SizedBox(
              height: 20,
            ),

            _buildDurationWidget(),
          ],
        ],
      ),
    );
  }

  /// TOTAL HOURS
  Widget _buildDurationWidget() {
    final duration =
        _checkOutTime!.difference(
          _checkInTime!,
        );

    final hours =
        duration.inHours;

    final minutes =
        duration.inMinutes % 60;

    return Container(
      padding:
          const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),

      decoration: BoxDecoration(
        color: Colors.white
            .withOpacity(0.1),

        borderRadius:
            BorderRadius.circular(8),
      ),

      child: Row(
        children: [
          const Icon(
            Icons.timelapse,
            color:
                Colors.lightBlueAccent,
            size: 16,
          ),

          const SizedBox(width: 8),

          Text(
            'Total Hours: ${hours}h ${minutes}m',

            style: const TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.w600,
              color:
                  Colors.lightBlueAccent,
            ),
          ),
        ],
      ),
    );
  }

  /// STATUS ITEM
  Widget _buildStatusItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          label,

          style: const TextStyle(
            fontSize: 12,
            fontWeight:
                FontWeight.w600,
            color: Colors.white70,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Icon(
              icon,
              color: AppColors.accent,
              size: 16,
            ),

            const SizedBox(width: 8),

            Text(
              value,

              style: const TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}