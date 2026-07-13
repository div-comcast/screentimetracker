import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard.dart';
import 'screens/focus.dart';
import 'screens/limits.dart';
import 'screens/reports.dart';
import 'screens/timeline.dart';
import 'widgets/bottom_navbar.dart';

/// Root widget — holds the bottom nav and swaps screens.
class ScreenTimeApp extends StatelessWidget {
  const ScreenTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screen Time Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: AppTheme.primary,
        scaffoldBackgroundColor: AppTheme.scaffoldBg,
        useMaterial3: true,
      ),
      home: const _AppShell(),
    );
  }
}

class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _currentNav = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNav,
        onTap: (i) => setState(() => _currentNav = i),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentNav) {
      case 0:
        return const DashboardScreen();
      case 1:
        return TimelineScreen();
      case 2:
        return const ReportsScreen();
      case 3:
        return const FocusScreen();
      case 4:
        return const LimitsScreen();
      default:
        return const DashboardScreen();
    }
  }
}
