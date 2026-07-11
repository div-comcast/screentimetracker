import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/filter_bar.dart';
import '../widgets/kpi_card.dart';
import '../widgets/section_header.dart';
import '../widgets/app_usage_tile.dart';

/// Daily dashboard: filters + KPI summary + donut-style share + top apps.
class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  String _category = 'All';
  bool _sortByTime = true;
  String _dateLabel = 'Today · Jul 11';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    var apps = MockData.apps
        .where((a) => _category == 'All' || a.category == _category)
        .toList();
    apps.sort((a, b) => _sortByTime
        ? b.minutes.compareTo(a.minutes)
        : b.sessions.compareTo(a.sessions));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        FilterBar(
          selectedCategory: _category,
          onCategorySelected: (c) => setState(() => _category = c),
          dateLabel: _dateLabel,
          onPickDate: _pickDate,
          sortByTime: _sortByTime,
          onSortChanged: (v) => setState(() => _sortByTime = v),
        ),
        const SizedBox(height: 20),
        _ScreenTimeHero(),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Daily KPI summary', icon: Icons.insights_rounded),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: [
            KpiCard(
              icon: Icons.touch_app_rounded,
              label: 'Total sessions',
              value: '${MockData.totalSessions}',
              accent: scheme.primary,
            ),
            const KpiCard(
              icon: Icons.apps_rounded,
              label: 'Apps used',
              value: '${MockData.appsUsed}',
              accent: Color(0xFF8B5CF6),
            ),
            const KpiCard(
              icon: Icons.timer_rounded,
              label: 'Longest session',
              value: '52m',
              accent: Color(0xFFF59E0B),
            ),
            const KpiCard(
              icon: Icons.trending_down_rounded,
              label: 'vs Yesterday',
              value: '8.3%',
              sub: 'Less than yesterday',
              accent: Color(0xFF10B981),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _MiniInfoCard(
                icon: Icons.wb_sunny_rounded,
                label: 'First activity',
                value: MockData.firstActivity,
                color: const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniInfoCard(
                icon: Icons.nightlight_round,
                label: 'Last activity',
                value: MockData.lastActivity,
                color: const Color(0xFF6366F1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SectionHeader(
          title: 'Top apps',
          action: 'See all',
          onAction: () {},
          icon: Icons.leaderboard_rounded,
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Column(
              children: [
                for (var i = 0; i < apps.length; i++) ...[
                  AppUsageTile(app: apps[i]),
                  if (i != apps.length - 1) const Divider(height: 1),
                ],
                if (apps.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No apps in "$_category"',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2027),
    );
    if (range != null) {
      setState(() {
        _dateLabel =
            '${range.start.month}/${range.start.day} – ${range.end.month}/${range.end.day}';
      });
    }
  }
}

/// The big screen-time hero card with a circular gauge.
class _ScreenTimeHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary,
              scheme.primary.withValues(alpha: 0.75),
            ],
          ),
        ),
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            SizedBox(
              width: 96,
              height: 96,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: CircularProgressIndicator(
                      value: 0.68,
                      strokeWidth: 9,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      valueColor:
                          const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('68%',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800)),
                      Text('of goal',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 22),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total screen time',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    formatMinutes(MockData.totalScreenMinutes),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.trending_down_rounded,
                            color: Colors.white, size: 15),
                        SizedBox(width: 4),
                        Text('8.3% vs yesterday',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _MiniInfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w800)),
                Text(label,
                    style: TextStyle(
                        fontSize: 11.5,
                        color: scheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
