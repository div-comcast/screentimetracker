import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Frontend-only mock models & data.
///
/// These mirror the shape of the backend reports (DailyUsageReport,
/// HourlyUsageReport, WeeklyUsageReport, DayTimeline) but are completely
/// independent so the UI can be built and previewed without any wiring.
/// Replace this file's data with real report objects when wiring the backend.
/// ─────────────────────────────────────────────────────────────────────────

/// Formats a whole number of minutes into "Xh Ym" / "Ym".
String formatMinutes(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h > 0) return m > 0 ? '${h}h ${m}m' : '${h}h';
  return '${m}m';
}

class MockApp {
  final String appName;
  final String packageName;
  final String category;
  final IconData icon;
  final Color color;
  final int minutes;
  final int sessions;
  final double percentage;
  final String firstUsed;
  final String lastUsed;

  /// Daily limit in minutes (null = no limit set).
  final int? dailyLimitMinutes;
  final bool alertEnabled;

  const MockApp({
    required this.appName,
    required this.packageName,
    required this.category,
    required this.icon,
    required this.color,
    required this.minutes,
    required this.sessions,
    required this.percentage,
    required this.firstUsed,
    required this.lastUsed,
    this.dailyLimitMinutes,
    this.alertEnabled = false,
  });

  /// Progress toward the daily limit (0..1+, null if no limit).
  double? get limitProgress =>
      dailyLimitMinutes == null ? null : minutes / dailyLimitMinutes!;

  bool get overLimit =>
      dailyLimitMinutes != null && minutes > dailyLimitMinutes!;
}

class HourBucket {
  final int hour; // 0..23
  final int minutes;
  final int sessions;
  const HourBucket(this.hour, this.minutes, this.sessions);
}

class WeeklyDay {
  final String label; // Mon, Tue...
  final DateTime date;
  final int minutes;
  final int sessions;
  final int appsUsed;
  const WeeklyDay({
    required this.label,
    required this.date,
    required this.minutes,
    required this.sessions,
    required this.appsUsed,
  });
}

class TimelineBlock {
  final String appName;
  final String category;
  final IconData icon;
  final Color color;
  final String start; // "09:15"
  final String end; // "09:42"
  final int minutes;
  const TimelineBlock({
    required this.appName,
    required this.category,
    required this.icon,
    required this.color,
    required this.start,
    required this.end,
    required this.minutes,
  });
}

/// Static demo dataset used by every tab.
class MockData {
  MockData._();

  static const List<String> categories = [
    'All',
    'Social',
    'Videos',
    'Games',
    'Productivity',
    'Audio',
    'News',
    'Photos',
    'Maps',
    'Other',
  ];

  // ── Daily KPI summary ────────────────────────────────────────────────
  static const int totalScreenMinutes = 337; // 5h 37m
  static const int totalSessions = 84;
  static const int appsUsed = 17;
  static const int longestSessionMinutes = 52;
  static const String firstActivity = '07:12';
  static const String lastActivity = '23:41';
  static const double vsYesterdayPct = -8.3;

  // ── Per-app breakdown ────────────────────────────────────────────────
  static const List<MockApp> apps = [
    MockApp(
      appName: 'Instagram',
      packageName: 'com.instagram.android',
      category: 'Social',
      icon: Icons.camera_alt_rounded,
      color: Color(0xFF3B82F6),
      minutes: 78,
      sessions: 23,
      percentage: 23.1,
      firstUsed: '07:45',
      lastUsed: '23:20',
      dailyLimitMinutes: 60,
      alertEnabled: true,
    ),
    MockApp(
      appName: 'YouTube',
      packageName: 'com.google.android.youtube',
      category: 'Videos',
      icon: Icons.play_circle_fill_rounded,
      color: Color(0xFFEF4444),
      minutes: 64,
      sessions: 12,
      percentage: 19.0,
      firstUsed: '08:30',
      lastUsed: '22:55',
      dailyLimitMinutes: 90,
      alertEnabled: true,
    ),
    MockApp(
      appName: 'WhatsApp',
      packageName: 'com.whatsapp',
      category: 'Social',
      icon: Icons.chat_rounded,
      color: Color(0xFF10B981),
      minutes: 45,
      sessions: 18,
      percentage: 13.4,
      firstUsed: '07:12',
      lastUsed: '23:41',
    ),
    MockApp(
      appName: 'Chrome',
      packageName: 'com.android.chrome',
      category: 'Productivity',
      icon: Icons.public_rounded,
      color: Color(0xFF06B6D4),
      minutes: 38,
      sessions: 9,
      percentage: 11.3,
      firstUsed: '09:02',
      lastUsed: '21:15',
    ),
    MockApp(
      appName: 'Spotify',
      packageName: 'com.spotify.music',
      category: 'Audio',
      icon: Icons.music_note_rounded,
      color: Color(0xFFF59E0B),
      minutes: 33,
      sessions: 6,
      percentage: 9.8,
      firstUsed: '08:00',
      lastUsed: '18:40',
      dailyLimitMinutes: 120,
    ),
    MockApp(
      appName: 'Clash of Clans',
      packageName: 'com.supercell.clashofclans',
      category: 'Games',
      icon: Icons.sports_esports_rounded,
      color: Color(0xFF8B5CF6),
      minutes: 27,
      sessions: 5,
      percentage: 8.0,
      firstUsed: '19:10',
      lastUsed: '22:30',
      dailyLimitMinutes: 30,
      alertEnabled: true,
    ),
    MockApp(
      appName: 'Gmail',
      packageName: 'com.google.android.gm',
      category: 'Productivity',
      icon: Icons.mail_rounded,
      color: Color(0xFF10B981),
      minutes: 21,
      sessions: 7,
      percentage: 6.2,
      firstUsed: '07:50',
      lastUsed: '20:05',
    ),
    MockApp(
      appName: 'Maps',
      packageName: 'com.google.android.apps.maps',
      category: 'Maps',
      icon: Icons.map_rounded,
      color: Color(0xFF14B8A6),
      minutes: 16,
      sessions: 3,
      percentage: 4.7,
      firstUsed: '12:20',
      lastUsed: '18:12',
    ),
    MockApp(
      appName: 'Reddit',
      packageName: 'com.reddit.frontpage',
      category: 'News',
      icon: Icons.forum_rounded,
      color: Color(0xFF06B6D4),
      minutes: 15,
      sessions: 8,
      percentage: 4.5,
      firstUsed: '10:15',
      lastUsed: '23:05',
    ),
  ];

