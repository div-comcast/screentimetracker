import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/header.dart';
import '../widgets/calendar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime? _selectedStart;
  DateTime? _selectedEnd;

  void _openCalendar() {
    showCalendarSheet(
      context,
      onApply: (start, end) {
        setState(() {
          _selectedStart = start;
          _selectedEnd = end;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenTimeHeader(onCalendarTap: _openCalendar),
          ],
        ),
      ),
    );
  }
}
