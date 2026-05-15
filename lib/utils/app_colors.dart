import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // =========================
  // CORE BRAND COLORS
  // =========================

  /// Deep Navy
  static const Color primary = Color(0xFF1A237E);

  /// Vibrant Cyan
  static const Color accent = Color(0xFF00BCD4);

  /// Secondary Teal
  static const Color secondary = Color(0xFF006876);

  // =========================
  // BACKGROUNDS & SURFACES
  // =========================

  static const Color background = Color(0xFFFAF9F9);

  static const Color backgroundAlt = Color(0xFFF4F3F3);

  static const Color surface = Color(0xFFFFFFFF);

  static const Color surfaceContainer = Color(0xFFEFEEED);

  // =========================
  // TEXT COLORS
  // =========================

  static const Color primaryText = Color(0xFF1A1C1C);

  static const Color secondaryText = Color(0xFF454652);

  static const Color lightText = Color(0xFFF1F0F0);

  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color onAccent = Color(0xFFFFFFFF);

  // =========================
  // STATUS COLORS
  // =========================

  static const Color success = Color(0xFF4CAF50);

  static const Color warning = Color(0xFFFFC107);

  static const Color error = Color(0xFFBA1A1A);

  static const Color info = Color(0xFF1E88E5);

  // =========================
  // BORDERS & OUTLINES
  // =========================

  static const Color border = Color(0xFFE0E0E0);

  // =========================
  // CARD COLORS
  // =========================

  static const Color card = Colors.white;

  static const Color cardBorder = Color(0xFFECEFF1);

  // =========================
  // SHADOWS
  // =========================

  static Color shadowLow = const Color(
    0xFF1A237E,
  ).withOpacity(0.04);

  static Color shadowMid = const Color(
    0xFF1A237E,
  ).withOpacity(0.08);

  static Color shadowHigh = const Color(
    0xFF1A237E,
  ).withOpacity(0.14);

  // =========================
  // GRADIENTS
  // =========================

  static const LinearGradient primaryGradient =
      LinearGradient(
        colors: [
          Color(0xFF1A237E),
          Color(0xFF000F5B),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static const LinearGradient accentGradient =
      LinearGradient(
        colors: [
          Color(0xFF00BCD4),
          Color(0xFF58E6FF),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}