import 'dart:math';
import 'package:flutter/material.dart';
import '../../../backend/domains/usage/reports.dart';
import '../../../backend/domains/usage/schema.dart';
import '../../theme/app_theme.dart';

// ─── Internal data class ───────────────────────────────────────────────────────

class _DayData {
  final DateTime date;
  final int totalMs;
  final List<AppSession> sessions;

  _DayData({
    required this.date,
    required this.totalMs,
    required this.sessions,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class AppSessionsScreen extends StatefulWidget {
  final AppDailyRecord app;
  final DateTime start;
  final DateTime end;

  const AppSessionsScreen({
    super.key,
    required this.app,
    required this.start,
    required this.end,
  });

  @override
  State<AppSessionsScreen> createState() => _AppSessionsScreenState();
}

class _AppSessionsScreenState extends State<AppSessionsScreen> {
  bool get _isSingleDay =>
      widget.start.year == widget.end.year &&
      widget.start.month == widget.end.month &&
      widget.start.day == widget.end.day;

  List<_DayData>? _dayData;
  bool _loading = true;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_isSingleDay) {
      setState(() => _loading = false);
      return;
    }

    final days = _daysInRange(widget.start, widget.end);
    final results = await Future.wait(
      days.map((day) async {
        final sessions = await getSessionsForApp(
          widget.app.packageName,
          day,
          day.add(const Duration(days: 1)),
        );
        final total = sessions.fold(0, (sum, s) => sum + s.duration);
        return _DayData(date: day, totalMs: total, sessions: sessions);
      }),
    );

    if (!mounted) return;

    int peakIdx = 0;
    int peakMs = 0;
    for (var i = 0; i < results.length; i++) {
      if (results[i].totalMs > peakMs) {
        peakMs = results[i].totalMs;
        peakIdx = i;
      }
    }

    setState(() {
      _dayData = results;
      _selectedDayIndex = peakIdx;
      _loading = false;
    });
  }

  static List<DateTime> _daysInRange(DateTime start, DateTime end) {
    final days = <DateTime>[];
    var d = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);
    while (!d.isAfter(last)) {
      days.add(d);
      d = d.add(const Duration(days: 1));
    }
    return days;
  }

  // ── Derived state ────────────────────────────────────────────────────────────

  List<AppSession> get _currentSessions {
    if (_isSingleDay) return widget.app.sessions;
    if (_dayData == null || _dayData!.isEmpty) return const [];
    return _dayData![_selectedDayIndex].sessions;
  }

  DateTime get _currentDay {
    if (_isSingleDay) return widget.start;
    if (_dayData == null || _dayData!.isEmpty) return widget.start;
    return _dayData![_selectedDayIndex].date;
  }

  int get _currentDayTotal {
    if (_isSingleDay) return widget.app.actualTimeUsed;
    if (_dayData == null || _dayData!.isEmpty) return 0;
    return _dayData![_selectedDayIndex].totalMs;
  }

  int get _totalMs {
    if (_isSingleDay) return widget.app.actualTimeUsed;
    if (_dayData == null) return 0;
    return _dayData!.fold(0, (sum, d) => sum + d.totalMs);
  }

  int get _totalSessions {
    if (_isSingleDay) return widget.app.sessionCount;
    if (_dayData == null) return 0;
    return _dayData!.fold(0, (sum, d) => sum + d.sessions.length);
  }

  int get _activeDays {
    if (_isSingleDay) return widget.app.actualTimeUsed > 0 ? 1 : 0;
    if (_dayData == null) return 0;
    return _dayData!.where((d) => d.totalMs > 0).length;
  }

  int get _avgPerDay {
    final active = _activeDays;
    if (active == 0) return 0;
    return _totalMs ~/ active;
  }

  // ── Formatters ───────────────────────────────────────────────────────────────

  static String _fmtMs(int ms) {
    final total = ms ~/ 60000;
    final h = total ~/ 60;
    final m = total % 60;
    if (total == 0) return '0m';
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverToBoxAdapter(child: _buildAppInfo()),
                  SliverToBoxAdapter(child: _buildStats()),
                  if (!_isSingleDay)
                    SliverToBoxAdapter(child: _buildDailyBreakdown()),
                  SliverToBoxAdapter(child: _buildSessionsSection()),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'App detail',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  // ── App info ─────────────────────────────────────────────────────────────────

  Widget _buildAppInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          _AppIcon(app: widget.app, size: 52, radius: 14),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.app.appName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  widget.app.category,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _DatePill(start: widget.start, end: widget.end),
        ],
      ),
    );
  }

  // ── Stats ────────────────────────────────────────────────────────────────────

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TOTAL THIS RANGE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _fmtMs(_totalMs),
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$_totalSessions sessions · avg ${_fmtMs(_avgPerDay)} / day',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Daily breakdown (multi-day only) ─────────────────────────────────────────

  Widget _buildDailyBreakdown() {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final data = _dayData!;
    final monthLabel = months[widget.start.month - 1];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily breakdown',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                monthLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _BarChart(
            data: data,
            selectedIndex: _selectedDayIndex,
            onSelect: (i) => setState(() => _selectedDayIndex = i),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Tap a day to see its sessions',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Sessions section ─────────────────────────────────────────────────────────

  Widget _buildSessionsSection() {
    final sessions = _currentSessions;
    final total = _currentDayTotal;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SessionsHeader(day: _currentDay, totalMs: total),
          const SizedBox(height: 16),
          if (sessions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No sessions recorded',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ...sessions.asMap().entries.map(
                  (e) => _SessionRow(
                    session: e.value,
                    maxMs: sessions.map((s) => s.duration).reduce(max),
                    isLast: e.key == sessions.length - 1,
                  ),
                ),
        ],
      ),
    );
  }
}

