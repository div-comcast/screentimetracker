import 'package:flutter/material.dart';

/// Central theme definitions for the Screen Time Tracker UI.
///
/// Uses a blue seed color that reads well in both light and dark modes.
/// This file is UI-only and has no dependency on the backend.
class AppTheme {
  AppTheme._();

  /// Primary brand blue — balanced for light and dark surfaces.
  static const Color seed = Color(0xFF2563EB); // blue-600

  /// Category accent colors used across charts, chips and tiles.
  static const Map<String, Color> categoryColors = {
    'Social': Color(0xFF3B82F6), // blue
    'Videos': Color(0xFFEF4444), // red
    'Games': Color(0xFF8B5CF6), // violet
    'Productivity': Color(0xFF10B981), // emerald
    'Audio': Color(0xFFF59E0B), // amber
    'News': Color(0xFF06B6D4), // cyan
    'Photos': Color(0xFFEC4899), // pink
    'Maps': Color(0xFF14B8A6), // teal
    'Other': Color(0xFF64748B), // slate
  };

  static Color categoryColor(String category) =>
      categoryColors[category] ?? categoryColors['Other']!;

  static ThemeData light() => _base(Brightness.light);

  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xFFF6F8FC)
          : const Color(0xFF0E1116),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: brightness == Brightness.light
            ? const Color(0xFFF6F8FC)
            : const Color(0xFF0E1116),
        foregroundColor: scheme.onSurface,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        color: brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF171B22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 3,
        height: 68,
        backgroundColor: brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF141821),
        indicatorColor: scheme.primary.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: scheme.onSurface,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.4),
        thickness: 1,
      ),
    );
  }
}
