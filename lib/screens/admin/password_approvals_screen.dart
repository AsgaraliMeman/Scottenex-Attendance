import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scottenex_attendance/utils/app_colors.dart';

class PasswordApprovalsScreen
    extends StatefulWidget {
  const PasswordApprovalsScreen({
    super.key,
  });

  @override
  State<PasswordApprovalsScreen>
  createState() =>
      _PasswordApprovalsScreenState();
}

class _PasswordApprovalsScreenState
    extends State<PasswordApprovalsScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>>
  get _passwordRequestsStream =>
      _firestore
          .collection(
            'password_reset_requests',
          )
          .where(
            'status',
            isEqualTo: 'pending',
          )
          .snapshots();

  Future<void> _updateRequestStatus(
    String requestId,
    String status,
    String email,
  ) async {
    try {
      // Update Firestore request status
      await _firestore
          .collection(
            'password_reset_requests',
          )
          .doc(requestId)
          .update({
            'status': status,
            'processedAt':
                Timestamp.now(),
          });

      // Send reset email if approved
      if (status == 'approved') {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(
              email: email,
            );

        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
                SnackBar(
                  backgroundColor:
                      Colors.green,
                  duration:
                      const Duration(
                        seconds: 4,
                      ),
                  content: Text(
                    'Approved successfully.\nReset email sent to $email',
                  ),
                ),
              );
        }
      } else {
        // Rejected
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
                const SnackBar(
                  backgroundColor:
                      Colors.red,
                  content: Text(
                    'Password reset request rejected',
                  ),
                ),
              );
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
            SnackBar(
              backgroundColor:
                  Colors.red,
              content: Text(
                'Firebase Error: ${e.message}',
              ),
            ),
          );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
            SnackBar(
              backgroundColor:
                  Colors.red,
              content: Text(
                'Error: $e',
              ),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.backgroundAlt,
      appBar: AppBar(
        backgroundColor:
            AppColors.backgroundAlt,
        elevation: 0,
        title: const Text(
          'Password Approvals',
          style: TextStyle(
            color: Colors.black,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>
      >(
        stream: _passwordRequestsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final requests =
              snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(
              child: Text(
                'No pending requests',
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (
              context,
              index,
            ) {
              final request =
                  requests[index];

              final data =
                  request.data();

              final email =
                  data['email'] ?? '';

              final requestedAt =
                  data['requestedAt']
                      ?.toDate();

              final requestDate =
                  requestedAt != null
                      ? DateFormat(
                        'MMM d, yyyy',
                      ).format(
                        requestedAt,
                      )
                      : '';

              return Container(
                margin:
                    const EdgeInsets.only(
                      bottom: 16,
                    ),
                padding:
                    const EdgeInsets.all(
                      18,
                    ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                        20,
                      ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(
                            0.05,
                          ),
                      blurRadius: 10,
                      offset:
                          const Offset(
                            0,
                            4,
                          ),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              AppColors
                                  .accent,
                          child: Text(
                            email
                                    .isNotEmpty
                                ? email[0]
                                    .toUpperCase()
                                : '?',
                            style:
                                const TextStyle(
                                  color:
                                      Colors
                                          .black,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                email,
                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  fontSize:
                                      16,
                                ),
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              const Text(
                                'Password Reset Request',
                                style: TextStyle(
                                  color:
                                      Colors
                                          .grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    Text(
                      'Requested: $requestDate',
                      style:
                          const TextStyle(
                            color:
                                Colors
                                    .black87,
                          ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                _updateRequestStatus(
                                  request.id,
                                  'approved',
                                  email,
                                ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppColors
                                      .accent,
                              padding:
                                  const EdgeInsets.symmetric(
                                    vertical:
                                        14,
                                  ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                      12,
                                    ),
                              ),
                            ),
                            child: const Text(
                              'Approve',
                              style: TextStyle(
                                color:
                                    Colors
                                        .black,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                _updateRequestStatus(
                                  request.id,
                                  'rejected',
                                  email,
                                ),
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(
                                    vertical:
                                        14,
                                  ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                      12,
                                    ),
                              ),
                            ),
                            child: const Text(
                              'Reject',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}