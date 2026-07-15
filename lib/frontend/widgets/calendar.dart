import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

void showCalendarSheet(
  BuildContext context, {
  required Function(DateTime start, DateTime? end) onApply,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DateRangePickerSheet(onApply: onApply),
  );
}

class DateRangePickerSheet extends StatefulWidget {
  final Function(DateTime start, DateTime? end) onApply;

  const DateRangePickerSheet({super.key, required this.onApply});

  @override
  State<DateRangePickerSheet> createState() => _DateRangePickerSheetState();
}

class _DateRangePickerSheetState extends State<DateRangePickerSheet> {
  late final DateTime _minDate;
  late final DateTime _maxDate;

  DateTime? _start;
  DateTime? _end;
  late DateTime _displayMonth;
  String? _activeShortcut;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _maxDate = DateTime(today.year, today.month, today.day);
    _minDate = _maxDate.subtract(const Duration(days: 20));
    _displayMonth = DateTime(_maxDate.year, _maxDate.month);
  }

  static DateTime _norm(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _inWindow(DateTime date) {
    final d = _norm(date);
    return !d.isBefore(_minDate) && !d.isAfter(_maxDate);
  }

  bool _isSelected(DateTime date) {
    final d = _norm(date);
    return (_start != null && d == _start) || (_end != null && d == _end);
  }

  bool _isInRange(DateTime date) {
    if (_start == null || _end == null) return false;
    final d = _norm(date);
    return d.isAfter(_start!) && d.isBefore(_end!);
  }

  bool _isStart(DateTime date) => _start != null && _norm(date) == _start;
  bool _isEnd(DateTime date) => _end != null && _norm(date) == _end;

  void _onDayTap(DateTime date) {
    final d = _norm(date);
    setState(() {
      _activeShortcut = null;
      if (_start == null || _end != null) {
        _start = d;
        _end = null;
      } else {
        if (d == _start) {
          _start = null;
        } else if (d.isBefore(_start!)) {
          _end = _start;
          _start = d;
        } else {
          _end = d;
        }
      }
    });
  }

  void _applyShortcut(String key) {
    setState(() {
      _activeShortcut = key;
      switch (key) {
        case 'yesterday':
          _start = _maxDate.subtract(const Duration(days: 1));
          _end = null;
          break;
        case 'last7':
          _start = _maxDate.subtract(const Duration(days: 6));
          _end = _maxDate;
          break;
        case 'last14':
          _start = _maxDate.subtract(const Duration(days: 13));
          _end = _maxDate;
          break;
      }
      if (_start != null) {
        _displayMonth = DateTime(_start!.year, _start!.month);
      }
    });
  }

  bool get _canGoBack {
    final prev = DateTime(_displayMonth.year, _displayMonth.month - 1);
    return !prev.isBefore(DateTime(_minDate.year, _minDate.month));
  }

  bool get _canGoForward {
    final next = DateTime(_displayMonth.year, _displayMonth.month + 1);
    return !next.isAfter(DateTime(_maxDate.year, _maxDate.month));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            _buildTitleRow(),
            _buildShortcuts(),
            _buildMonthHeader(),
            _buildDayLabels(),
            _buildGrid(),
            _buildApplyButton(context),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() => Container(
        margin: const EdgeInsets.only(top: 12, bottom: 4),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _buildTitleRow() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Select dates',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => setState(() {
                _start = null;
                _end = null;
                _activeShortcut = null;
              }),
              child: const Text(
                'Reset',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildShortcuts() {
    final items = [
      ('Yesterday', 'yesterday'),
      ('Last 7 days', 'last7'),
      ('Last 14 days', 'last14'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items.map((item) {
            final active = _activeShortcut == item.$2;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => _applyShortcut(item.$2),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primary
                        : const Color(0xFFF0F1F7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.$1,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color:
                          active ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMonthHeader() {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 12, 0),
      child: Row(
        children: [
          Text(
            '${months[_displayMonth.month - 1]} ${_displayMonth.year}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _canGoBack
                ? () => setState(() => _displayMonth =
                    DateTime(_displayMonth.year, _displayMonth.month - 1))
                : null,
            icon: Icon(
              Icons.chevron_left,
              color:
                  _canGoBack ? AppColors.textPrimary : Colors.grey.shade300,
            ),
          ),
          IconButton(
            onPressed: _canGoForward
                ? () => setState(() => _displayMonth =
                    DateTime(_displayMonth.year, _displayMonth.month + 1))
                : null,
            icon: Icon(
              Icons.chevron_right,
              color: _canGoForward
                  ? AppColors.textPrimary
                  : Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayLabels() {
    const labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: labels
            .map((l) => SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(
                      l,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildGrid() {
    final firstDay =
        DateTime(_displayMonth.year, _displayMonth.month, 1);
    final daysInMonth =
        DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;
    // weekday: Mon=1..Sun=7 → convert to Sun=0..Sat=6
    final startOffset = firstDay.weekday % 7;

    final cells = <Widget>[];

    for (int i = 0; i < startOffset; i++) {
      cells.add(const SizedBox(width: 40, height: 44));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date =
          DateTime(_displayMonth.year, _displayMonth.month, day);
      cells.add(_DayCell(
        day: day,
        inWindow: _inWindow(date),
        isSelected: _isSelected(date),
        isInRange: _isInRange(date),
        isStart: _isStart(date),
        isEnd: _isEnd(date),
        hasRange: _end != null,
        onTap: _inWindow(date) ? () => _onDayTap(date) : null,
      ));
    }

    final rem = cells.length % 7;
    if (rem != 0) {
      for (int i = 0; i < 7 - rem; i++) {
        cells.add(const SizedBox(width: 40, height: 44));
      }
    }

    final rows = <Widget>[];
    for (int i = 0; i < cells.length; i += 7) {
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: cells.sublist(i, i + 7),
      ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(children: rows),
    );
  }



  Widget _buildApplyButton(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _start != null
                ? () {
                    widget.onApply(_start!, _end);
                    Navigator.pop(context);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor:
                  AppColors.primary.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(
              'Apply',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
}

// ── Day Cell ─────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final int day;
  final bool inWindow;
  final bool isSelected;
  final bool isInRange;
  final bool isStart;
  final bool isEnd;
  final bool hasRange;
  final VoidCallback? onTap;

  const _DayCell({
    required this.day,
    required this.inWindow,
    required this.isSelected,
    required this.isInRange,
    required this.isStart,
    required this.isEnd,
    required this.hasRange,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const rangeColor = Color(0xFFDDE3FC);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 40,
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Range highlight strip
            if (hasRange && (isStart || isEnd || isInRange))
              Positioned(
                left: isEnd && !isStart ? 0 : 20,
                right: isStart && !isEnd ? 0 : 20,
                top: 4,
                bottom: 4,
                child: Container(color: rangeColor),
              ),
            // Selection circle
            Container(
              width: 36,
              height: 36,
              decoration: isSelected
                  ? const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: inWindow
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: !inWindow
                        ? Colors.grey.shade300
                        : isSelected
                            ? Colors.white
                            : isInRange
                                ? AppColors.primary
                                : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
