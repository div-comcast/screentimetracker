import 'package:flutter/material.dart';
import '../../../backend/domains/usage/reports.dart';
import '../../../backend/domains/usage/schema.dart';
import '../../theme/app_theme.dart';

class KpiCard extends StatefulWidget {
  final DateTime start;
  final DateTime end;

  const KpiCard({super.key, required this.start, required this.end});

  @override
  State<KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<KpiCard> {
  late Future<DailyUsageReport> _future;

  @override
  void initState() {
    super.initState();
    _future = getDailyUsageReport(startDate: widget.start, endDate: widget.end);
  }

  @override
  void didUpdateWidget(KpiCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.start != widget.start || oldWidget.end != widget.end) {
      setState(() {
        _future = getDailyUsageReport(startDate: widget.start, endDate: widget.end);
      });
    }
  }

  int get _days => widget.end.difference(widget.start).inDays + 1;

  String get _periodLabel {
    if (_days == 1) {
      final today = DateTime.now();
      final isToday = widget.start.year == today.year &&
          widget.start.month == today.month &&
          widget.start.day == today.day;
      return isToday ? 'Total today' : 'Total on ${_shortDate(widget.start)}';
    }
    if (_days == 7) return 'Total this week';
    if (_days == 14) return 'Total last 14 days';
    return 'Total for $_days days';
  }

  static String _shortDate(DateTime d) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${m[d.month - 1]} ${d.day}';
  }

  static String _formatTime(int ms) {
    final totalMins = ms ~/ 60000;
    final h = totalMins ~/ 60;
    final m = totalMins % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  String _subtitleText(DailyKpiRecord kpi) {
    final avgMs = _days > 0 ? kpi.derivedTimeUsed ~/ _days : 0;
    final avgStr = 'avg ${_formatTime(avgMs)} / day';

    final vsYest = kpi.vsYesterdayPct;
    if (vsYest != null) {
      final word = vsYest < 0 ? 'less' : 'more';
      final ref = _days == 1 ? 'yesterday' : 'prev. day';
      return '$word than $ref · $avgStr';
    }
    return avgStr;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A6CF7), Color(0xFF2A3DC7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: FutureBuilder<DailyUsageReport>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoading();
            }
            if (!snapshot.hasData || snapshot.hasError) {
              return _buildEmpty();
            }
            return _buildContent(snapshot.data!.kpi);
          },
        ),
      ),
    );
  }

  Widget _buildContent(DailyKpiRecord kpi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: period label + % badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _periodLabel,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (kpi.vsYesterdayPct != null)
              _PctBadge(pct: kpi.vsYesterdayPct!),
          ],
        ),
        const SizedBox(height: 6),
        // Big time
        Text(
          _formatTime(kpi.derivedTimeUsed),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.bold,
            letterSpacing: -1.5,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        // Subtitle
        Text(
          _subtitleText(kpi),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _Shimmer(width: 110, height: 14),
            _Shimmer(width: 60, height: 26),
          ],
        ),
        const SizedBox(height: 10),
        _Shimmer(width: 160, height: 42),
        const SizedBox(height: 10),
        _Shimmer(width: 220, height: 13),
      ],
    );
  }

  Widget _buildEmpty() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _periodLabel,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 6),
        const Text(
          '0m',
          style: TextStyle(
            color: Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.bold,
            letterSpacing: -1.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'No data for this period',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}

// ── % Badge ──────────────────────────────────────────────────────────────────

class _PctBadge extends StatelessWidget {
  final double pct;
  const _PctBadge({required this.pct});

  @override
  Widget build(BuildContext context) {
    final isDown = pct < 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDown ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 3),
          Text(
            '${pct.abs().toStringAsFixed(1)}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shimmer placeholder ───────────────────────────────────────────────────────

class _Shimmer extends StatelessWidget {
  final double width;
  final double height;
  const _Shimmer({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
