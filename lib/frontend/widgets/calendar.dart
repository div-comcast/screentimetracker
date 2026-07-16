import 'package:flutter/material.dart';

class CalendarWidget extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime? initialEndDate;
  final ValueChanged<DateTime>? onDateSelected;
  final void Function(DateTime start, DateTime end)? onRangeSelected;

  const CalendarWidget({
    super.key,
    this.initialDate,
    this.initialEndDate,
    this.onDateSelected,
    this.onRangeSelected,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  // 21-day window: today − 20  →  today
  late final DateTime _minDate;
  late final DateTime _maxDate;

  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  late DateTime _displayedMonth;

  static const List<String> _weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _maxDate = DateTime(now.year, now.month, now.day);
    _minDate = _maxDate.subtract(const Duration(days: 20));

    final init = widget.initialDate != null
        ? _clamp(widget.initialDate!)
        : _maxDate;
    _rangeStart = init;
    _rangeEnd = widget.initialEndDate != null
        ? _clamp(widget.initialEndDate!)
        : null;
    _displayedMonth = DateTime(init.year, init.month);
  }

  DateTime _clamp(DateTime d) {
    final date = DateTime(d.year, d.month, d.day);
    if (date.isBefore(_minDate)) return _minDate;
    if (date.isAfter(_maxDate)) return _maxDate;
    return date;
  }

  bool _isDisabled(DateTime date) =>
      date.isBefore(_minDate) || date.isAfter(_maxDate);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isInRange(DateTime date) {
    if (_rangeStart == null || _rangeEnd == null) return false;
    final d = DateTime(date.year, date.month, date.day);
    return d.isAfter(_rangeStart!) && d.isBefore(_rangeEnd!);
  }

  bool _isRangeStart(DateTime date) =>
      _rangeStart != null && _isSameDay(date, _rangeStart!);

  bool _isRangeEnd(DateTime date) =>
      _rangeEnd != null && _isSameDay(date, _rangeEnd!);

  String _formatShort(DateTime d) {
    final m = _months[d.month - 1].substring(0, 3);
    return '$m ${d.day}';
  }

  String get _pillLabel {
    if (_rangeStart == null) return _formatShort(_maxDate);
    if (_rangeEnd == null) return _formatShort(_rangeStart!);
    return '${_formatShort(_rangeStart!)} – ${_formatShort(_rangeEnd!)}';
  }

  bool get _isRange => _rangeEnd != null;

  bool get _canGoBack {
    final current = _rangeStart ?? _maxDate;
    return !current.isAtSameMomentAs(_minDate) && !current.isBefore(_minDate);
  }

  bool get _canGoForward {
    final current = _rangeStart ?? _maxDate;
    return current.isBefore(_maxDate);
  }

  void _stepDay(int delta) {
    final current = _rangeStart ?? _maxDate;
    final next = current.add(Duration(days: delta));
    if (next.isBefore(_minDate) || next.isAfter(_maxDate)) return;
    setState(() {
      _rangeStart = next;
      _rangeEnd = null;
      _displayedMonth = DateTime(next.year, next.month);
    });
    widget.onDateSelected?.call(next);
  }

  void _onDateTap(DateTime date, StateSetter setSheetState) {
    if (_isDisabled(date)) return;

    setSheetState(() {
      if (_rangeStart == null || _rangeEnd != null) {
        _rangeStart = date;
        _rangeEnd = null;
      } else {
        if (date.isBefore(_rangeStart!)) {
          _rangeEnd = _rangeStart;
          _rangeStart = date;
        } else if (_isSameDay(date, _rangeStart!)) {
          // Same day tapped twice → single date selection
          _rangeEnd = null;
        } else {
          _rangeEnd = date;
        }
      }
    });

    setState(() {});
  }

  void _applySelection() {
    if (_rangeStart == null) return;
    setState(() {});
    if (_rangeEnd != null) {
      widget.onRangeSelected?.call(_rangeStart!, _rangeEnd!);
    }
    widget.onDateSelected?.call(_rangeStart!);
    Navigator.of(context).pop();
  }

  // ── Date pill ─────────────────────────────────────────────────────────────
  Widget _buildDatePill(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ← back arrow
        _arrowButton(
          icon: Icons.chevron_left_rounded,
          enabled: _canGoBack && !_isRange,
          onTap: () => _stepDay(-1),
        ),

        const SizedBox(width: 4),

        // Date label (tap opens calendar)
        GestureDetector(
          onTap: () => _showCalendarSheet(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: const Color(0xFFCCCCCC), width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _pillLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                if (_isRange) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.close_rounded, size: 14, color: Color(0xFF999999)),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(width: 4),

        // → forward arrow
        _arrowButton(
          icon: Icons.chevron_right_rounded,
          enabled: _canGoForward && !_isRange,
          onTap: () => _stepDay(1),
        ),

        const SizedBox(width: 6),

        // Calendar icon
        GestureDetector(
          onTap: () => _showCalendarSheet(context),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFCCCCCC), width: 1.2),
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              size: 17,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _arrowButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Icon(
        icon,
        size: 22,
        color: enabled
            ? const Color(0xFF1A1A1A)
            : const Color(0xFFCCCCCC),
      ),
    );
  }

  // ── Bottom sheet ──────────────────────────────────────────────────────────
  void _showCalendarSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SingleChildScrollView(
              child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title + status hint
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Period',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        _rangeStart == null
                            ? 'Tap a start date'
                            : _rangeEnd == null
                                ? 'Now tap end date'
                                : '${_formatShort(_rangeStart!)} – ${_formatShort(_rangeEnd!)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Max 21 days from today',
                      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Month navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => setSheetState(() {
                          _displayedMonth = DateTime(
                              _displayedMonth.year, _displayedMonth.month - 1);
                        }),
                        icon: const Icon(Icons.chevron_left_rounded),
                        color: const Color(0xFF1A1A1A),
                      ),
                      Text(
                        '${_months[_displayedMonth.month - 1]} ${_displayedMonth.year}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setSheetState(() {
                          _displayedMonth = DateTime(
                              _displayedMonth.year, _displayedMonth.month + 1);
                        }),
                        icon: const Icon(Icons.chevron_right_rounded),
                        color: const Color(0xFF1A1A1A),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Weekday headers
                  Row(
                    children: _weekDays
                        .map((d) => Expanded(
                              child: Center(
                                child: Text(
                                  d,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 6),

                  _buildDateGrid(setSheetState),

                  const SizedBox(height: 20),

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _rangeStart != null ? _applySelection : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE87070),
                        disabledBackgroundColor: const Color(0xFFE0D6CA),
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white60,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Apply',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            );
          },
        );
      },
    );
  }

  // ── Date grid ─────────────────────────────────────────────────────────────
  Widget _buildDateGrid(StateSetter setSheetState) {
    final firstDay = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final daysInMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    final startOffset = firstDay.weekday % 7; // Sunday = 0

    final allCells = <DateTime?>[
      ...List.filled(startOffset, null),
      for (int d = 1; d <= daysInMonth; d++)
        DateTime(_displayedMonth.year, _displayedMonth.month, d),
    ];

    final rows = <Widget>[];
    for (int i = 0; i < allCells.length; i += 7) {
      final week = allCells.sublist(i, (i + 7).clamp(0, allCells.length));
      rows.add(Row(
        children: List.generate(7, (col) {
          if (col >= week.length || week[col] == null) {
            return const Expanded(child: SizedBox(height: 44));
          }
          return Expanded(
              child: _buildDayCell(week[col]!, setSheetState));
        }),
      ));
    }

    return Column(children: rows);
  }

  Widget _buildDayCell(DateTime date, StateSetter setSheetState) {
    final disabled = _isDisabled(date);
    final isStart = _isRangeStart(date);
    final isEnd = _isRangeEnd(date);
    final inRange = _isInRange(date);
    final isToday = _isSameDay(date, _maxDate);
    final selected = isStart || isEnd;
    final hasRange = _rangeEnd != null;

    Color? stripColor;
    BorderRadius? stripRadius;
    if ((inRange || isStart || isEnd) && hasRange) {
      stripColor = const Color(0xFFE87070).withValues(alpha: 0.15);
      if (isStart) {
        stripRadius = const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        );
      } else if (isEnd) {
        stripRadius = const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        );
      }
    }

    return GestureDetector(
      onTap: disabled ? null : () => _onDateTap(date, setSheetState),
      child: Container(
        height: 44,
        decoration: BoxDecoration(color: stripColor, borderRadius: stripRadius),
        child: Center(
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFE87070) : Colors.transparent,
              shape: BoxShape.circle,
              border: isToday && !selected
                  ? Border.all(color: const Color(0xFFE87070), width: 1.5)
                  : null,
            ),
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: disabled
                      ? Colors.grey[300]
                      : selected
                          ? Colors.white
                          : const Color(0xFF1A1A1A),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _buildDatePill(context);
}

