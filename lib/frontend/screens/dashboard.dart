import 'package:flutter/material.dart';
import '../../backend/domains/usage/schema.dart';
import '../widgets/top_header.dart';
import '../widgets/screen_time_card.dart';
import '../widgets/focus_score_card.dart';
import '../widgets/focus_session_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DailyUsageReport? _report;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2EDE4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Header ──────────────────────────────────────────────
              TopHeader(
                userName: 'Celeste',
                onSettingsTap: () {
                  // TODO: navigate to settings
                },
              ),
              const SizedBox(height: 4),

              // ── Screen Time Card ────────────────────────────────────────
              ScreenTimeCard(
                onReportLoaded: (report) {
                  if (mounted) setState(() => _report = report);
                },
              ),
              const SizedBox(height: 16),

              // ── Focus Score Card ────────────────────────────────────────
              FocusScoreCard(report: _report),
              const SizedBox(height: 20),

              // ── Start Focus Session Button ───────────────────────────────
              FocusSessionButton(
                lastSession: 'Last session: 2 hours ago',
                onTap: () {
                  // TODO: start focus session screen
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

