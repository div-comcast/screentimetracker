import 'package:flutter/material.dart';

/// App settings: theme mode + placeholder toggles for future features.
class SettingsTab extends StatelessWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const SettingsTab({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.palette_rounded),
                title: const Text('Appearance'),
                subtitle: Text(_label(themeMode)),
              ),
              const Divider(height: 1),
              RadioListTile<ThemeMode>(
                value: ThemeMode.system,
                groupValue: themeMode,
                onChanged: (v) => onThemeModeChanged(v!),
                title: const Text('System default'),
                secondary: const Icon(Icons.brightness_auto_rounded),
              ),
              RadioListTile<ThemeMode>(
                value: ThemeMode.light,
                groupValue: themeMode,
                onChanged: (v) => onThemeModeChanged(v!),
                title: const Text('Light'),
                secondary: const Icon(Icons.light_mode_rounded),
              ),
              RadioListTile<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: themeMode,
                onChanged: (v) => onThemeModeChanged(v!),
                title: const Text('Dark'),
                secondary: const Icon(Icons.dark_mode_rounded),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_rounded),
                title: const Text('Usage notifications'),
                subtitle: const Text('Get notified when limits are reached'),
                value: true,
                onChanged: (_) {},
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.weekend_rounded),
                title: const Text('Weekly report'),
                subtitle: const Text('Summary every Sunday evening'),
                value: true,
                onChanged: (_) {},
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.filter_alt_rounded),
                title: const Text('Hide system apps'),
                subtitle: const Text('Exclude launchers & OS services'),
                value: true,
                onChanged: (_) {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.file_download_rounded),
                title: const Text('Export data'),
                subtitle: const Text('Download usage as CSV'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.privacy_tip_rounded),
                title: const Text('Privacy'),
                subtitle: const Text('All data stays on your device'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
              const Divider(height: 1),
              const AboutListTile(
                icon: Icon(Icons.info_rounded),
                applicationName: 'Screen Time Tracker',
                applicationVersion: '0.1.0',
                child: Text('About'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _label(ThemeMode m) => switch (m) {
        ThemeMode.system => 'System default',
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
      };
}
