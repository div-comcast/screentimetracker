import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../bridge/cache_data.dart';
import 'schema.dart';
import 'category.dart';
import 'helpers.dart';

// ─── Public API/Functions ──────────────────────────────────────────────────────────────

/// Returns a complete [DailyUsageReport] for a date range: KPI summary + per-app breakdown.
/// Defaults to today when no dates are supplied; single date sets both sides to the same day.

Future<List<AppSession>> getSessionsForApp(
  String packageName,
  DateTime startDate,
  DateTime endDate, {
  List<Map>? preloadedEvents,
}) async {
  // All events (all packages) are needed to track which package was last paused,
  // so we can apply the same "new launch = came from different app" rule as Kotlin.
  final allEvents = preloadedEvents ?? eventsForRange(startDate, endDate);

  final sessions = <AppSession>[];
  DateTime? sessionStart;
  DateTime? sessionLastBackground; // latest BACKGROUND for target app within current session
  String? lastPausedPkg;
  // True after a SCREEN_OFF so the next FOREGROUND always opens a fresh session,
  // even if the same app resumes (screen-off/on is not in-app navigation).
  var screenOffSinceLastFg = false;

  for (final event in allEvents) {
    final type = event['eventType'] as String;
    final pkg = event['packageName'] as String;
    final ts = DateTime.fromMillisecondsSinceEpoch(event['timestamp'] as int);

    if (type == 'SCREEN_OFF') {
      // Safety close: if PAUSED didn't fire (OEM bug), mark the session end here.
      if (sessionStart != null && sessionLastBackground == null) {
        sessionLastBackground = ts;
      }
      screenOffSinceLastFg = true;
      continue;
    }

    if (type == 'BACKGROUND') {
      lastPausedPkg = pkg;
      if (pkg == packageName && sessionStart != null) {
        sessionLastBackground = ts;
      }
    } else if (type == 'FOREGROUND' && pkg == packageName) {
      // New session when: came from a different app, OR returning after screen-off.
      final isNewSession = lastPausedPkg != packageName || screenOffSinceLastFg;
      screenOffSinceLastFg = false;

      if (isNewSession) {
        // Close the previous session first if one was open.
        if (sessionStart != null && sessionLastBackground != null) {
          final s = sessionStart;
          final bg = sessionLastBackground;
          final ms = bg.difference(s).inMilliseconds;
          if (ms >= 1000) sessions.add(AppSession(start: s, end: bg, duration: ms));
        }
        sessionStart = ts;
        sessionLastBackground = null;
      }
      // else: in-app activity transition — continue current session.
    }
  }

  // Close the final session. If no BACKGROUND was recorded the app is still in foreground.
  if (sessionStart != null) {
    final s = sessionStart;
    final sessionEnd =
        sessionLastBackground ?? (DateTime.now().isBefore(endDate) ? DateTime.now() : endDate);
    final ms = sessionEnd.difference(s).inMilliseconds;
    if (ms >= 1000) sessions.add(AppSession(start: s, end: sessionEnd, duration: ms));
  }

  return sessions;
}


