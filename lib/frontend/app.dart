import 'package:flutter/material.dart';
import 'screens/dashboard.dart';
import 'screens/loading_screen.dart';

class ScreenTimeTrackerApp extends StatelessWidget {
  const ScreenTimeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screen Time Tracker',
      debugShowCheckedModeBanner: false,
      home: const LoadingScreen(child: DashboardScreen()),
    );
  }
}
