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
                onSettingsTap: () {},
              ),
              const SizedBox(height: 4),

              // ── White Screen Time Card ──────────────────────────────────
              ScreenTimeCard(
                onReportLoaded: (report) {
                  if (mounted) setState(() => _report = report);
                },
              ),

              // ── Yellow Focus Score Card (overlaps white by ~40px) ────────
              Transform.translate(
                offset: const Offset(0, -40),
                child: FocusScoreCard(report: _report),
              ),

              // ── Button ──────────────────────────────────────────────────
              Transform.translate(
                offset: const Offset(0, -28),
                child: FocusSessionButton(
                  lastSession: 'Last session: 2 hours ago',
                  onTap: () {
                    // TODO: start focus session screen
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

