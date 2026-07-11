import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/section_header.dart';
import '../widgets/simple_bar_chart.dart';
import '../widgets/kpi_card.dart';

/// Weekly usage report: 7-day bar chart + weekly summary KPIs + day list.
class WeeklyTab extends StatelessWidget {
  const WeeklyTab({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final peak = MockData.weeklyPeak;

    final bars = MockData.weekly
        .map((d) => BarData(
              label: d.label,
              value: d.minutes,
              highlight: d.label == peak.label,
            ))
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const SectionHeader(
            title: 'This week', icon: Icons.calendar_view_week_rounded),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
            child: SimpleBarChart(
              bars: bars,
              height: 200,
              color: scheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader(
            title: 'Weekly summary', icon: Icons.summarize_rounded),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: [
            KpiCard(
              icon: Icons.summarize_rounded,
              label: 'Weekly total',
              value: formatMinutes(MockData.weeklyTotal),
              accent: scheme.primary,
            ),
            KpiCard(
              icon: Icons.calculate_rounded,
              label: 'Daily average',
              value: formatMinutes(MockData.weeklyAvg),
              accent: const Color(0xFF8B5CF6),
            ),
            KpiCard(
              icon: Icons.trending_up_rounded,
              label: 'Peak day',
              value: peak.label,
              sub: formatMinutes(peak.minutes),
              accent: const Color(0xFFEF4444),
            ),
            KpiCard(
              icon: Icons.event_available_rounded,
              label: 'Active days',
              value: '${MockData.weeklyActiveDays}/7',
              accent: const Color(0xFF10B981),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const SectionHeader(
            title: 'Day breakdown', icon: Icons.today_rounded),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Column(
              children: [
                for (final d in MockData.weekly)
                  ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: scheme.primary.withValues(alpha: 0.14),
                      child: Text(
                        d.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                    title: Text(
                      formatMinutes(d.minutes),
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text('${d.sessions} sessions · ${d.appsUsed} apps'),
                    trailing: SizedBox(
                      width: 90,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: d.minutes / peak.minutes,
                          minHeight: 8,
                          backgroundColor: scheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(scheme.primary),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
