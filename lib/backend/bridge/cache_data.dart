import 'dart:typed_data';
import 'receive_data.dart';

class RawDayData {
  final List<dynamic> stats;
  final List<dynamic> events;

  const RawDayData({required this.stats, required this.events});
}

class RawCache {
  final Map<DateTime, RawDayData> days;
  final List<String> launcherPackages;
  final Map<String, ({String appName, Uint8List? icon})> icons;

  const RawCache({
    required this.days,
    required this.launcherPackages,
    required this.icons,
  });
}

RawCache? _cache;

RawCache? get rawCache => _cache;

Future<RawCache> fetchRawCache({
  required DateTime startDate,
  required DateTime endDate,
}) async {
  final start = DateTime(startDate.year, startDate.month, startDate.day);
  final end   = DateTime(endDate.year,   endDate.month,   endDate.day);

  // Fetch per-day stats and full-range events in parallel.
  final dayCount = end.difference(start).inDays + 1;
  final dates = List.generate(dayCount, (i) => start.add(Duration(days: i)));

  final perDayStatsFuture = Future.wait(dates.map((d) => getAppUsageForDate(d)));
  final eventsFuture      = getUsageEvents(start, end.add(const Duration(days: 1)));
  final launchersFuture   = getLauncherPackages();

  final perDayStats = await perDayStatsFuture;
  final events      = await eventsFuture;
  final launchers   = await launchersFuture;

  // Collect unique packages across all days for a single icon fetch.
  final packages = <String>{};
  for (final day in perDayStats) {
    for (final r in day) {
      final pkg = (r as Map)['packageName'] as String?;
      if (pkg != null) packages.add(pkg);
    }
  }

  final rawIcons = await getAppIcons(packages.toList());
  final iconMap = <String, ({String appName, Uint8List? icon})>{};
  for (final r in rawIcons) {
    final map = r as Map;
    final pkg = map['packageName'] as String;
    iconMap[pkg] = (
      appName: map['appName'] as String,
      icon: map['iconBytes'] != null
          ? Uint8List.fromList((map['iconBytes'] as List).cast<int>())
          : null,
    );
  }

  final dayMap = <DateTime, RawDayData>{};
  for (var i = 0; i < dates.length; i++) {
    dayMap[dates[i]] = RawDayData(stats: perDayStats[i], events: events);
  }

  _cache = RawCache(days: dayMap, launcherPackages: launchers, icons: iconMap);
  return _cache!;
}
