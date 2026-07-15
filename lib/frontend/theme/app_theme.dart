import 'package:flutter/material.dart';

class AppColors {
  // Background
  static const Color background = Color(0xFFEEF0F8);
  static const Color cardBackground = Colors.white;

  // Primary blue used for the summary card and accents
  static const Color primary = Color(0xFF3D5AF1);
  static const Color primaryDark = Color(0xFF2A3DC7);

  // Text
  static const Color textPrimary = Color(0xFF1A1F36);
  static const Color textSecondary = Color(0xFF8A8FA8);

  // Icon button background
  static const Color iconButtonBg = Colors.white;
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        surface: AppColors.background,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
    );
  }
}
