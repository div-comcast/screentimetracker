import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/section_header.dart';
import '../widgets/app_usage_tile.dart';

/// Limits & alerts: overall daily limit, per-app limits and alert toggles.
class LimitsTab extends StatefulWidget {
  const LimitsTab({super.key});

  @override
  State<LimitsTab> createState() => _LimitsTabState();
}

class _LimitsTabState extends State<LimitsTab> {
  double _dailyLimit = 300; // minutes
  bool _bedtimeEnabled = true;
  bool _focusEnabled = false;

  // Local copy so toggles/edits are interactive in the skeleton.
  late List<MockApp> _apps = List.of(MockData.apps);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final used = MockData.totalScreenMinutes;
    final progress = (used / _dailyLimit).clamp(0.0, 1.0);
    final limited = _apps.where((a) => a.dailyLimitMinutes != null).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        // ── Overall daily limit ──────────────────────────────────────
        const SectionHeader(
            title: 'Daily limit', icon: Icons.hourglass_bottom_rounded),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      formatMinutes(used),
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: progress >= 1
                              ? scheme.error
                              : scheme.onSurface),
                    ),
                    Text('  / ${formatMinutes(_dailyLimit.round())}',
                        style: TextStyle(
                            fontSize: 15,
                            color: scheme.onSurfaceVariant)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (progress >= 1
                                ? scheme.error
                                : scheme.primary)
                            .withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${(progress * 100).round()}%',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: progress >= 1
                                ? scheme.error
                                : scheme.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: scheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(
                        progress >= 1 ? scheme.error : scheme.primary),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Set daily limit: ${formatMinutes(_dailyLimit.round())}',
                    style: TextStyle(
                        fontSize: 12.5, color: scheme.onSurfaceVariant)),
                Slider(
                  value: _dailyLimit,
                  min: 60,
                  max: 600,
                  divisions: 18,
                  label: formatMinutes(_dailyLimit.round()),
                  onChanged: (v) => setState(() => _dailyLimit = v),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // ── Schedules / alerts ───────────────────────────────────────
        const SectionHeader(
            title: 'Schedules & alerts', icon: Icons.notifications_active_rounded),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.bedtime_rounded),
                title: const Text('Bedtime mode'),
                subtitle: const Text('Mute apps 23:00 – 07:00'),
                value: _bedtimeEnabled,
                onChanged: (v) => setState(() => _bedtimeEnabled = v),
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.center_focus_strong_rounded),
                title: const Text('Focus mode'),
                subtitle: const Text('Block distracting apps while working'),
                value: _focusEnabled,
                onChanged: (v) => setState(() => _focusEnabled = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // ── Per-app limits ───────────────────────────────────────────
        SectionHeader(
          title: 'App limits',
          icon: Icons.app_blocking_rounded,
          action: 'Add',
          onAction: () {},
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Column(
              children: [
                for (var i = 0; i < limited.length; i++) ...[
                  AppUsageTile(
                    app: limited[i],
                    showLimit: true,
                    onTap: () => _editLimit(limited[i]),
                  ),
                  if (i != limited.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // ── Per-app alerts ───────────────────────────────────────────
        const SectionHeader(
            title: 'App alerts', icon: Icons.campaign_rounded),
        Card(
          child: Column(
            children: [
              for (var i = 0; i < _apps.length; i++) ...[
                SwitchListTile(
                  secondary: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _apps[i].color.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(_apps[i].icon,
                        color: _apps[i].color, size: 20),
                  ),
                  title: Text(_apps[i].appName,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(_apps[i].dailyLimitMinutes != null
                      ? 'Alert at ${formatMinutes(_apps[i].dailyLimitMinutes!)}'
                      : 'No limit set'),
                  value: _apps[i].alertEnabled,
                  onChanged: (v) => setState(() {
                    final a = _apps[i];
                    _apps[i] = MockApp(
                      appName: a.appName,
                      packageName: a.packageName,
                      category: a.category,
                      icon: a.icon,
                      color: a.color,
                      minutes: a.minutes,
                      sessions: a.sessions,
                      percentage: a.percentage,
                      firstUsed: a.firstUsed,
                      lastUsed: a.lastUsed,
                      dailyLimitMinutes: a.dailyLimitMinutes,
                      alertEnabled: v,
                    );
                  }),
                ),
                if (i != _apps.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _editLimit(MockApp app) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit limit · ${app.appName}',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Current limit: ${app.dailyLimitMinutes != null ? formatMinutes(app.dailyLimitMinutes!) : "none"}',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
