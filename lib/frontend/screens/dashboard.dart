import 'package:flutter/material.dart';
import '../widgets/top_header.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2EDE4),
      body: SafeArea(
        child: SingleChildScrollView(
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

              // ── Remaining dashboard sections go here ────────────────────
              // e.g. ScreenTimeCard, FocusScoreCard, StartFocusButton …
            ],
          ),
        ),
      ),
    );
  }
}
