import 'dart:math';
import 'package:flutter/material.dart';
import '../../backend/bridge/cache_data.dart';
import '../../backend/domains/usage/reports.dart';
import '../../backend/domains/usage/schema.dart';
import 'calendar.dart';

// ─── Main widget ───────────────────────────────────────────────────────────────

class ScreenTimeCard extends StatefulWidget {
  final void Function(DailyUsageReport report)? onReportLoaded;

  const ScreenTimeCard({super.key, this.onReportLoaded});

  @override
  State<ScreenTimeCard> createState() => _ScreenTimeCardState();
}

class _ScreenTimeCardState extends State<ScreenTimeCard> {
  DateTime _start = DateTime.now();
  DateTime? _end;

  bool _loading = false;
  bool _noData = false;

  DailyUsageReport? _daily;
  HourlyUsageReport? _hourly;
  WeeklyUsageReport? _weekly;

  @override
  void initState() {
    super.initState();
    _load(_start, null);
  }

  bool get _isMultiDay => _end != null && !_sameDay(_start, _end!);

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ── Data loading ───────────────────────────────────────────────────────────

  Future<void> _load(DateTime start, DateTime? end) async {
    setState(() {
      _loading = true;
      _noData = false;
    });
    try {
      await fetchRawCache(startDate: start, endDate: end ?? start);

      final daily = await getDailyUsageReport(
        startDate: start,
        endDate: end,
      );

      if (end == null || _sameDay(start, end)) {
        // Single day → hourly report for the chart
        final hourly = await getHourlyUsageReport(
          startDate: start,
          endDate: end,
        );
        if (mounted) {
          setState(() {
            _daily = daily;
            _hourly = hourly;
            _weekly = null;
            _loading = false;
          });
          widget.onReportLoaded?.call(daily);
        }
      } else {
        // Date range → weekly report for the chart
        final weekly = await getWeeklyUsageReport(
          startDate: start,
          endDate: end,
        );
        if (mounted) {
          setState(() {
            _daily = daily;
            _weekly = weekly;
            _hourly = null;
            _loading = false;
          });
          widget.onReportLoaded?.call(daily);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _noData = true;
          _loading = false;
        });
      }
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Format milliseconds as "h:mm" or "0:mm"
  String _hhmm(int ms) {
    final totalMin = ms ~/ 60000;
    final h = totalMin ~/ 60;
    final m = totalMin % 60;
    return h > 0 ? '$h:${m.toString().padLeft(2, '0')}' : '0:${m.toString().padLeft(2, '0')}';
  }

  String get _periodLabel {
    if (!_isMultiDay && _sameDay(_start, DateTime.now())) return 'Today';
    if (_isMultiDay && _end != null) {
      return '${_end!.difference(_start).inDays + 1} days';
    }
    const wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const mo = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${wd[_start.weekday - 1]}, ${mo[_start.month - 1]} ${_start.day}';
  }

  int get _lastHourMs {
    final h = _hourly;
    if (h == null) return 0;
    final now = DateTime.now();
    try {
      return h.hours.firstWhere((r) => r.hourStart.hour == now.hour).derivedTimeUsed;
    } catch (_) {
      return 0;
    }
  }

  List<double> get _chartValues {
    if (_hourly != null) {
      final vals = List<double>.filled(24, 0.0);
      for (final h in _hourly!.hours) {
        vals[h.hourStart.hour] = h.derivedTimeUsed.toDouble();
      }
      return vals;
    }
    if (_weekly != null) {
      return _weekly!.days.map((d) => d.actualTimeUsed.toDouble()).toList();
    }
    return List<double>.filled(24, 0.0);
  }

  List<String> get _xLabels {
    if (_isMultiDay && _weekly != null) {
      const wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return _weekly!.days.map((d) => wd[d.date.weekday - 1]).toList();
    }
    return const ['AM', '10 AM', '12 PM', '2 PM', '4 PM', '6 PM', '8 PM'];
  }

  // ── Calendar callbacks ─────────────────────────────────────────────────────

  void _onDateSelected(DateTime date) {
    setState(() {
      _start = date;
      _end = null;
    });
    _load(date, null);
  }

  void _onRangeSelected(DateTime start, DateTime end) {
    setState(() {
      _start = start;
      _end = end;
    });
    _load(start, end);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final totalMs = _daily?.kpi.derivedTimeUsed ?? 0;
    final pickups = _daily?.kpi.totalSessionCount ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: title + calendar picker ─────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SCREEN TIME',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              CalendarWidget(
                key: ValueKey('$_start|$_end'),
                initialDate: _start,
                initialEndDate: _end,
                onDateSelected: _onDateSelected,
                onRangeSelected: _onRangeSelected,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Content ──────────────────────────────────────────────────────
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(
                  color: Color(0xFFE87070),
                  strokeWidth: 2,
                ),
              ),
            )
          else ...[
            // KPI row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Total time (big)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hhmm(totalMs),
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _periodLabel,
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(width: 22),

                // Last hour (single-day only)
                if (!_isMultiDay) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _hhmm(_lastHourMs),
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        'Last hour',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                ],

