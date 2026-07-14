import 'dart:math';
import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../theme/app_theme.dart';
import '../widgets/usage_kpi.dart';
import '../widgets/topbar_section.dart';
import '../widgets/appusage_tiles.dart';
import 'sessions.dart';

/// Main dashboard screen — assembles all widgets matching the design.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedTab = 0;
  int _reportViewIndex = 0; // 0 = Daily, 1 = Weekly
  String _selectedCategory = 'All';
  bool _showCalendar = false;

  // Date state: supports single date or range. Today = max, 14 days ago = min.
  late DateTime _startDate;
  late DateTime _endDate;
  late DateTime _today;
  late DateTime _minDate;

  // Range selection state for calendar
  bool _isRangeMode = false;
  DateTime? _rangePickStart; // non-null after user picked start, waiting for end

  // Calendar month view state
  late int _calendarMonth; // 1-12
  late int _calendarYear;

  static const _months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const _monthsFull = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _today = DateTime(_today.year, _today.month, _today.day);
    _startDate = _today;
    _endDate = _today;
    _minDate = _today.subtract(const Duration(days: 13));
    _calendarMonth = _today.month;
    _calendarYear = _today.year;
  }

  bool get _isRange => _startDate != _endDate;

  String _formatDate(DateTime d) => '${d.day} ${_monthsFull[d.month]} ${d.year}';
  String _formatShort(DateTime d) => '${d.day} ${_months[d.month]}';

  String get _datePillText {
    if (_isRange) return '${_formatShort(_startDate)} – ${_formatShort(_endDate)}';
    return _formatDate(_startDate);
  }

  bool get _canGoForward => _endDate.isBefore(_today);
  bool get _canGoBack => _startDate.isAfter(_minDate);

  // Backend categories from AppCategory enum
  static const _categories = [
    'All', 'Games', 'Audio', 'Videos', 'Photos',
    'Social', 'News', 'Maps', 'Productivity', 'Other',
  ];

  List<DummyAppUsage> get _filteredApps {
    if (_selectedTab != 1 || _selectedCategory == 'All') return dummyApps;
    return dummyApps.where((a) => a.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Main scrollable content ──────────────────────────
            CustomScrollView(
              slivers: [
                // ── App Bar ──────────────────────────────────────
                SliverToBoxAdapter(child: _buildAppBar()),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Daily / Weekly Toggle ────────────────────────────────
            SliverToBoxAdapter(child: _buildReportToggle()),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // ── KPI Card (daily or weekly) ───────────────────────────
            SliverToBoxAdapter(child: _buildKpiCard()),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Peak Card ────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildPeakCard()),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Chart Card ───────────────────────────────────────────
            SliverToBoxAdapter(child: _buildChartCard()),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Activity Row ─────────────────────────────────────────
            SliverToBoxAdapter(child: _buildActivityRow()),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Insights Card ────────────────────────────────────────
            SliverToBoxAdapter(child: _buildInsightsCard()),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Tab Bar ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: TabBarSection(
                selectedIndex: _selectedTab,
                onTabChanged: (i) => setState(() => _selectedTab = i),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Content based on selected tab ────────────────────
              // ── Sort Header ──────────────────────────────────────
              SliverToBoxAdapter(child: _buildSortHeader()),

              // ── App List ─────────────────────────────────────────
              if (_filteredApps.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Text(
                        'No apps in this category',
                        style: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final app = _filteredApps[index];
                      return AppUsageTile(
                        app: app,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SessionsScreen(app: app),
                            ),
                          );
                        },
                      );
                    },
                    childCount: _filteredApps.length,
                  ),
                ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),

            // ── Calendar Overlay ─────────────────────────────────
            if (_showCalendar) ...[
              // Tap-to-dismiss scrim
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _showCalendar = false;
                    _rangePickStart = null;
                    _isRangeMode = false;
                  }),
                  child: Container(color: Colors.black.withValues(alpha: 0.2)),
                ),
              ),
              // Floating calendar card
              Positioned(
                top: 60,
                left: 24,
                right: 24,
                child: Material(
                  color: Colors.transparent,
                  child: _buildInlineCalendar(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Top bar: hamburger, centered date nav, calendar icon ──────────

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Spacer(),
          // Left arrow (shift day back by 1)
          IconButton(
            onPressed: _canGoBack
                ? () => setState(() {
                      final newDate = _startDate.subtract(const Duration(days: 1));
                      _startDate = newDate;
                      _endDate = newDate;
                    })
                : null,
            icon: Icon(Icons.chevron_left,
                color: _canGoBack ? AppTheme.primary : AppTheme.textMuted.withValues(alpha: 0.3)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          // Date pill (tappable — toggles calendar)
          GestureDetector(
            onTap: () => setState(() => _showCalendar = !_showCalendar),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    _datePillText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Right arrow (shift day forward by 1)
          IconButton(
            onPressed: _canGoForward
                ? () => setState(() {
                      final newDate = _endDate.add(const Duration(days: 1));
                      _startDate = newDate;
                      _endDate = newDate;
                    })
                : null,
            icon: Icon(Icons.chevron_right,
                color: _canGoForward ? AppTheme.primary : AppTheme.textMuted.withValues(alpha: 0.3)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const Spacer(),
          // Profile icon → opens settings
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const _SettingsPage()),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person_outline,
                color: AppTheme.primary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Compact overlay calendar with quick options & range support ────

  Widget _buildInlineCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick options
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 14, 10, 0),
            child: Row(
              children: [
                _quickChip('Today', () => _selectSingle(_today)),
                const SizedBox(width: 6),
                _quickChip('Yesterday', () => _selectSingle(_today.subtract(const Duration(days: 1)))),
                const SizedBox(width: 6),
                _quickChip('Last 7d', () => _selectRange(_today.subtract(const Duration(days: 6)), _today)),
                const SizedBox(width: 6),
                _quickChip('Last 14d', () => _selectRange(_minDate, _today)),
              ],
            ),
          ),

          // Range pick hint
          if (_isRangeMode)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _rangePickStart == null
                    ? 'Tap to select start date'
                    : 'Now select end date (start: ${_formatShort(_rangePickStart!)})',
                style: TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w500),
              ),
            ),

          const Divider(height: 16, indent: 12, endIndent: 12),

          // Custom calendar grid — only shows days within 14-day window
          _buildCustomCalendar(),

          // Mode toggle: single vs range
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                _modeChip('Single Day', !_isRangeMode, () {
                  setState(() {
                    _isRangeMode = false;
                    _rangePickStart = null;
                    _startDate = _today;
                    _endDate = _today;
                  });
                }),
                const SizedBox(width: 8),
                _modeChip('Date Range', _isRangeMode, () {
                  setState(() {
                    _isRangeMode = true;
                    _rangePickStart = null;
                    // Don't pre-select anything — user will make two clicks
                  });
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Custom calendar grid (one month at a time, max 2 months) ──────

  Widget _buildCustomCalendar() {
    // Get all 14 days
    final days = <DateTime>[];
    for (var d = _minDate; !d.isAfter(_today); d = d.add(const Duration(days: 1))) {
      days.add(d);
    }

    // Active days in the currently viewed month
    final activeDays = days.where((d) => d.month == _calendarMonth && d.year == _calendarYear).toList();

    // Can navigate back/forward? Only if the other month has active days
    final canGoBack = days.any((d) {
      final prevMonth = _calendarMonth == 1 ? 12 : _calendarMonth - 1;
      final prevYear = _calendarMonth == 1 ? _calendarYear - 1 : _calendarYear;
      return d.month == prevMonth && d.year == prevYear;
    });
    final canGoForward = days.any((d) {
      final nextMonth = _calendarMonth == 12 ? 1 : _calendarMonth + 1;
      final nextYear = _calendarMonth == 12 ? _calendarYear + 1 : _calendarYear;
      return d.month == nextMonth && d.year == nextYear;
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: _buildMonthGrid(
        DateTime(_calendarYear, _calendarMonth, 1),
        activeDays,
        canGoBack: canGoBack,
        canGoForward: canGoForward,
      ),
    );
  }

  Widget _buildMonthGrid(DateTime monthDate, List<DateTime> activeDays,
      {required bool canGoBack, required bool canGoForward}) {
    final monthName = _monthsFull[monthDate.month];
    final year = monthDate.year;

    // First day of the month
    final firstOfMonth = DateTime(monthDate.year, monthDate.month, 1);
    final daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;
    final startWeekday = firstOfMonth.weekday % 7; // 0=Mon in our grid

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month label with navigation arrows
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: [
              if (canGoBack)
                GestureDetector(
                  onTap: () => setState(() {
                    if (_calendarMonth == 1) {
                      _calendarMonth = 12;
                      _calendarYear--;
                    } else {
                      _calendarMonth--;
                    }
                  }),
                  child: const Icon(Icons.chevron_left, size: 20, color: AppTheme.primary),
                )
              else
                const SizedBox(width: 20),
              const SizedBox(width: 4),
              Text(
                '$monthName $year',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              if (canGoForward)
                GestureDetector(
                  onTap: () => setState(() {
                    if (_calendarMonth == 12) {
                      _calendarMonth = 1;
                      _calendarYear++;
                    } else {
                      _calendarMonth++;
                    }
                  }),
                  child: const Icon(Icons.chevron_right, size: 20, color: AppTheme.primary),
                )
              else
                const SizedBox(width: 20),
            ],
          ),
        ),
        // Day-of-week headers
        Row(
          children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
              .map((d) => Expanded(
                    child: Center(
                      child: Text(d,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textMuted)),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 4),
        // Day grid
        ..._buildWeekRows(firstOfMonth, daysInMonth, startWeekday, activeDays),
        const SizedBox(height: 8),
      ],
    );
  }

  List<Widget> _buildWeekRows(
      DateTime firstOfMonth, int daysInMonth, int startWeekday, List<DateTime> activeDays) {
    final rows = <Widget>[];
    // Monday = 0, adjust Flutter's weekday (Mon=1..Sun=7) to 0-indexed
    final offset = (firstOfMonth.weekday - 1) % 7;
    final totalCells = offset + daysInMonth;
    final weekCount = (totalCells / 7).ceil();

    for (var week = 0; week < weekCount; week++) {
      final cells = <Widget>[];
      for (var col = 0; col < 7; col++) {
        final dayIndex = week * 7 + col - offset + 1;
        if (dayIndex < 1 || dayIndex > daysInMonth) {
          cells.add(const Expanded(child: SizedBox(height: 36)));
          continue;
        }
        final date = DateTime(firstOfMonth.year, firstOfMonth.month, dayIndex);
        final isActive = activeDays.any((d) => d.day == date.day && d.month == date.month);
        final isSelected = (date == _startDate || date == _endDate) ||
            (_isRange && !date.isBefore(_startDate) && !date.isAfter(_endDate));
        final isRangeStart = _rangePickStart != null &&
            date.day == _rangePickStart!.day &&
            date.month == _rangePickStart!.month;

        cells.add(Expanded(
          child: GestureDetector(
            onTap: isActive ? () => _onCalendarDateTap(date) : null,
            child: Container(
              height: 36,
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: isRangeStart
                    ? AppTheme.primary.withValues(alpha: 0.3)
                    : isSelected
                        ? AppTheme.primary
                        : null,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                '$dayIndex',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected || isRangeStart ? FontWeight.w700 : FontWeight.w400,
                  color: !isActive
                      ? AppTheme.textMuted.withValues(alpha: 0.3)
                      : isSelected
                          ? Colors.white
                          : AppTheme.textPrimary,
                ),
              ),
            ),
          ),
        ));
      }
      rows.add(Row(children: cells));
    }
    return rows;
  }

  void _selectSingle(DateTime date) {
    setState(() {
      _startDate = date;
      _endDate = date;
      _rangePickStart = null;
      _showCalendar = false;
    });
  }

  void _selectRange(DateTime start, DateTime end) {
    setState(() {
      _startDate = start;
      _endDate = end;
      _rangePickStart = null;
      _showCalendar = false;
    });
  }

  void _onCalendarDateTap(DateTime date) {
    setState(() {
      if (!_isRangeMode) {
        // Single day mode: one tap selects and closes
        _startDate = date;
        _endDate = date;
        _showCalendar = false;
      } else if (_rangePickStart == null) {
        // Range mode, first click: set start date
        _rangePickStart = date;
      } else {
        // Range mode, second click: set end date, close
        if (date.isBefore(_rangePickStart!)) {
          _startDate = date;
          _endDate = _rangePickStart!;
        } else {
          _startDate = _rangePickStart!;
          _endDate = date;
        }
        _rangePickStart = null;
        _isRangeMode = false;
        _showCalendar = false;
      }
    });
  }

  Widget _quickChip(String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.scaffoldBg,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _modeChip(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primary : AppTheme.scaffoldBg,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // ─── "Apps" label + "By Usage Time" sort + category filter ─────────

  Widget _buildSortHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          const Text('Apps', style: AppTheme.headlineMedium),
          const Spacer(),
          if (_selectedTab == 1) ...[
            GestureDetector(
              onTap: _showCategorySheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _selectedCategory == 'All'
                      ? Colors.white
                      : AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _selectedCategory == 'All'
                        ? AppTheme.textMuted.withValues(alpha: 0.3)
                        : AppTheme.primary.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.filter_list, size: 16,
                        color: _selectedCategory == 'All' ? AppTheme.textSecondary : AppTheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      _selectedCategory,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _selectedCategory == 'All' ? AppTheme.textSecondary : AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.keyboard_arrow_down, size: 16,
                        color: _selectedCategory == 'All' ? AppTheme.textSecondary : AppTheme.primary),
                  ],
                ),
              ),
            ),
          ] else ...[
            Row(
              children: [
                Text(
                  'By Usage Time',
                  style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.sort, size: 18, color: AppTheme.textSecondary),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─── Category bottom sheet ────────────────────────────────────────

  void _showCategorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Filter by Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 12),
              ...(_categories.map((cat) {
                final isSelected = cat == _selectedCategory;
                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                    size: 22,
                  ),
                  title: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                    ),
                  ),
                  onTap: () {
                    setState(() => _selectedCategory = cat);
                    Navigator.pop(ctx);
                  },
                );
              })),
              SizedBox(height: MediaQuery.of(ctx).padding.bottom + 16),
            ],
          ),
        );
      },
    );
  }

  // ─── Daily / Weekly Toggle ──────────────────────────────────────────

  Widget _buildReportToggle() {
    final labels = ['Daily', 'Weekly'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
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
            final isSelected = i == _reportViewIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _reportViewIndex = i),
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
      ),
    );
  }

  // ─── KPI Card: Daily = existing card, Weekly = new weekly card ──────

  Widget _buildKpiCard() {
    if (_reportViewIndex == 0) {
      return UsageSummaryCard(
        kpi: dummyKpi,
        donutSegments: dummyDonutSegments,
        date: dummyDate,
      );
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: AppTheme.cardRadius,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Time Used',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                const Text('38h 20m',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.calendar_today,
                          color: Colors.white70, size: 14),
                      SizedBox(width: 4),
                      Text('7 active days',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 12)),
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
            Text(label,
                style: const TextStyle(color: Colors.white54, fontSize: 10)),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }

  // ─── Peak Card ──────────────────────────────────────────────────────

  Widget _buildPeakCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
      ),
      child: _reportViewIndex == 0 ? _dailyPeak() : _weeklyPeak(),
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
                  Text('Peak Hour',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('8 PM – 9 PM',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Text('55m 15s',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary)),
              Text('Time Used', style: AppTheme.bodySmall),
            ],
          ),
        ),
        Container(
            width: 1,
            height: 70,
            color: AppTheme.textMuted.withValues(alpha: 0.2)),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: AppTheme.primary, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('73',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary)),
                ],
              ),
              Text('Sessions', style: AppTheme.bodySmall),
              const SizedBox(height: 10),
              Text('8:07 PM',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
              Text('First Activity', style: AppTheme.bodySmall),
              const SizedBox(height: 6),
              Text('9:00 PM',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
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
                  Text('Peak Day',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Thursday',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Text('7h 50m',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary)),
              Text('Time Used', style: AppTheme.bodySmall),
            ],
          ),
        ),
        Container(
            width: 1,
            height: 70,
            color: AppTheme.textMuted.withValues(alpha: 0.2)),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: AppTheme.primary, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('502',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary)),
                ],
              ),
              Text('Sessions', style: AppTheme.bodySmall),
              const SizedBox(height: 10),
              Text('33 apps',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
              Text('Apps Used', style: AppTheme.bodySmall),
              const SizedBox(height: 6),
              Text('Jul 10',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
              Text('Date', style: AppTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Chart Card ─────────────────────────────────────────────────────

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
                _reportViewIndex == 0
                    ? 'Hourly Usage Overview'
                    : 'Daily Usage Overview',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary),
              ),
              const Spacer(),
              _chartToggle(),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: _reportViewIndex == 0
                ? _hourlyBarChart()
                : _weeklyBarChart(),
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
    final hourlyMinutes = [
      5, 8, 12, 10, 18, 20, 22, 35, 38, 40, 33, 35, 55, 42, 38, 20, 12
    ];
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('55m 15s',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 4),
                ],
                Container(
                  height: 140 * ratio,
                  decoration: BoxDecoration(
                    color: isPeak
                        ? AppTheme.primary
                        : AppTheme.primary.withValues(alpha: 0.3 + ratio * 0.4),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('7h 50m',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 4),
                ],
                Container(
                  height: 130 * ratio,
                  decoration: BoxDecoration(
                    color: isPeak
                        ? AppTheme.primary
                        : AppTheme.primary.withValues(alpha: 0.3 + ratio * 0.4),
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
    final labels = _reportViewIndex == 0
        ? ['8 AM', '10 AM', '12 PM', '2 PM', '4 PM', '6 PM', '8 PM', '10 PM', '12 AM']
        : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels
          .map((l) => Text(l,
              style: const TextStyle(
                  fontSize: 10, color: AppTheme.textMuted)))
          .toList(),
    );
  }

  // ─── Activity Row ────────────────────────────────────────────────────

  Widget _buildActivityRow() {
    final items = _reportViewIndex == 0
        ? [
            _ActivityItem(Icons.wb_sunny_outlined, 'First Activity',
                '08:09 AM', AppTheme.green),
            _ActivityItem(Icons.nights_stay_outlined, 'Last Activity',
                '11:47 PM', AppTheme.primary),
            _ActivityItem(
                Icons.trending_up, 'Most Active', '8 PM – 9 PM', AppTheme.red),
          ]
        : [
            _ActivityItem(
                Icons.trending_up, 'Most Active', 'Thursday', AppTheme.primary),
            _ActivityItem(
                Icons.trending_down, 'Least Active', 'Monday', AppTheme.green),
            _ActivityItem(
                Icons.trending_flat, 'Daily Avg', '5h 28m', AppTheme.red),
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
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary),
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
    final insights = _reportViewIndex == 0
        ? [
            _InsightItem(Icons.access_time, AppTheme.primary,
                'You were most active in the evening.'),
            _InsightItem(Icons.visibility, AppTheme.green,
                'Peak productivity window around 2 PM – 4 PM.'),
            _InsightItem(Icons.phone_android, AppTheme.primary,
                'Consider taking breaks between 8 PM – 10 PM.'),
          ]
        : [
            _InsightItem(Icons.trending_up, AppTheme.primary,
                'Thursday was your busiest day this week.'),
            _InsightItem(Icons.trending_down, AppTheme.green,
                'Monday had the lowest screen time.'),
            _InsightItem(Icons.calendar_today, AppTheme.primary,
                'You averaged 5h 28m per day.'),
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
              const Text('Insights',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
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
                        child: Icon(insight.icon,
                            size: 18, color: insight.color),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        insight.text,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                            height: 1.3),
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

// ─── Settings Page ──────────────────────────────────────────────────────

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // Profile section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: AppTheme.primary, size: 26),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                      SizedBox(height: 2),
                      Text('Manage your profile', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppTheme.textMuted),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _settingsTile(context, Icons.notifications_outlined, 'Notifications', 'Manage alerts & reminders'),
          _settingsTile(context, Icons.palette_outlined, 'Appearance', 'Theme & display'),
          _settingsTile(context, Icons.lock_outline, 'Privacy', 'Data & permissions'),
          _settingsTile(context, Icons.storage_outlined, 'Data Management', 'Export, clear & backup'),
          _settingsTile(context, Icons.info_outline, 'About', 'Version & licenses'),
        ],
      ),
    );
  }

  Widget _settingsTile(BuildContext context, IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary, size: 22),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
        trailing: const Icon(Icons.chevron_right, size: 20, color: AppTheme.textMuted),
        onTap: () {},
      ),
    );
  }
}
