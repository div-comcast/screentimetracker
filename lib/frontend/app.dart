import 'package:flutter/material.dart';
import 'screens/dashboard.dart';

class ScreenTimeTrackerApp extends StatelessWidget {
  const ScreenTimeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screen Time Tracker',
      debugShowCheckedModeBanner: false,
      home: const DashboardScreen(),
    );
  }
}
