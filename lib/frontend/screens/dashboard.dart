import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/header.dart';
import '../widgets/calendar.dart';
import '../widgets/date_rangebar.dart';
import '../widgets/dashboard/kpi_card.dart';
import '../widgets/dashboard/chart_section.dart';
import '../widgets/dashboard/app_usage.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DateTime _selectedStart;
  late DateTime _selectedEnd;
  late final DateTime _minDate;
  late final DateTime _maxDate;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _maxDate = DateTime(today.year, today.month, today.day);
    _minDate = _maxDate.subtract(const Duration(days: 20));
    _selectedStart = _maxDate;
    _selectedEnd = _maxDate;
  }

  void _openCalendar() {
    showCalendarSheet(
      context,
      onApply: (start, end) {
        setState(() {
          _selectedStart = start;
          _selectedEnd = end ?? start;
        });
      },
    );
  }

  void _shiftBack() {
    final span = _selectedEnd.difference(_selectedStart).inDays;
    final newStart = _selectedStart.subtract(const Duration(days: 1));
    if (newStart.isBefore(_minDate)) return;
    setState(() {
      _selectedStart = newStart;
      _selectedEnd = newStart.add(Duration(days: span));
    });
  }

  void _shiftForward() {
    final span = _selectedEnd.difference(_selectedStart).inDays;
    final newEnd = _selectedEnd.add(const Duration(days: 1));
    if (newEnd.isAfter(_maxDate)) return;
    setState(() {
      _selectedEnd = newEnd;
      _selectedStart = newEnd.subtract(Duration(days: span));
    });
  }

  bool get _canGoBack => _selectedStart.isAfter(_minDate);
  bool get _canGoForward => _selectedEnd.isBefore(_maxDate);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenTimeHeader(onCalendarTap: _openCalendar),
              DateBar(
                start: _selectedStart,
                end: _selectedStart == _selectedEnd ? null : _selectedEnd,
                onTap: _openCalendar,
                onBack: _canGoBack ? _shiftBack : null,
                onForward: _canGoForward ? _shiftForward : null,
              ),
              const SizedBox(height: 12),
              KpiCard(
                start: _selectedStart,
                end: _selectedEnd,
              ),
              const SizedBox(height: 20),
              ChartSection(
                start: _selectedStart,
                end: _selectedEnd,
              ),
              const SizedBox(height: 24),
              AppUsageSection(
                start: _selectedStart,
                end: _selectedEnd,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
