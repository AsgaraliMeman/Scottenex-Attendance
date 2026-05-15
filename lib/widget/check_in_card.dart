import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

Widget buildCheckInCard({
  required bool isCheckedIn,
  required DateTime? checkOutTime,
  required Function(bool) onAttendance,
  bool canInteract = true,
}) {
  /// Determine if it's a new day after checkout
  bool isNewDayAfterCheckout() {
    if (checkOutTime == null) return false;
    final checkOutDate = checkOutTime.toString().split(' ')[0];
    final todayDate = DateTime.now().toString().split(' ')[0];
    return checkOutDate != todayDate;
  }

  /// Determine if user should see check-in or check-out option
  bool shouldShowCheckIn() {
    if (!isCheckedIn) return true; // Not checked in yet
    if (checkOutTime != null && isNewDayAfterCheckout())
      return true; // New day after checkout
    return false; // Show check-out
  }
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),

    padding: const EdgeInsets.all(24),

    child: Column(
      children: [
        const Icon(
          Icons.schedule,
          color: AppColors.accent,
          size: 52,
        ),

        const SizedBox(height: 18),

        const Text(
          'Ready for duty?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          'Slide to confirm your presence for\n'
          'today\'s shift. Your location and time will\n'
          'be recorded.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.secondaryText,
            height: 1.6,
          ),
        ),

        const SizedBox(height: 34),

        /// MODERN FLIP SWITCH
        Opacity(
          opacity: canInteract ? 1.0 : 0.6,
          child: GestureDetector(
            onTap: canInteract
                ? () {
                    if (shouldShowCheckIn()) {
                      onAttendance(true); // Check in
                    } else {
                      onAttendance(false); // Check out
                    }
                  }
                : null,

            child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 350,
            ),

            width: 120,
            height: 210,

            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(30),

              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey.shade300,
                  Colors.grey.shade500,
                ],
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    0.25,
                  ),
                  blurRadius: 20,
                  offset: const Offset(8, 8),
                ),

                BoxShadow(
                  color: Colors.white.withOpacity(
                    0.9,
                  ),
                  blurRadius: 18,
                  offset: const Offset(-6, -6),
                ),
              ],
            ),

            child: Stack(
              children: [
                /// TOP IN
                Align(
                  alignment: Alignment.topCenter,

                  child: Padding(
                    padding:
                        const EdgeInsets.only(
                          top: 16,
                        ),

                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,

                      children: [
                        Container(
                          width: 14,
                          height: 14,

                          decoration: BoxDecoration(
                            shape:
                                BoxShape.circle,

                            color:
                                Colors.cyanAccent,

                            boxShadow: [
                              BoxShadow(
                                color: Colors
                                    .cyanAccent
                                    .withOpacity(
                                      0.9,
                                    ),

                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        const Text(
                          "IN",

                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,

                            fontSize: 15,

                            color:
                                Color(
                                  0xFF0D1B8C,
                                ),

                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// BOTTOM OUT
                Align(
                  alignment:
                      Alignment.bottomCenter,

                  child: Padding(
                    padding:
                        const EdgeInsets.only(
                          bottom: 16,
                        ),

                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,

                      children: [
                        const Text(
                          "OUT",

                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,

                            fontSize: 15,

                            color: Colors.red,

                            letterSpacing: 1,
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        Container(
                          width: 14,
                          height: 14,

                          decoration: BoxDecoration(
                            shape:
                                BoxShape.circle,

                            color: Colors.red,

                            boxShadow: [
                              BoxShadow(
                                color: Colors.red
                                    .withOpacity(
                                      0.7,
                                    ),

                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// SWITCH HANDLE
                AnimatedAlign(
                  duration: const Duration(
                    milliseconds: 350,
                  ),

                  curve: Curves.easeInOut,

                  alignment: shouldShowCheckIn()
                      ? Alignment.bottomCenter
                      : Alignment.topCenter,

                  child: Container(
                    width: 90,
                    height: 90,

                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(
                            24,
                          ),

                      gradient: LinearGradient(
                        begin:
                            Alignment.topLeft,

                        end: Alignment
                            .bottomRight,

                        colors: [
                          Colors.white,
                          Colors.grey.shade300,
                        ],
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(
                                0.2,
                              ),

                          blurRadius: 12,

                          offset:
                              const Offset(
                                4,
                                5,
                              ),
                        ),
                      ],
                    ),

                    child: Center(
                      child: AnimatedSwitcher(
                        duration:
                            const Duration(
                              milliseconds:
                                  300,
                            ),

                        child: Icon(
                          shouldShowCheckIn()
                              ? Icons.power_settings_new
                              : Icons.flash_on,

                          key: ValueKey(
                            shouldShowCheckIn(),
                          ),

                          size: 40,

                          color: shouldShowCheckIn()
                              ? Colors.red
                              : Colors.cyanAccent,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ),

        const SizedBox(height: 22),

        Text(
          shouldShowCheckIn()
              ? 'FLIP SWITCH TO CHECK IN'
              : 'FLIP SWITCH TO CHECK OUT',

          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.secondaryText,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: 12),

        if (!canInteract)
          const Text(
            'Your shift has ended for today',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFFB0BEC5),
              fontStyle: FontStyle.italic,
            ),
          )
        else
          const SizedBox.shrink(),

        const SizedBox(height: 6),

      
      ],
    ),
  );
} 