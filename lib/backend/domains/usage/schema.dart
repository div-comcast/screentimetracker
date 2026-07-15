import 'dart:convert';
import 'dart:typed_data';
import '../utils.dart';


enum AppSortOrder { byTime, bySessions }

enum AppCategory {
  all,
  games,
  audio,
  videos,
  photos,
  social,
  news,
  maps,
  productivity,
  other;

  String get label => switch (this) {
    AppCategory.all          => 'All',
    AppCategory.games        => 'Games',
    AppCategory.audio        => 'Audio',
    AppCategory.videos       => 'Videos',
    AppCategory.photos       => 'Photos',
    AppCategory.social       => 'Social',
    AppCategory.news         => 'News',
    AppCategory.maps         => 'Maps',
    AppCategory.productivity => 'Productivity',
    AppCategory.other        => 'Other',
  };

  static AppCategory fromString(String value) => AppCategory.values.firstWhere(
    (e) => e.label == value,
    orElse: () => AppCategory.other,
  );
}

class AppSession {
  final DateTime start;
  final DateTime end;
  final int duration;

  AppSession({
    required this.start,
    required this.end,
    required this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'start': formatDateTime(start),
      'end': formatDateTime(end),
      'duration': formatMs(duration),
    };
  }
}

class AppDailyRecord {
  final String packageName;
  final String appName;
  final Uint8List? appIcon;
  final String category;
  final DateTime date;
  final int actualTimeUsed;
  final double usagePercentage;
  final DateTime firstUsed;
  final DateTime lastUsed;
  int get sessionCount => sessions.length;
  final List<AppSession> sessions;

  AppDailyRecord({
    required this.packageName,
    required this.appName,
    this.appIcon,
    this.category = 'Other',
    required this.date,
    required this.actualTimeUsed,
    this.usagePercentage = 0.0,
    required this.firstUsed,
    required this.lastUsed,
    this.sessions = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'packageName': packageName,
      'appName': appName,
      'appIcon': appIcon != null ? '${base64Encode(appIcon!).substring(0, 6)}...' : null,
      'category': category,
      'date': formatDateTime(date),
      'actualTimeUsed': formatMs(actualTimeUsed),
      'usagePercentage': '${usagePercentage.toStringAsFixed(1)}%',
      'sessionCount': sessionCount,
      'firstUsed': formatDateTime(firstUsed),
      'lastUsed': formatDateTime(lastUsed),
      'sessions': {
        for (var i = 0; i < sessions.length; i++) '${i + 1}': sessions[i].toJson(),
      },
    };
  }
}

class DailyKpiRecord {
  final int derivedTimeUsed;
  final int totalSessionCount;
  final DateTime firstActivity;
  final DateTime lastActivity;
  final int totalAppsUsed;
  final int longestSession;
  // Positive = more than yesterday, negative = less, null = no yesterday data.
  final double? vsYesterdayPct;

  DailyKpiRecord({
    required this.derivedTimeUsed,
    required this.totalSessionCount,
    required this.firstActivity,
    required this.lastActivity,
    required this.totalAppsUsed,
    this.longestSession = 0,
    this.vsYesterdayPct,
  });

  Map<String, dynamic> toJson() {
    return {
      'derivedTimeUsed': formatMs(derivedTimeUsed),
      'totalSessionCount': totalSessionCount,
      'firstActivity': formatDateTime(firstActivity),
      'lastActivity': formatDateTime(lastActivity),
      'totalAppsUsed': totalAppsUsed,
      'longestSession': formatMs(longestSession),
      'vsYesterdayPct': vsYesterdayPct != null
          ? '${vsYesterdayPct! >= 0 ? '+' : ''}${vsYesterdayPct!.toStringAsFixed(1)}%'
          : null,
    };
  }
}

/// Top-level response for a date-range query.
/// [kpi] is pure scalar numbers. [mostUsedApp]/[mostVisitedApp] are richer objects
/// that live here rather than in kpi. [apps] is sorted by actualTimeUsed descending.
class DailyUsageReport {
  final DailyKpiRecord kpi;
  final List<AppDailyRecord> apps;

  DailyUsageReport({
    required this.kpi,
    required this.apps,
  });

  Map<String, dynamic> toJson() => {
        'kpi': kpi.toJson(),
        'apps': {
          for (var i = 0; i < apps.length; i++) '${i + 1}': apps[i].toJson(),
        },
      };
}

class HourKpiRecord {
  final DateTime hourStart;
  final DateTime hourEnd;
  final int derivedTimeUsed;
  final int totalSessionCount;
  final DateTime? firstActivity;
  final DateTime? lastActivity;