Future<DailyUsageReport> getDailyUsageReport({
  DateTime? startDate,
  DateTime? endDate,
  bool excludeLaunchers = true,
  AppCategory category = AppCategory.all,
  AppSortOrder sortOrder = AppSortOrder.byTime,
}) async {
  final (rangeStart, rangeEnd) = resolveRange(startDate: startDate, endDate: endDate);
  final rangeEndExclusive = rangeEnd.add(const Duration(days: 1));

  final cache = rawCache;
  final dates = daysInRange(rangeStart, rangeEnd);
  final perDayRaw = dates.map((d) => cache?.days[d]?.stats ?? <dynamic>[]).toList();
  final launcherPackages = excludeLaunchers ? (cache?.launcherPackages.toSet() ?? <String>{}) : <String>{};
  final rawEvents = eventsForRange(rangeStart, rangeEndExclusive);

  final categoryMap = buildCategoryMap(perDayRaw);
  final aggregated = buildAggregatedMap(perDayRaw, launcherPackages);

  final windows = filterLauncherWindows(
    buildForegroundWindows(rawEvents, rangeEndExclusive),
    launcherPackages,
  );
  final longestSession = windows.isEmpty
      ? 0
      : windows.map((w) => w.end.difference(w.start).inMilliseconds).reduce(max);
  final windowTime = windows.fold(0, (sum, w) => sum + w.end.difference(w.start).inMilliseconds);

  // Yesterday's total screen time for the % change KPI.
  final yStart = rangeStart.subtract(const Duration(days: 1));
  final yEvents = eventsForRange(yStart, rangeStart);
  final yWindowTime = filterLauncherWindows(
    buildForegroundWindows(yEvents, rangeStart),
    launcherPackages,
  ).fold(0, (sum, w) => sum + w.end.difference(w.start).inMilliseconds);
  final vsYesterdayPct = yWindowTime > 0 ? (windowTime - yWindowTime) / yWindowTime * 100.0 : null;

  // kpi must be built before records so usagePercentage can reference kpi.derivedTimeUsed.
  // timeUsedOverride: event-based total (SCREEN_OFF-aware) replaces the inflated raw sum.
  final kpi = buildDailyKpi(aggregated, longestSession: longestSession, timeUsedOverride: windowTime);

  // Per-app time from event windows — accurate for past days (avoids Android's screen-off inflation).
  // Both actualTimeUsed and usagePercentage now use the same event-based source so they're consistent.
  final windowTimePerPkg = <String, int>{};
  for (final w in windows) {
    final ms = w.end.difference(w.start).inMilliseconds;
    windowTimePerPkg[w.packageName] = (windowTimePerPkg[w.packageName] ?? 0) + ms;
  }

  final iconData = iconMapFromCache(aggregated.keys.toList());

  final unsorted = aggregated.values.map((map) {
    final pkg = map['packageName'] as String;
    final actualTime = windowTimePerPkg[pkg] ?? 0;
    final pct = windowTime > 0 ? actualTime / windowTime * 100.0 : 0.0;
    return AppDailyRecord(
      packageName: pkg,
      appName: map['appName'] as String,
      appIcon: iconData[pkg]?.icon,
      category: categoryMap[pkg] ?? 'Other',
      date: rangeStart,
      actualTimeUsed: actualTime,
      usagePercentage: pct,
      firstUsed: DateTime.fromMillisecondsSinceEpoch(map['firstTimeUsed'] as int),
      lastUsed: DateTime.fromMillisecondsSinceEpoch(map['lastTimeUsed'] as int),
    );
  }).toList()
    ..sort((a, b) => b.actualTimeUsed.compareTo(a.actualTimeUsed));

  final records = await Future.wait(unsorted.map((r) async {
    final rawSessions = await getSessionsForApp(r.packageName, rangeStart, rangeEndExclusive, preloadedEvents: rawEvents);
    final sessionsSum = rawSessions.fold(0, (sum, s) => sum + s.duration);
    final sessions = (sessionsSum > 0 && sessionsSum != r.actualTimeUsed)
        ? rawSessions.map((s) {
            final ratio = r.actualTimeUsed / sessionsSum;
            return AppSession(start: s.start, end: s.end, duration: (s.duration * ratio).round());
          }).where((s) => s.duration >= 1000).toList()
        : rawSessions;
    return AppDailyRecord(
      packageName: r.packageName,
      appName: r.appName,
      appIcon: r.appIcon,
      category: r.category,
      date: r.date,
      actualTimeUsed: r.actualTimeUsed,
      usagePercentage: r.usagePercentage,
      firstUsed: r.firstUsed,
      lastUsed: r.lastUsed,
      sessions: sessions,
    );
  }));

  // Apply category filter and recompute KPI for the filtered subset.
  final List<AppDailyRecord> filteredApps;
  final DailyKpiRecord finalKpi;
  if (category == AppCategory.all) {
    filteredApps = records.toList();
    finalKpi = DailyKpiRecord(
      derivedTimeUsed: kpi.derivedTimeUsed,
      totalSessionCount: records.fold(0, (sum, r) => sum + r.sessions.length),
      firstActivity: kpi.firstActivity,
      lastActivity: kpi.lastActivity,
      totalAppsUsed: kpi.totalAppsUsed,
      longestSession: kpi.longestSession,
      vsYesterdayPct: vsYesterdayPct,
    );
  } else {
    final subset = records.where((a) => a.category == category.label).toList();
    if (subset.isEmpty) {
      filteredApps = [];
      final now = DateTime.now();
      finalKpi = DailyKpiRecord(
        derivedTimeUsed: 0, totalSessionCount: 0,
        firstActivity: now, lastActivity: now,
        totalAppsUsed: 0, longestSession: 0,
        vsYesterdayPct: vsYesterdayPct,
      );
    } else {
      final totalTime = subset.fold(0, (sum, a) => sum + a.actualTimeUsed);
      final longestSess = subset.expand((a) => a.sessions).fold(0, (best, s) => s.duration > best ? s.duration : best);
      finalKpi = DailyKpiRecord(
        derivedTimeUsed: totalTime,
        totalSessionCount: subset.fold(0, (sum, a) => sum + a.sessions.length),
        firstActivity: subset.map((a) => a.firstUsed).reduce((a, b) => a.isBefore(b) ? a : b),
        lastActivity: subset.map((a) => a.lastUsed).reduce((a, b) => a.isAfter(b) ? a : b),
        totalAppsUsed: subset.length,
        longestSession: longestSess,
        vsYesterdayPct: vsYesterdayPct,
      );
      filteredApps = subset.map((a) {
        final pct = totalTime > 0 ? a.actualTimeUsed / totalTime * 100.0 : 0.0;
        return AppDailyRecord(
          packageName: a.packageName, appName: a.appName, appIcon: a.appIcon,
          category: a.category, date: a.date, actualTimeUsed: a.actualTimeUsed,
          usagePercentage: pct,
          firstUsed: a.firstUsed, lastUsed: a.lastUsed, sessions: a.sessions,
        );
      }).toList();
    }
  }

  final sortedApps = filteredApps.toList()
    ..sort((a, b) => sortOrder == AppSortOrder.byTime
        ? b.actualTimeUsed.compareTo(a.actualTimeUsed)
        : b.sessionCount.compareTo(a.sessionCount));

  final report = DailyUsageReport(kpi: finalKpi, apps: sortedApps);

  debugPrint('dailyUsageReport =');
  debugPrint(const JsonEncoder.withIndent('  ').convert(report.toJson()));

  return report;
}


