import 'dart:math';
import 'package:flutter/material.dart';
import '../../../backend/domains/usage/reports.dart';
import '../../theme/app_theme.dart';

// ─── Internal data model ──────────────────────────────────────────────────────

class _ChartPoint {
  final String label; // empty = no x-axis label at this position
  final int ms;
  const _ChartPoint(this.label, this.ms);
}

// ─── Public widget ────────────────────────────────────────────────────────────

class ChartSection extends StatefulWidget {
  final DateTime start;
  final DateTime end;

  const ChartSection({super.key, required this.start, required this.end});

  @override
  State<ChartSection> createState() => _ChartSectionState();
}

class _ChartSectionState extends State<ChartSection> {
  bool _isDaily = true;
  int _selectedIndex = -1;
  Future<List<_ChartPoint>>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(ChartSection old) {
    super.didUpdateWidget(old);
    if (old.start != widget.start || old.end != widget.end) _load();
  }

  void _load() {
    final f = _isDaily ? _fetchHourly() : _fetchWeekly();
    // Auto-select peak point once data arrives
    f.then((pts) {
      if (!mounted || pts.isEmpty) return;
      final maxIdx = pts
          .asMap()
          .entries
          .reduce((a, b) => a.value.ms >= b.value.ms ? a : b)
          .key;
      if (mounted) setState(() => _selectedIndex = maxIdx);
    });
    setState(() {
      _selectedIndex = -1;
      _future = f;
    });
  }

  void _onToggle(bool daily) {
    if (_isDaily == daily) return;
    _isDaily = daily;
    _load();
  }

  // Daily tab → hourly breakdown of start date only
  Future<List<_ChartPoint>> _fetchHourly() async {
    final report = await getHourlyUsageReport(
      startDate: widget.start,
      endDate: widget.start,
    );
    final slots = List.filled(24, 0);
    for (final h in report.hours) {
      slots[h.hourStart.hour] = h.derivedTimeUsed;
    }
    return List.generate(24, (i) {
      final lbl = switch (i) {
        0  => '12am',
        6  => '6am',
        12 => '12pm',
        18 => '6pm',
        _  => '',
      };
      return _ChartPoint(lbl, slots[i]);
    });
  }

  // Weekly tab → day-by-day breakdown over full selected range
  Future<List<_ChartPoint>> _fetchWeekly() async {
    final report = await getWeeklyUsageReport(
      startDate: widget.start,
      endDate: widget.end,
    );
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return report.days
        .map((d) => _ChartPoint(dayNames[d.date.weekday - 1], d.actualTimeUsed))
        .toList();
  }

