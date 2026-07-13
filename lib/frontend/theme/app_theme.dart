import 'package:flutter/material.dart';

/// Centralized theme constants matching the design's purple/indigo palette.
class AppTheme {
  AppTheme._();

  // ─── Primary Colors ─────────────────────────────────────────────────
  static const Color primary = Color(0xFF5B5FC7);
  static const Color primaryLight = Color(0xFF7C80D7);
  static const Color primaryDark = Color(0xFF4A4EB5);
  static const Color scaffoldBg = Color(0xFFF5F5FA);
  static const Color cardBg = Colors.white;
  static const Color summaryCardBg = Color(0xFF5B5FC7);

  // ─── Accent / Semantic ──────────────────────────────────────────────
  static const Color green = Color(0xFF4CAF50);
  static const Color red = Color(0xFFE85D75);
  static const Color orange = Color(0xFFF47521);

  // ─── Text Colors ────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1E1E2D);
  static const Color textSecondary = Color(0xFF6E6E82);
  static const Color textOnPrimary = Colors.white;
  static const Color textMuted = Color(0xFF9E9EB8);

  // ─── Text Styles ────────────────────────────────────────────────────
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: textOnPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textMuted,
  );

  static const TextStyle labelBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  // ─── Decorations ────────────────────────────────────────────────────
  static BorderRadius cardRadius = BorderRadius.circular(20);
  static BorderRadius tileRadius = BorderRadius.circular(16);

  static BoxDecoration tileDecoration = BoxDecoration(
    color: cardBg,
    borderRadius: tileRadius,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