Future<HourlyUsageReport> getHourlyUsageReport({
  DateTime? startDate,
  DateTime? endDate,
  bool excludeLaunchers = true,
}) async {
  final (rangeStart, rangeEnd) = resolveRange(startDate: startDate, endDate: endDate);
  final rangeEndExclusive = rangeEnd.add(const Duration(days: 1));

  final cache = rawCache;
  final dates = daysInRange(rangeStart, rangeEnd);
  final perDayRaw = dates.map((d) => cache?.days[d]?.stats ?? <dynamic>[]).toList();
  final launcherPackages = excludeLaunchers ? (cache?.launcherPackages.toSet() ?? <String>{}) : <String>{};
  final rawEvents = eventsForRange(rangeStart, rangeEndExclusive);

  final aggregated = buildAggregatedMap(perDayRaw, launcherPackages);

  final windows = filterLauncherWindows(
    buildForegroundWindows(rawEvents, rangeEndExclusive),
    launcherPackages,
  );
  final longestSession = windows.isEmpty
      ? 0
      : windows.map((w) => w.end.difference(w.start).inMilliseconds).reduce(max);
  final windowTime = windows.fold(0, (sum, w) => sum + w.end.difference(w.start).inMilliseconds);
  final kpi = buildDailyKpi(aggregated, longestSession: longestSession, timeUsedOverride: windowTime, totalSessionCount: windows.length);

  final hours = <HourKpiRecord>[];
  for (var h = rangeStart; h.isBefore(rangeEndExclusive); h = h.add(const Duration(hours: 1))) {
    final slotStart = h;
    final slotEnd = h.add(const Duration(hours: 1));

    int totalMs = 0;
    int sessionCount = 0;
    DateTime? firstActivity;
    DateTime? lastActivity;

    for (final w in windows) {
      final overlap = overlapMs(w.start, w.end, slotStart, slotEnd);
      if (overlap <= 0) continue;

      totalMs += overlap;

      if (!w.start.isBefore(slotStart) && w.start.isBefore(slotEnd)) {
        sessionCount++;
        if (firstActivity == null || w.start.isBefore(firstActivity)) firstActivity = w.start;
      }

      final effectiveEnd = w.end.isBefore(slotEnd) ? w.end : slotEnd;
      if (lastActivity == null || effectiveEnd.isAfter(lastActivity)) lastActivity = effectiveEnd;
    }

    if (totalMs > 0) {
      hours.add(HourKpiRecord(
        hourStart: slotStart,
        hourEnd: slotEnd,
        derivedTimeUsed: totalMs,
        totalSessionCount: sessionCount,
        firstActivity: firstActivity,
        lastActivity: lastActivity,
      ));
    }
  }

  final peakHour = hours.isEmpty
      ? null
      : hours.reduce((a, b) => a.derivedTimeUsed >= b.derivedTimeUsed ? a : b);

  final report = HourlyUsageReport(kpi: kpi, peakHour: peakHour, hours: hours);

  debugPrint('hourlyUsageReport =');
  debugPrint(const JsonEncoder.withIndent('  ').convert(report.toJson()));

  return report;
}


