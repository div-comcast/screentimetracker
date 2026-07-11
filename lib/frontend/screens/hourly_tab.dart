import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/section_header.dart';
import '../widgets/simple_bar_chart.dart';
import '../widgets/kpi_card.dart';

/// Hourly usage report: a 24-hour bar chart + peak-hour highlight.
class HourlyTab extends StatelessWidget {
  const HourlyTab({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final peak = MockData.peakHour;

    final bars = MockData.hourly
        .where((h) => h.hour % 2 == 0) // show even hours to fit width
        .map((h) => BarData(
              label: _hourLabel(h.hour),
              value: h.minutes,
              highlight: h.hour == peak,
            ))
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: KpiCard(
                icon: Icons.schedule_rounded,
                label: 'Peak hour',
                value: '${_hourLabel(peak)}–${_hourLabel(peak + 1)}',
                accent: scheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: KpiCard(
                icon: Icons.local_fire_department_rounded,
                label: 'Peak usage',
                value: '41m',
                accent: Color(0xFFEF4444),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const SectionHeader(
            title: 'Hourly breakdown', icon: Icons.bar_chart_rounded),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
            child: SimpleBarChart(
              bars: bars,
              height: 220,
              color: scheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SectionHeader(
            title: 'Active hours', icon: Icons.access_time_filled_rounded),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Column(
              children: [
                for (final h in MockData.hourly.where((h) => h.minutes > 0)) ...[
                  ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: (h.hour == peak
                              ? scheme.primary
                              : scheme.primary.withValues(alpha: 0.14)),
                      child: Text(
                        '${h.hour}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: h.hour == peak
                              ? scheme.onPrimary
                              : scheme.primary,
                        ),
                      ),
                    ),
                    title: Text(
                      '${_hourLabel(h.hour)} – ${_hourLabel(h.hour + 1)}',
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('${h.sessions} sessions'),
                    trailing: Text(
                      formatMinutes(h.minutes),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _hourLabel(int h) {
    final hour = h % 24;
    if (hour == 0) return '12a';
    if (hour == 12) return '12p';
    return hour < 12 ? '${hour}a' : '${hour - 12}p';
  }
}