  void _onInteract(Offset local, int count, double width) {
    if (count < 2) return;
    const hPad = _ChartPainter.hPad;
    final chartW = width - hPad * 2;
    final idx = ((local.dx - hPad) / (chartW / (count - 1)))
        .round()
        .clamp(0, count - 1);
    if (_selectedIndex != idx) setState(() => _selectedIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildToggle(),
          const SizedBox(height: 16),
          FutureBuilder<List<_ChartPoint>>(
            future: _future,
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return _buildPlaceholder();
              }
              final pts = snap.data ?? [];
              if (pts.isEmpty) return _buildPlaceholder();
              return _buildChart(pts);
            },
          ),
        ],
      ),
    );
  }

  // ── Toggle ──────────────────────────────────────────────────────────────────

  Widget _buildToggle() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'Daily',
            active: _isDaily,
            onTap: () => _onToggle(true),
          ),
          _TabButton(
            label: 'Weekly',
            active: !_isDaily,
            onTap: () => _onToggle(false),
          ),
        ],
      ),
    );
  }

  // ── Chart ────────────────────────────────────────────────────────────────────

  Widget _buildChart(List<_ChartPoint> pts) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final w = constraints.maxWidth;
        return GestureDetector(
          onTapDown: (d) => _onInteract(d.localPosition, pts.length, w),
          onHorizontalDragUpdate: (d) => _onInteract(d.localPosition, pts.length, w),
          child: SizedBox(
            height: 180,
            width: w,
            child: CustomPaint(
              painter: _ChartPainter(
                points: pts,
                selectedIndex: _selectedIndex,
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Placeholder ──────────────────────────────────────────────────────────────

  Widget _buildPlaceholder() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          'No data',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ─── Toggle tab button ────────────────────────────────────────────────────────

class _TabButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: active
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Chart painter ────────────────────────────────────────────────────────────

class _ChartPainter extends CustomPainter {
  final List<_ChartPoint> points;
  final int selectedIndex;

  static const hPad   = 16.0;
  static const _topPad = 48.0;
  static const _botPad = 28.0;

  const _ChartPainter({required this.points, required this.selectedIndex});

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.selectedIndex != selectedIndex || old.points != points;

  static String _fmt(int ms) {
    final total = ms ~/ 60000;
    final h = total ~/ 60;
    final m = total % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  @override
  void paint(Canvas canvas, Size size) {
    final n = points.length;
    if (n < 2) return;

    final maxMs = points.map((p) => p.ms).reduce(max).toDouble();
    if (maxMs <= 0) return;

    final l = hPad;
    final r = size.width - hPad;
    final t = _topPad;
    final b = size.height - _botPad;
    final cw = r - l;
    final ch = b - t;

    // Coordinate helpers
    double px(int i) => l + (i / (n - 1)) * cw;
    double py(double ms) => b - (ms / maxMs) * ch;

    final coords = List.generate(
      n,
      (i) => Offset(px(i), py(points[i].ms.toDouble())),
    );

    // ── 1. Gradient fill ───────────────────────────────────────────────────
    final fillPath = Path()
      ..moveTo(coords.first.dx, b)
      ..lineTo(coords.first.dx, coords.first.dy);
    _addCurve(fillPath, coords);
    fillPath
      ..lineTo(coords.last.dx, b)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.18),
            AppColors.primary.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTRB(l, t, r, b)),
    );

    // ── 2. Line ────────────────────────────────────────────────────────────
    final linePath = Path()
      ..moveTo(coords.first.dx, coords.first.dy);
    _addCurve(linePath, coords);

    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // ── 3. Dots (non-selected) ─────────────────────────────────────────────
    for (int i = 0; i < n; i++) {
      if (i == selectedIndex) continue;
      _drawDot(canvas, coords[i], 3.5, false);
    }

    // ── 4. Selected point ──────────────────────────────────────────────────
    if (selectedIndex >= 0 && selectedIndex < n) {
      final sp = coords[selectedIndex];
      _drawDashed(canvas, Offset(sp.dx, sp.dy + 10), Offset(sp.dx, b));
      _drawDot(canvas, sp, 6.0, true);
      _drawTooltip(canvas, sp, _fmt(points[selectedIndex].ms), size.width);
    }

    // ── 5. X-axis labels ───────────────────────────────────────────────────
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < n; i++) {
      final lbl = points[i].label;
      if (lbl.isEmpty) continue;
      tp.text = TextSpan(
        text: lbl,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(coords[i].dx - tp.width / 2, b + 6));
    }
  }

  // Smooth cubic bezier through points
  void _addCurve(Path path, List<Offset> pts) {
    for (int i = 0; i < pts.length - 1; i++) {
      final cpX = (pts[i].dx + pts[i + 1].dx) / 2;
      path.cubicTo(
        cpX, pts[i].dy,
        cpX, pts[i + 1].dy,
        pts[i + 1].dx, pts[i + 1].dy,
      );
    }
  }

  void _drawDot(Canvas canvas, Offset c, double r, bool selected) {
    // Fill
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = selected ? AppColors.primary : Colors.white
        ..style = PaintingStyle.fill,
    );
    // Border
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = selected ? 0 : 1.5
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawDashed(Canvas canvas, Offset from, Offset to) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 1.2;
    final dir = to - from;
    final len = dir.distance;
    final unit = Offset(dir.dx / len, dir.dy / len);
    double d = 0;
    bool draw = true;
    while (d < len) {
      final next = (d + 4.0).clamp(0.0, len);
      if (draw) {
        canvas.drawLine(from + unit * d, from + unit * next, paint);
      }
      d = next;
      draw = !draw;
    }
  }

  void _drawTooltip(Canvas canvas, Offset pt, String text, double canvasW) {
    const hPad = 10.0;
    const vPad = 6.0;
    const arrowH = 5.0;
    const arrowW = 5.0;
    const radius = 8.0;

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final boxW = tp.width + hPad * 2;
    final boxH = tp.height + vPad * 2;

    double left = pt.dx - boxW / 2;
    left = left.clamp(4.0, canvasW - boxW - 4.0);
    final top = pt.dy - boxH - arrowH - 6.0;

    // Box
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, boxW, boxH),
        const Radius.circular(radius),
      ),
      Paint()..color = AppColors.primary,
    );

    // Arrow
    final ax = pt.dx.clamp(left + radius, left + boxW - radius);
    canvas.drawPath(
      Path()
        ..moveTo(ax - arrowW, top + boxH)
        ..lineTo(ax, top + boxH + arrowH)
        ..lineTo(ax + arrowW, top + boxH)
        ..close(),
      Paint()..color = AppColors.primary,
    );

    // Text
    tp.paint(canvas, Offset(left + hPad, top + vPad));
  }
}