  HourKpiRecord({
    required this.hourStart,
    required this.hourEnd,
    required this.derivedTimeUsed,
    required this.totalSessionCount,
    this.firstActivity,
    this.lastActivity,
  });

  Map<String, dynamic> toJson() => {
        'hourStart': formatDateTime(hourStart),
        'hourEnd': formatDateTime(hourEnd),
        'derivedTimeUsed': formatMs(derivedTimeUsed),
        'totalSessionCount': totalSessionCount,
        'firstActivity': firstActivity != null ? formatDateTime(firstActivity!) : null,
        'lastActivity': lastActivity != null ? formatDateTime(lastActivity!) : null,
      };
}

class HourlyUsageReport {
  final DailyKpiRecord kpi;
  final HourKpiRecord? peakHour;
  final List<HourKpiRecord> hours;

  HourlyUsageReport({
    required this.kpi,
    this.peakHour,
    required this.hours,
  });

  Map<String, dynamic> toJson() => {
        'kpi': kpi.toJson(),
        'peakHour': peakHour?.toJson(),
        'hours': {
          for (var i = 0; i < hours.length; i++) '${i + 1}': hours[i].toJson(),
        },
      };
}

/// A single app window in the day timeline — one continuous foreground period.
class TimelineEntry {
  final String packageName;
  final String appName;
  final Uint8List? appIcon;
  final DateTime start;
  final DateTime end;
  final int duration; // ms

  TimelineEntry({
    required this.packageName,
    required this.appName,
    this.appIcon,
    required this.start,
    required this.end,
    required this.duration,
  });

  Map<String, dynamic> toJson() => {
        'packageName': packageName,
        'appName': appName,
        'appIcon': appIcon != null ? '${base64Encode(appIcon!).substring(0, 6)}...' : null,
        'start': formatDateTime(start),
        'end': formatDateTime(end),
        'duration': formatMs(duration),
      };
}

/// Full day timeline: ordered list of app windows from midnight to midnight.
/// [derivedTimeUsed] is the sum of all entry durations.
class DayTimeline {
  final DateTime date;
  final int derivedTimeUsed;
  final List<TimelineEntry> entries;

  DayTimeline({
    required this.date,
    required this.derivedTimeUsed,
    required this.entries,
  });

  Map<String, dynamic> toJson() => {
        'date': formatDateTime(date),
        'derivedTimeUsed': formatMs(derivedTimeUsed),
        'entries': {
          for (var i = 0; i < entries.length; i++) '${i + 1}': entries[i].toJson(),
        },
      };
}

/// One calendar day's totals inside a [WeeklyUsageReport].
/// Mirrors [AppDailyRecord] fields at the day level — no per-app breakdown, no sessions.
class WeeklyDayRecord {
  final DateTime date;
  final int actualTimeUsed;
  final int sessionCount;
  final DateTime? firstUsed;
  final DateTime? lastUsed;
  final int totalAppsUsed;

  WeeklyDayRecord({
    required this.date,
    required this.actualTimeUsed,
    required this.sessionCount,
    this.firstUsed,
    this.lastUsed,
    required this.totalAppsUsed,
  });

  Map<String, dynamic> toJson() => {
        'date': formatDateTime(date),
        'actualTimeUsed': formatMs(actualTimeUsed),
        'sessionCount': sessionCount,
        'firstUsed': firstUsed != null ? formatDateTime(firstUsed!) : null,
        'lastUsed': lastUsed != null ? formatDateTime(lastUsed!) : null,
        'totalAppsUsed': totalAppsUsed,
      };
}

/// Weekly usage report: one [WeeklyDayRecord] per day, plus stats derived from those days.
/// [days] is sorted oldest → newest. Aggregate fields are computed across all days in range.
class WeeklyUsageReport {
  final int derivedTimeUsed;
  final int averageDailyTime;
  final int peakDailyTime;
  final DateTime peakDay;
  final int activeDays;
  final int totalSessionCount;
  final List<WeeklyDayRecord> days;

  WeeklyUsageReport({
    required this.derivedTimeUsed,
    required this.averageDailyTime,
    required this.peakDailyTime,
    required this.peakDay,
    required this.activeDays,
    required this.totalSessionCount,
    required this.days,
  });

  Map<String, dynamic> toJson() => {
        'derivedTimeUsed': formatMs(derivedTimeUsed),
        'averageDailyTime': formatMs(averageDailyTime),
        'peakDailyTime': formatMs(peakDailyTime),
        'peakDay': formatDateTime(peakDay),
        'activeDays': activeDays,
        'totalSessionCount': totalSessionCount,
        'days': {
          for (var i = 0; i < days.length; i++) '${i + 1}': days[i].toJson(),
        },
      };
}
