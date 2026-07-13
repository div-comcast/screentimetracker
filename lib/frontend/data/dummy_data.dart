import 'package:flutter/material.dart';

/// Dummy data models and mock values for the frontend skeleton.
/// Replace with real backend wiring later.

class DummyAppUsage {
  final int rank;
  final String appName;
  final String category;
  final IconData iconData;
  final Color iconColor;
  final String usageTime;
  final double usagePercent;
  final String timeRange;
  final int sessions;

  const DummyAppUsage({
    required this.rank,
    required this.appName,
    required this.category,
    required this.iconData,
    required this.iconColor,
    required this.usageTime,
    required this.usagePercent,
    required this.timeRange,
    required this.sessions,
  });
}

class DummyKpi {
  final String totalScreenTime;
  final double vsYesterdayPct;
  final bool isUp;
  final int appsUsed;
  final String firstActivity;
  final String lastActivity;
  final int sessionCount;
  final String longestSession;

  const DummyKpi({
    required this.totalScreenTime,
    required this.vsYesterdayPct,
    required this.isUp,
    required this.appsUsed,
    required this.firstActivity,
    required this.lastActivity,
    required this.sessionCount,
    required this.longestSession,
  });
}

class DummyDonutSegment {
  final double percent;
  final Color color;

  const DummyDonutSegment({required this.percent, required this.color});
}

// ─── Mock Data ──────────────────────────────────────────────────────────

const dummyDate = '10 July 2026';

const dummyKpi = DummyKpi(
  totalScreenTime: '7h 50m',
  vsYesterdayPct: 5.4,
  isUp: true,
  appsUsed: 33,
  firstActivity: '08:09 AM',
  lastActivity: '11:47 PM',
  sessionCount: 265,
  longestSession: '48m 39s',
);

const dummyDonutSegments = [
  DummyDonutSegment(percent: 0.85, color: Color(0xFF5B5FC7)),
  DummyDonutSegment(percent: 0.10, color: Color(0xFF7C80D7)),
  DummyDonutSegment(percent: 0.05, color: Color(0xFFE85D75)),
];

const dummyApps = [
  DummyAppUsage(
    rank: 1,
    appName: 'Digital Wellbeing',
    category: 'Productivity',
    iconData: Icons.location_on,
    iconColor: Color(0xFF4CAF50),
    usageTime: '1h 39m',
    usagePercent: 21.1,
    timeRange: '11:18 AM – 09:43 PM',
    sessions: 42,
  ),
  DummyAppUsage(
    rank: 2,
    appName: 'screentimetracker',
    category: 'Other',
    iconData: Icons.bar_chart,
    iconColor: Color(0xFF5B5FC7),
    usageTime: '1h 39m',
    usagePercent: 21.1,
    timeRange: '09:41 AM – 10:34 PM',
    sessions: 30,
  ),
  DummyAppUsage(
    rank: 3,
    appName: 'Instagram',
    category: 'Social',
    iconData: Icons.camera_alt,
    iconColor: Color(0xFFE1306C),
    usageTime: '1h 10m',
    usagePercent: 14.9,
    timeRange: '08:46 AM – 10:16 PM',
    sessions: 28,
  ),
  DummyAppUsage(
    rank: 4,
    appName: 'Crunchyroll',
    category: 'Entertainment',
    iconData: Icons.play_circle_fill,
    iconColor: Color(0xFFF47521),
    usageTime: '1h 03m',
    usagePercent: 13.5,
    timeRange: '12:33 PM – 11:46 PM',
    sessions: 3,
  ),
  DummyAppUsage(
    rank: 5,
    appName: 'YouTube',
    category: 'Videos',
    iconData: Icons.play_arrow,
    iconColor: Color(0xFFFF0000),
    usageTime: '52m',
    usagePercent: 11.1,
    timeRange: '09:00 AM – 10:00 PM',
    sessions: 15,
  ),
  DummyAppUsage(
    rank: 6,
    appName: 'WhatsApp',
    category: 'Social',
    iconData: Icons.chat,
    iconColor: Color(0xFF25D366),
    usageTime: '38m',
    usagePercent: 8.1,
    timeRange: '08:15 AM – 11:30 PM',
    sessions: 45,
  ),
  DummyAppUsage(
    rank: 7,
    appName: 'Chrome',
    category: 'Productivity',
    iconData: Icons.language,
    iconColor: Color(0xFF4285F4),
    usageTime: '22m',
    usagePercent: 4.7,
    timeRange: '10:00 AM – 09:00 PM',
    sessions: 12,
  ),
];
