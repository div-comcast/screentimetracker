import 'package:flutter/services.dart';

const _channel = MethodChannel('com.example.screentimetracker/usage');

Future<bool> hasUsagePermission() async {
  return await _channel.invokeMethod('hasUsagePermission');
}

Future<void> requestUsagePermission() async {
  await _channel.invokeMethod('requestUsagePermission');
}

Future<List<dynamic>> getAppUsageForDate(DateTime date) async {
  return await _channel.invokeMethod('getAppUsageForDate', {
    'dateMs': date.millisecondsSinceEpoch,
  });
}

Future<List<dynamic>> getAppIcons(List<String> packageNames) async {
  return await _channel.invokeMethod('getAppIcons', {
    'packageNames': packageNames,
  });
}

Future<List<dynamic>> getUsageEvents(DateTime start, DateTime end) async {
  return await _channel.invokeMethod('getUsageEvents', {
    'startMs': start.millisecondsSinceEpoch,
    'endMs': end.millisecondsSinceEpoch,
  });
}

/// Returns package names of all apps registered as home-screen launchers on this device.
/// Uses the OS home-intent query — works across all OEMs (Samsung, Xiaomi, POCO, etc.).
Future<List<String>> getLauncherPackages() async {
  final raw = await _channel.invokeMethod<List>('getLauncherPackages');
  return raw?.cast<String>() ?? [];
}