Future<WeeklyUsageReport> getWeeklyUsageReport({
  DateTime? startDate,
  DateTime? endDate,
  bool excludeLaunchers = true,
}) async {
  final (rangeStart, rangeEnd) = resolveRange(startDate: startDate, endDate: endDate);
  final dates = daysInRange(rangeStart, rangeEnd);
  final rangeEndExclusive = rangeEnd.add(const Duration(days: 1));

  final cache = rawCache;
  final perDayRaw = dates.map((d) => cache?.days[d]?.stats ?? <dynamic>[]).toList();
  final launcherPackages = excludeLaunchers ? (cache?.launcherPackages.toSet() ?? <String>{}) : <String>{};
  final rawEvents = eventsForRange(rangeStart, rangeEndExclusive);

  // Build event windows once for the full range, then intersect per day.
  // This is the same SCREEN_OFF-aware approach used by hourly/timeline — it
  // prevents phantom foreground time that Android accumulates on MIUI when
  // ACTIVITY_PAUSED fires late or not at all after the screen turns off.
  final allWindows = filterLauncherWindows(
    buildForegroundWindows(rawEvents, rangeEndExclusive),
    launcherPackages,
  );

  final dayRecords = <WeeklyDayRecord>[];
  for (var i = 0; i < dates.length; i++) {
    final dayStart = dates[i];
    final dayEnd = dayStart.add(const Duration(days: 1));

    // Event-based screen-on time for this day (capped at SCREEN_OFF).
    final derivedTimeUsed = allWindows.fold<int>(0, (sum, w) => sum + overlapMs(w.start, w.end, dayStart, dayEnd));
    // Session count: windows that started on this day — same event-window source as time.
    final daySessions = allWindows.where((w) => !w.start.isBefore(dayStart) && w.start.isBefore(dayEnd)).length;

    // Use aggregated stats for first+last used / app count only.
    final aggregated = buildAggregatedMap([perDayRaw[i]], launcherPackages);
    if (aggregated.isEmpty && derivedTimeUsed == 0) {
      dayRecords.add(WeeklyDayRecord(
        date: dayStart,
        actualTimeUsed: 0,
        sessionCount: 0,
        firstUsed: null,
        lastUsed: null,
        totalAppsUsed: 0,
      ));
    } else {
      final kpi = buildDailyKpi(aggregated);
      dayRecords.add(WeeklyDayRecord(
        date: dayStart,
        actualTimeUsed: derivedTimeUsed,
        sessionCount: daySessions,
        firstUsed: aggregated.isEmpty ? null : kpi.firstActivity,
        lastUsed: aggregated.isEmpty ? null : kpi.lastActivity,
        totalAppsUsed: kpi.totalAppsUsed,
      ));
    }
  }

  final derivedTimeUsed = dayRecords.fold(0, (sum, d) => sum + d.actualTimeUsed);
  final activeDays = dayRecords.where((d) => d.actualTimeUsed > 0).length;
  final averageDailyTime = dates.isEmpty ? 0 : derivedTimeUsed ~/ dates.length;
  final peak = dayRecords.reduce((a, b) => a.actualTimeUsed >= b.actualTimeUsed ? a : b);
  final totalSessionCount = dayRecords.fold(0, (sum, d) => sum + d.sessionCount);

  final report = WeeklyUsageReport(
    derivedTimeUsed: derivedTimeUsed,
    averageDailyTime: averageDailyTime,
    peakDailyTime: peak.actualTimeUsed,
    peakDay: peak.date,
    activeDays: activeDays,
    totalSessionCount: totalSessionCount,
    days: dayRecords,
  );

  debugPrint('weeklyUsageReport =');
  debugPrint(const JsonEncoder.withIndent('  ').convert(report.toJson()));

  return report;
}


Future<DayTimeline> getDayTimeline({
  DateTime? startDate,
  DateTime? endDate,
  bool excludeLaunchers = true,
}) async {
  final (rangeStart, rangeEnd) = resolveRange(startDate: startDate, endDate: endDate);
  final rangeEndExclusive = rangeEnd.add(const Duration(days: 1));

  final cache = rawCache;
  final launcherPackages = excludeLaunchers ? (cache?.launcherPackages.toSet() ?? <String>{}) : <String>{};
  final rawEvents = eventsForRange(rangeStart, rangeEndExclusive);

  final windows = filterLauncherWindows(
    buildForegroundWindows(rawEvents, rangeEndExclusive),
    launcherPackages,
  )..sort((a, b) => a.start.compareTo(b.start));

  final packageNames = windows.map((w) => w.packageName).toSet().toList();
  final iconData = iconMapFromCache(packageNames);

  final entries = windows.map((w) {
    final data = iconData[w.packageName];
    return TimelineEntry(
      packageName: w.packageName,
      appName: data?.appName ?? w.packageName,
      appIcon: data?.icon,
      start: w.start,
      end: w.end,
      duration: w.end.difference(w.start).inMilliseconds,
    );
  }).toList();

  final derivedTimeUsed = entries.fold(0, (sum, e) => sum + e.duration);

  final timeline = DayTimeline(
    date: rangeStart,
    derivedTimeUsed: derivedTimeUsed,
    entries: entries,
  );

  debugPrint('dayTimeline =');
  debugPrint(const JsonEncoder.withIndent('  ').convert(timeline.toJson()));

  return timeline;
}