// ─── App icon ─────────────────────────────────────────────────────────────────

class _AppIcon extends StatelessWidget {
  final AppDailyRecord app;
  final double size;
  final double radius;

  const _AppIcon({
    required this.app,
    required this.size,
    required this.radius,
  });

  static const _fallbackColors = [
    Color(0xFFE8553E), Color(0xFFE8403B), Color(0xFF3D8EF8),
    Color(0xFF25D366), Color(0xFF1DB954), Color(0xFF6C63FF),
    Color(0xFFFFA500), Color(0xFF111111),
  ];

  @override
  Widget build(BuildContext context) {
    if (app.appIcon != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.memory(
          app.appIcon!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    final bg =
        _fallbackColors[app.appName.hashCode.abs() % _fallbackColors.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: Text(
        app.appName.isNotEmpty ? app.appName[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ─── Date pill ────────────────────────────────────────────────────────────────

class _DatePill extends StatelessWidget {
  final DateTime start;
  final DateTime end;

  const _DatePill({required this.start, required this.end});

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String get _label {
    final isSame = start.year == end.year &&
        start.month == end.month &&
        start.day == end.day;
    if (isSame) return '${_months[start.month - 1]} ${start.day}';
    if (start.month == end.month && start.year == end.year) {
      return '${_months[start.month - 1]} ${start.day} – ${end.day}';
    }
    return '${_months[start.month - 1]} ${start.day} – ${_months[end.month - 1]} ${end.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today_rounded,
            size: 13,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            _label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bar chart ────────────────────────────────────────────────────────────────

class _BarChart extends StatelessWidget {
  final List<_DayData> data;
  final int selectedIndex;
  final void Function(int) onSelect;

  const _BarChart({
    required this.data,
    required this.selectedIndex,
    required this.onSelect,
  });

  static const _weekDayAbbr = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];
  static const _maxBarH = 100.0;
  static const _minBarH = 5.0;
  static const _barW = 38.0;
  static const _itemW = _barW + 16.0;

  @override
  Widget build(BuildContext context) {
    final maxMs = data.fold(0, (m, d) => d.totalMs > m ? d.totalMs : m);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        height: _maxBarH + 34,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: data.asMap().entries.map((e) {
            final i = e.key;
            final d = e.value;
            final selected = i == selectedIndex;
            final fraction = maxMs > 0 ? d.totalMs / maxMs : 0.0;
            final barH = d.totalMs > 0
                ? (_minBarH + fraction * (_maxBarH - _minBarH))
                : _minBarH * 0.5;
            final dow = (d.date.weekday - 1) % 7;
            final label = '${_weekDayAbbr[dow]} ${d.date.day}';

            return GestureDetector(
              onTap: () => onSelect(i),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: _itemW,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: _barW,
                      height: barH,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.18),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.normal,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── Sessions header ──────────────────────────────────────────────────────────

class _SessionsHeader extends StatelessWidget {
  final DateTime day;
  final int totalMs;

  const _SessionsHeader({required this.day, required this.totalMs});

  static const _dayAbbr = [
    'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN',
  ];
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String _fmtMs(int ms) {
    final total = ms ~/ 60000;
    final h = total ~/ 60;
    final m = total % 60;
    if (total == 0) return '0m';
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final dow = (day.weekday - 1) % 7;
    final label = '${_dayAbbr[dow]}, ${_months[day.month - 1]} ${day.day}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'SESSIONS · $label',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _fmtMs(totalMs),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Session row ──────────────────────────────────────────────────────────────

class _SessionRow extends StatelessWidget {
  final AppSession session;
  final int maxMs;
  final bool isLast;

  const _SessionRow({
    required this.session,
    required this.maxMs,
    this.isLast = false,
  });

  static String _fmtMs(int ms) {
    final total = ms ~/ 60000;
    final h = total ~/ 60;
    final m = total % 60;
    if (total == 0) return '<1m';
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  static String _fmtTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final fraction = maxMs > 0 ? session.duration / maxMs : 0.0;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Start time label
          SizedBox(
            width: 76,
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                _fmtTime(session.start),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Timeline: circle + vertical connector
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                  color: Colors.white,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Duration + end time + progress bar
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 4 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _fmtMs(session.duration),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'ends ${_fmtTime(session.end)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (_, c) => Stack(
                      children: [
                        Container(
                          height: 4,
                          width: c.maxWidth,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Container(
                          height: 4,
                          width: c.maxWidth * fraction.clamp(0.0, 1.0),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