                // Phone pickups
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$pickups',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      'Phone pickups',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Chart
            SizedBox(
              height: 100,
              child: _UsageLineChart(
                values: _chartValues,
                xLabels: _xLabels,
                isHourly: !_isMultiDay,
                currentHour: DateTime.now().hour,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Line chart ────────────────────────────────────────────────────────────────

class _UsageLineChart extends StatelessWidget {
  final List<double> values;
  final List<String> xLabels;
  final bool isHourly;
  final int currentHour;

  const _UsageLineChart({
    required this.values,
    required this.xLabels,
    required this.isHourly,
    required this.currentHour,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _ChartPainter(
        values: values,
        xLabels: xLabels,
        isHourly: isHourly,
        currentHour: currentHour,
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> xLabels;
  final bool isHourly;
  final int currentHour;

  static const _labelH = 18.0;
  static const _lineColor = Color(0xFF5BAD6F);
  static const _dotColor = Color(0xFF3A9954);

  const _ChartPainter({
    required this.values,
    required this.xLabels,
    required this.isHourly,
    required this.currentHour,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final chartH = size.height - _labelH;
    final n = values.length;
    final maxVal = values.reduce(max);

    // ── Points ──────────────────────────────────────────────────────────────
    final pts = List<Offset>.generate(n, (i) {
      final x = n == 1 ? size.width / 2 : i / (n - 1) * size.width;
      final y = maxVal <= 0
          ? chartH
          : chartH - (values[i] / maxVal) * (chartH - 8);
      return Offset(x, y);
    });

    // ── Filled area ──────────────────────────────────────────────────────────
    final fillPath = _buildCurvePath(pts, chartH: chartH, closed: true);
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _lineColor.withValues(alpha: 0.28),
            _lineColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, chartH)),
    );

    // ── Line ─────────────────────────────────────────────────────────────────
    canvas.drawPath(
      _buildCurvePath(pts, chartH: chartH, closed: false),
      Paint()
        ..color = _lineColor
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // ── Current-hour marker (hourly view only) ───────────────────────────────
    if (isHourly && currentHour < pts.length) {
      final p = pts[currentHour];

      // Dashed vertical line
      final dashPaint = Paint()
        ..color = Colors.grey.withValues(alpha: 0.35)
        ..strokeWidth = 1;
      double dy = 0;
      while (dy < chartH) {
        canvas.drawLine(
          Offset(p.dx, dy),
          Offset(p.dx, (dy + 4).clamp(0.0, chartH)),
          dashPaint,
        );
        dy += 7;
      }

      // White ring + filled dot
      canvas.drawCircle(p, 5, Paint()..color = _dotColor);
      canvas.drawCircle(
        p,
        5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // ── X-axis labels ────────────────────────────────────────────────────────
    if (isHourly) {
      const labelHours = [0, 10, 12, 14, 16, 18, 20];
      for (int i = 0; i < labelHours.length && i < xLabels.length; i++) {
        final h = labelHours[i];
        if (h >= n) continue;
        _drawLabel(
          canvas,
          xLabels[i],
          n == 1 ? size.width / 2 : h / (n - 1) * size.width,
          chartH + 3,
          size.width,
        );
      }
    } else {
      for (int i = 0; i < xLabels.length; i++) {
        final x = xLabels.length == 1
            ? size.width / 2
            : i / (xLabels.length - 1) * size.width;
        _drawLabel(canvas, xLabels[i], x, chartH + 3, size.width);
      }
    }
  }

  Path _buildCurvePath(
    List<Offset> pts, {
    required double chartH,
    required bool closed,
  }) {
    final path = Path();
    if (pts.isEmpty) return path;

    if (closed) {
      path.moveTo(pts.first.dx, chartH);
      path.lineTo(pts.first.dx, pts.first.dy);
    } else {
      path.moveTo(pts.first.dx, pts.first.dy);
    }

    for (int i = 0; i < pts.length - 1; i++) {
      final p0 = pts[i];
      final p1 = pts[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    if (closed) {
      path.lineTo(pts.last.dx, chartH);
      path.close();
    }
    return path;
  }

  void _drawLabel(
      Canvas canvas, String text, double x, double y, double maxW) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xFFAAAAAA),
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
        canvas, Offset((x - tp.width / 2).clamp(0.0, maxW - tp.width), y));
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.values != values || old.currentHour != currentHour;
}