  // ── Hourly report (0..23) ────────────────────────────────────────────
  static const List<HourBucket> hourly = [
    HourBucket(0, 0, 0),
    HourBucket(1, 0, 0),
    HourBucket(2, 0, 0),
    HourBucket(3, 0, 0),
    HourBucket(4, 0, 0),
    HourBucket(5, 0, 0),
    HourBucket(6, 3, 1),
    HourBucket(7, 18, 5),
    HourBucket(8, 26, 8),
    HourBucket(9, 21, 6),
    HourBucket(10, 14, 4),
    HourBucket(11, 9, 3),
    HourBucket(12, 24, 7),
    HourBucket(13, 17, 5),
    HourBucket(14, 11, 4),
    HourBucket(15, 8, 3),
    HourBucket(16, 13, 4),
    HourBucket(17, 19, 5),
    HourBucket(18, 28, 6),
    HourBucket(19, 34, 7),
    HourBucket(20, 41, 8),
    HourBucket(21, 30, 5),
    HourBucket(22, 22, 4),
    HourBucket(23, 9, 2),
  ];

  static int get peakHour =>
      hourly.reduce((a, b) => a.minutes >= b.minutes ? a : b).hour;

  // ── Weekly report ────────────────────────────────────────────────────
  static final List<WeeklyDay> weekly = [
    WeeklyDay(label: 'Mon', date: DateTime(2026, 7, 6), minutes: 298, sessions: 71, appsUsed: 15),
    WeeklyDay(label: 'Tue', date: DateTime(2026, 7, 7), minutes: 342, sessions: 88, appsUsed: 18),
    WeeklyDay(label: 'Wed', date: DateTime(2026, 7, 8), minutes: 401, sessions: 95, appsUsed: 19),
    WeeklyDay(label: 'Thu', date: DateTime(2026, 7, 9), minutes: 276, sessions: 64, appsUsed: 14),
    WeeklyDay(label: 'Fri', date: DateTime(2026, 7, 10), minutes: 368, sessions: 90, appsUsed: 17),
    WeeklyDay(label: 'Sat', date: DateTime(2026, 7, 11), minutes: 337, sessions: 84, appsUsed: 17),
    WeeklyDay(label: 'Sun', date: DateTime(2026, 7, 12), minutes: 189, sessions: 43, appsUsed: 11),
  ];

  static int get weeklyTotal =>
      weekly.fold(0, (sum, d) => sum + d.minutes);
  static int get weeklyAvg => (weeklyTotal / weekly.length).round();
  static WeeklyDay get weeklyPeak =>
      weekly.reduce((a, b) => a.minutes >= b.minutes ? a : b);
  static int get weeklyActiveDays =>
      weekly.where((d) => d.minutes > 0).length;
  static int get weeklySessions =>
      weekly.fold(0, (sum, d) => sum + d.sessions);

  // ── Day timeline ─────────────────────────────────────────────────────
  static const List<TimelineBlock> timeline = [
    TimelineBlock(appName: 'WhatsApp', category: 'Social', icon: Icons.chat_rounded, color: Color(0xFF10B981), start: '07:12', end: '07:28', minutes: 16),
    TimelineBlock(appName: 'Gmail', category: 'Productivity', icon: Icons.mail_rounded, color: Color(0xFF10B981), start: '07:50', end: '08:04', minutes: 14),
    TimelineBlock(appName: 'Instagram', category: 'Social', icon: Icons.camera_alt_rounded, color: Color(0xFF3B82F6), start: '08:10', end: '08:39', minutes: 29),
    TimelineBlock(appName: 'Spotify', category: 'Audio', icon: Icons.music_note_rounded, color: Color(0xFFF59E0B), start: '08:40', end: '09:12', minutes: 32),
    TimelineBlock(appName: 'Chrome', category: 'Productivity', icon: Icons.public_rounded, color: Color(0xFF06B6D4), start: '09:15', end: '09:44', minutes: 29),
    TimelineBlock(appName: 'YouTube', category: 'Videos', icon: Icons.play_circle_fill_rounded, color: Color(0xFFEF4444), start: '12:20', end: '13:12', minutes: 52),
    TimelineBlock(appName: 'Maps', category: 'Maps', icon: Icons.map_rounded, color: Color(0xFF14B8A6), start: '18:00', end: '18:16', minutes: 16),
    TimelineBlock(appName: 'Clash of Clans', category: 'Games', icon: Icons.sports_esports_rounded, color: Color(0xFF8B5CF6), start: '19:10', end: '19:38', minutes: 28),
    TimelineBlock(appName: 'Instagram', category: 'Social', icon: Icons.camera_alt_rounded, color: Color(0xFF3B82F6), start: '22:50', end: '23:20', minutes: 30),
  ];
}
