import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_shell.dart';

/// Root widget for the frontend skeleton. Owns the theme-mode state and
/// wires the light/dark themes. This is UI-only — no backend imports.
class ScreenTimeApp extends StatefulWidget {
  const ScreenTimeApp({super.key});

  @override
  State<ScreenTimeApp> createState() => _ScreenTimeAppState();
}

class _ScreenTimeAppState extends State<ScreenTimeApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screen Time Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      home: HomeShell(
        themeMode: _themeMode,
        onThemeModeChanged: (m) => setState(() => _themeMode = m),
      ),
    );
  }
}
