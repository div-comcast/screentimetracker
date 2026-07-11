import 'package:flutter/material.dart';
import 'dashboard_tab.dart';
import 'hourly_tab.dart';
import 'weekly_tab.dart';
import 'timeline_tab.dart';
import 'limits_tab.dart';
import 'settings_tab.dart';

/// Main navigation shell holding all tabs behind a Material 3 NavigationBar.
class HomeShell extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const HomeShell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  bool _showSettings = false;

  static const _titles = [
    'Dashboard',
    'Hourly',
    'Weekly',
    'Timeline',
    'Limits',
  ];

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      const DashboardTab(),
      const HourlyTab(),
      const WeeklyTab(),
      const TimelineTab(),
      const LimitsTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_showSettings ? 'Settings' : _titles[_index]),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            icon: Icon(_isDark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded),
            onPressed: () => widget.onThemeModeChanged(
              _isDark ? ThemeMode.light : ThemeMode.dark,
            ),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: Icon(_showSettings
                ? Icons.close_rounded
                : Icons.settings_rounded),
            onPressed: () => setState(() => _showSettings = !_showSettings),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _showSettings
            ? SettingsTab(
                key: const ValueKey('settings'),
                themeMode: widget.themeMode,
                onThemeModeChanged: widget.onThemeModeChanged,
              )
            : KeyedSubtree(
                key: ValueKey(_index),
                child: tabs[_index],
              ),
      ),
      bottomNavigationBar: _showSettings
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: 'Daily',
                ),
                NavigationDestination(
                  icon: Icon(Icons.schedule_outlined),
                  selectedIcon: Icon(Icons.schedule_rounded),
                  label: 'Hourly',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_view_week_outlined),
                  selectedIcon: Icon(Icons.calendar_view_week_rounded),
                  label: 'Weekly',
                ),
                NavigationDestination(
                  icon: Icon(Icons.timeline_outlined),
                  selectedIcon: Icon(Icons.timeline_rounded),
                  label: 'Timeline',
                ),
                NavigationDestination(
                  icon: Icon(Icons.hourglass_empty_rounded),
                  selectedIcon: Icon(Icons.hourglass_bottom_rounded),
                  label: 'Limits',
                ),
              ],
            ),
    );
  }

  bool get _isDark {
    if (widget.themeMode == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return widget.themeMode == ThemeMode.dark;
  }
}
