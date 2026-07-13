import 'dart:math';
import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../theme/app_theme.dart';

/// The large blue/purple summary card at the top of the dashboard.
/// Shows total screen time, donut chart, % change, and KPI stats row.
class UsageSummaryCard extends StatelessWidget {
  final DummyKpi kpi;
  final List<DummyDonutSegment> donutSegments;
  final String date;
  final VoidCallback? onPrevDay;
  final VoidCallback? onNextDay;

  const UsageSummaryCard({
    super.key,
    required this.kpi,
    required this.donutSegments,
    required this.date,
    this.onPrevDay,
    this.onNextDay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.summaryCardBg,
        borderRadius: AppTheme.cardRadius,
      ),
      child: Column(
        children: [
          // ── Total Screen Time + Donut ───────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Screen Time',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(kpi.totalScreenTime, style: AppTheme.headlineLarge),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          kpi.isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                          color: kpi.isUp
                              ? const Color(0xFF69F0AE)
                              : AppTheme.red,
                          size: 20,
                        ),
                        Text(
                          '${kpi.vsYesterdayPct}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: kpi.isUp
                                ? const Color(0xFF69F0AE)
                                : AppTheme.red,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'vs yesterday',
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // ── Donut Chart ────────────────────────────────────
              SizedBox(
                width: 110,
                height: 110,
                child: CustomPaint(
                  painter: _DonutPainter(
                    segments: donutSegments,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${kpi.appsUsed}',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Apps used',
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── KPI Stats Row ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _KpiStat(
                  icon: Icons.access_time,
                  label: 'First Activity',
                  value: kpi.firstActivity,
                ),
                _KpiStat(
                  icon: Icons.access_time,
                  label: 'Last Activity',
                  value: kpi.lastActivity,
                ),
                _KpiStat(
                  icon: Icons.show_chart,
                  label: 'Sessions',
                  value: '${kpi.sessionCount}',
                ),
                _KpiStat(
                  icon: Icons.timelapse,
                  label: 'Longest Session',
                  value: kpi.longestSession,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── KPI stat column ─────────────────────────────────────────────────────

class _KpiStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _KpiStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.white60),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(color: Colors.white54, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ─── Donut chart painter ─────────────────────────────────────────────────

class _DonutPainter extends CustomPainter {
  final List<DummyDonutSegment> segments;

  _DonutPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 10.0;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    double startAngle = -pi / 2; // start from top
    for (final seg in segments) {
      final sweepAngle = 2 * pi * seg.percent;
      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => false;
}
