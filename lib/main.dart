import 'package:flutter/material.dart';
import 'backend/bridge/cache_data.dart';
import 'backend/domains/usage/reports.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final today = DateTime.now();
  await fetchRawCache(
    startDate: today.subtract(const Duration(days: 13)),
    endDate: today,
  );

  await getDailyUsageReport(startDate: DateTime(2026, 7, 10), endDate: DateTime(2026, 7, 10));

  await getDailyUsageReport();

  await getHourlyUsageReport(startDate: DateTime(2026, 7, 10), endDate: DateTime(2026, 7, 10));

  await getHourlyUsageReport();

  await getDayTimeline(startDate: DateTime(2026, 7, 10), endDate: DateTime(2026, 7, 10));

  await getDayTimeline();

  await getWeeklyUsageReport(
    startDate: today.subtract(const Duration(days: 6)),
    endDate: today,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
