import 'dart:math';
import 'dart:typed_data';
import '../../bridge/cache_data.dart';
import 'schema.dart';

(DateTime, DateTime) resolveRange({DateTime? startDate, DateTime? endDate}) {
  final DateTime s;
  final DateTime e;
  if (startDate == null && endDate == null) {
    s = e = DateTime.now();
  } else if (startDate != null && endDate == null) {
    s = e = startDate;
  } else if (startDate == null) {
    s = e = endDate!;
  } else {
    s = startDate;
    e = endDate!;
  }
  return (DateTime(s.year, s.month, s.day), DateTime(e.year, e.month, e.day));
}

List<DateTime> daysInRange(DateTime rangeStart, DateTime rangeEnd) {
  final dates = <DateTime>[];
  for (var d = rangeStart; !d.isAfter(rangeEnd); d = d.add(const Duration(days: 1))) {
    dates.add(d);
  }
  return dates;
}

int overlapMs(DateTime aStart, DateTime aEnd, DateTime bStart, DateTime bEnd) {
  final overlapStart = aStart.isAfter(bStart) ? aStart : bStart;
  final overlapEnd = aEnd.isBefore(bEnd) ? aEnd : bEnd;
  return overlapEnd.isAfter(overlapStart)
      ? overlapEnd.difference(overlapStart).inMilliseconds
      : 0;
}

List<({String packageName, DateTime start, DateTime end})> buildForegroundWindows(
  List<Map> events,
  DateTime rangeEndExclusive,
) {
  final windows = <({String packageName, DateTime start, DateTime end})>[];
  final openAt = <String, DateTime>{};

  for (final event in events) {
    final type = event['eventType'] as String;
    final pkg = event['packageName'] as String;
    final ts = DateTime.fromMillisecondsSinceEpoch(event['timestamp'] as int);

    if (type == 'FOREGROUND') {
      openAt[pkg] = ts;
    } else if (type == 'BACKGROUND') {
      final fgStart = openAt.remove(pkg);
      if (fgStart != null) windows.add((packageName: pkg, start: fgStart, end: ts));
    } else if (type == 'SCREEN_OFF') {
      for (final entry in openAt.entries) {
        windows.add((packageName: entry.key, start: entry.value, end: ts));
      }
      openAt.clear();
    }
  }

  final fallback = rangeEndExclusive.isBefore(DateTime.now()) ? rangeEndExclusive : DateTime.now();
  for (final entry in openAt.entries) {
    windows.add((packageName: entry.key, start: entry.value, end: fallback));
  }
  return windows;
}

Map<String, Map<String, dynamic>> buildAggregatedMap(
  List<List<dynamic>> perDayRaw,
  Set<String> launcherPackages,
) {
  final aggregated = <String, Map<String, dynamic>>{};
  for (final dayRaw in perDayRaw) {
    for (final r in dayRaw) {
      final map = r as Map;
      final pkg = map['packageName'] as String;
      if (!aggregated.containsKey(pkg)) {
        aggregated[pkg] = {
          'packageName': pkg,
          'appName': map['appName'] as String,
          'totalForegroundTimeMs': map['totalForegroundTimeMs'] as int,
          'firstTimeUsed': map['firstTimeUsed'] as int,
          'lastTimeUsed': map['lastTimeUsed'] as int,
        };
      } else {
        final entry = aggregated[pkg]!;
        entry['totalForegroundTimeMs'] =
            (entry['totalForegroundTimeMs'] as int) + (map['totalForegroundTimeMs'] as int);
        entry['firstTimeUsed'] =
            min(entry['firstTimeUsed'] as int, map['firstTimeUsed'] as int);
        entry['lastTimeUsed'] =
            max(entry['lastTimeUsed'] as int, map['lastTimeUsed'] as int);
      }
    }
  }
  if (launcherPackages.isNotEmpty) {
    aggregated.removeWhere((pkg, _) => launcherPackages.contains(pkg));
  }
  return aggregated;
}

Map<String, ({String appName, Uint8List? icon})> iconMapFromCache(List<String> packageNames) {
  final cache = rawCache;
  if (cache == null || packageNames.isEmpty) return {};
  return {for (final pkg in packageNames) if (cache.icons.containsKey(pkg)) pkg: cache.icons[pkg]!};
}

List<Map> eventsForRange(DateTime start, DateTime endExclusive) {
  final cache = rawCache;
  if (cache == null || cache.days.isEmpty) return [];
  final startMs = start.millisecondsSinceEpoch;
  final endMs   = endExclusive.millisecondsSinceEpoch;
  return cache.days.values.first.events
      .where((e) {
        final ts = (e as Map)['timestamp'] as int;
        return ts >= startMs && ts < endMs;
      })
      .map((e) => e as Map)
      .toList();
}

List<({String packageName, DateTime start, DateTime end})> filterLauncherWindows(
  List<({String packageName, DateTime start, DateTime end})> windows,
  Set<String> launcherPackages,
) {
  if (launcherPackages.isEmpty) return windows;
  return windows.where((w) => !launcherPackages.contains(w.packageName)).toList();
}

DailyKpiRecord buildDailyKpi(
  Map<String, Map<String, dynamic>> aggregated, {
  int longestSession = 0,
  int? timeUsedOverride,
  int totalSessionCount = 0,
}) {
  if (aggregated.isEmpty) {
    final now = DateTime.now();
    return DailyKpiRecord(
      derivedTimeUsed: timeUsedOverride ?? 0,
      totalSessionCount: totalSessionCount,
      firstActivity: now,
      lastActivity: now,
      totalAppsUsed: 0,
      longestSession: longestSession,
    );
  }
  final values = aggregated.values.toList();
  return DailyKpiRecord(
    derivedTimeUsed: timeUsedOverride ??
        values.fold(0, (sum, m) => sum + (m['totalForegroundTimeMs'] as int)),
    totalSessionCount: totalSessionCount,
    firstActivity: DateTime.fromMillisecondsSinceEpoch(
      values.map((m) => m['firstTimeUsed'] as int).reduce(min),
    ),
    lastActivity: DateTime.fromMillisecondsSinceEpoch(
      values.map((m) => m['lastTimeUsed'] as int).reduce(max),
    ),
    totalAppsUsed: aggregated.length,
    longestSession: longestSession,
  );
}
