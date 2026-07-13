import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reports screen with Daily (hourly breakdown) and Weekly (daily breakdown) views.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _viewIndex = 0; // 0 = Daily, 1 = Weekly

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildKpiCard(),
              const SizedBox(height: 16),
              _buildPeakCard(),
              const SizedBox(height: 16),
              _buildChartCard(),
              const SizedBox(height: 16),
              _buildActivityRow(),
              const SizedBox(height: 16),
              _buildInsightsCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header with title + Daily/Weekly toggle ─────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Usage Report',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Icon(Icons.ios_share, color: AppTheme.textMuted, size: 22),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: AppTheme.textMuted),
              const SizedBox(width: 6),
              Text(
                _viewIndex == 0 ? '10 July 2026' : '7 – 13 July 2026',
                style: AppTheme.bodyMedium,
              ),
              const Icon(Icons.keyboard_arrow_down, size: 18, color: AppTheme.textSecondary),
            ],
          ),
          const SizedBox(height: 16),
          _buildToggle(),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    final labels = ['Daily', 'Weekly'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final isSelected = i == _viewIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _viewIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── KPI Summary Card (purple) ───────────────────────────────────────

  Widget _buildKpiCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: _viewIndex == 0 ? _dailyKpi() : _weeklyKpi(),
    );
  }

  Widget _dailyKpi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Total time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Time Used', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  const Text('7h 50m', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.trending_up, color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text('vs Yesterday  --', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Right: Sessions, Apps Used, Longest, Avg
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _kpiMiniItem(Icons.sensors, 'Sessions', '502'),
                const SizedBox(height: 10),
                _kpiMiniItem(Icons.apps, 'Apps Used', '33'),
                const SizedBox(height: 10),
                _kpiMiniItem(Icons.access_time, 'Longest Session', '48m 39s'),
                const SizedBox(height: 10),
                _kpiMiniItem(Icons.trending_flat, 'Avg. per Session', '56s'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _weeklyKpi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Time Used', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  const Text('38h 20m', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today, color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text('7 active days', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _kpiMiniItem(Icons.trending_flat, 'Daily Avg', '5h 28m'),
                const SizedBox(height: 10),
                _kpiMiniItem(Icons.trending_up, 'Peak Day', '7h 50m'),
                const SizedBox(height: 10),
                _kpiMiniItem(Icons.sensors, 'Total Sessions', '2,814'),
                const SizedBox(height: 10),
                _kpiMiniItem(Icons.apps, 'Active Days', '7/7'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _kpiMiniItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }

  // ─── Peak Hour / Peak Day Card ───────────────────────────────────────

  Widget _buildPeakCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
      ),
      child: _viewIndex == 0 ? _dailyPeak() : _weeklyPeak(),
    );
  }

  Widget _dailyPeak() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: AppTheme.primary, size: 18),
                  const SizedBox(width: 6),
                  Text('Peak Hour', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('8 PM – 9 PM', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Text('55m 15s', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.primary)),
              Text('Time Used', style: AppTheme.bodySmall),
            ],
          ),
        ),
        Container(width: 1, height: 70, color: AppTheme.textMuted.withValues(alpha: 0.2)),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('73', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                ],
              ),
              Text('Sessions', style: AppTheme.bodySmall),
              const SizedBox(height: 10),
              Text('8:07 PM', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              Text('First Activity', style: AppTheme.bodySmall),
              const SizedBox(height: 6),
              Text('9:00 PM', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              Text('Last Activity', style: AppTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _weeklyPeak() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: AppTheme.primary, size: 18),
                  const SizedBox(width: 6),
                  Text('Peak Day', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Thursday', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Text('7h 50m', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.primary)),
              Text('Time Used', style: AppTheme.bodySmall),
            ],
          ),
        ),
        Container(width: 1, height: 70, color: AppTheme.textMuted.withValues(alpha: 0.2)),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('502', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                ],
              ),
              Text('Sessions', style: AppTheme.bodySmall),
              const SizedBox(height: 10),
              Text('33 apps', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              Text('Apps Used', style: AppTheme.bodySmall),
              const SizedBox(height: 6),
              Text('Jul 10', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              Text('Date', style: AppTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Bar Chart Card ──────────────────────────────────────────────────

  Widget _buildChartCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _viewIndex == 0 ? 'Hourly Usage Overview' : 'Daily Usage Overview',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
              const Spacer(),
              _chartToggle(),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: _viewIndex == 0 ? _hourlyBarChart() : _weeklyBarChart(),
          ),
          const SizedBox(height: 8),
          _chartLabels(),
        ],
      ),
    );
  }

  Widget _chartToggle() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppTheme.scaffoldBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _chartToggleBtn('Time Used', true),
          _chartToggleBtn('Sessions', false),
        ],
      ),
    );
  }

  Widget _chartToggleBtn(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.white : AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _hourlyBarChart() {
    // Dummy hourly data (17 hours: 8 AM to 12 AM)
    final hourlyMinutes = [5, 8, 12, 10, 18, 20, 22, 35, 38, 40, 33, 35, 55, 42, 38, 20, 12];
    final maxVal = hourlyMinutes.reduce(max).toDouble();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: hourlyMinutes.map((m) {
        final ratio = m / maxVal;
        final isPeak = m == 55;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isPeak) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('55m 15s', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 4),
                ],
                Container(
                  height: 140 * ratio,
                  decoration: BoxDecoration(
                    color: isPeak ? AppTheme.primary : AppTheme.primary.withValues(alpha: 0.3 + ratio * 0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _weeklyBarChart() {
    // Dummy weekly data (7 days)
    final dailyHours = [4.2, 5.8, 6.1, 7.83, 5.2, 4.5, 5.0];
    final maxVal = dailyHours.reduce(max);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: dailyHours.asMap().entries.map((entry) {
        final ratio = entry.value / maxVal;
        final isPeak = entry.value == 7.83;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isPeak) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('7h 50m', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 4),
                ],
                Container(
                  height: 130 * ratio,
                  decoration: BoxDecoration(
                    color: isPeak ? AppTheme.primary : AppTheme.primary.withValues(alpha: 0.3 + ratio * 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _chartLabels() {
    final labels = _viewIndex == 0
        ? ['8 AM', '10 AM', '12 PM', '2 PM', '4 PM', '6 PM', '8 PM', '10 PM', '12 AM']
        : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels.map((l) => Text(l, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted))).toList(),
    );
  }

  // ─── Activity summary row ────────────────────────────────────────────

  Widget _buildActivityRow() {
    final items = _viewIndex == 0
        ? [
            _ActivityItem(Icons.wb_sunny_outlined, 'First Activity', '08:09 AM', AppTheme.green),
            _ActivityItem(Icons.nights_stay_outlined, 'Last Activity', '11:47 PM', AppTheme.primary),
            _ActivityItem(Icons.trending_up, 'Most Active', '8 PM – 9 PM', AppTheme.red),
          ]
        : [
            _ActivityItem(Icons.trending_up, 'Most Active', 'Thursday', AppTheme.primary),
            _ActivityItem(Icons.trending_down, 'Least Active', 'Monday', AppTheme.green),
            _ActivityItem(Icons.trending_flat, 'Daily Avg', '5h 28m', AppTheme.red),
          ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: items.map((item) {
          return Expanded(
            child: Column(
              children: [
                Icon(item.icon, size: 22, color: item.color),
                const SizedBox(height: 6),
                Text(item.label, style: AppTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  item.value,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Insights Card ───────────────────────────────────────────────────

  Widget _buildInsightsCard() {
    final insights = _viewIndex == 0
        ? [
            _InsightItem(Icons.access_time, AppTheme.primary, 'You were most active in the evening.'),
            _InsightItem(Icons.visibility, AppTheme.green, 'Peak productivity window around 2 PM – 4 PM.'),
            _InsightItem(Icons.phone_android, AppTheme.primary, 'Consider taking breaks between 8 PM – 10 PM.'),
          ]
        : [
            _InsightItem(Icons.trending_up, AppTheme.primary, 'Thursday was your busiest day this week.'),
            _InsightItem(Icons.trending_down, AppTheme.green, 'Monday had the lowest screen time.'),
            _InsightItem(Icons.calendar_today, AppTheme.primary, 'You averaged 5h 28m per day.'),
          ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 18, color: AppTheme.primary),
              const SizedBox(width: 6),
              const Text('Insights', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: insights.map((insight) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: insight.color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(insight.icon, size: 18, color: insight.color),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        insight.text,
                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, height: 1.3),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  _ActivityItem(this.icon, this.label, this.value, this.color);
}

class _InsightItem {
  final IconData icon;
  final Color color;
  final String text;
  _InsightItem(this.icon, this.color, this.text);
}
