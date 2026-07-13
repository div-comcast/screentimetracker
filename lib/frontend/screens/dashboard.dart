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

            // ── Summary Card ─────────────────────────────────────
            SliverToBoxAdapter(
              child: UsageSummaryCard(
                kpi: dummyKpi,
                donutSegments: dummyDonutSegments,
                date: dummyDate,
              ),
            ),

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
          const Icon(Icons.menu, color: AppTheme.textPrimary, size: 26),
          const Spacer(),
          // Left arrow (shift range/day back by 1)
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
          // Right arrow (shift range/day forward by 1)
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
          // Calendar toggle
          GestureDetector(
            onTap: () => setState(() => _showCalendar = !_showCalendar),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _showCalendar
                    ? AppTheme.primary
                    : AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.calendar_today,
                color: _showCalendar ? Colors.white : AppTheme.primary,
                size: 20,
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

          // Calendar grid
          SizedBox(
            height: 280,
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppTheme.primary,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: AppTheme.textPrimary,
                ),
                textTheme: Theme.of(context).textTheme.copyWith(
                  headlineSmall: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
              ),
              child: CalendarDatePicker(
                initialDate: _endDate,
                firstDate: _minDate,
                lastDate: _today,
                onDateChanged: _onCalendarDateTap,
              ),
            ),
          ),

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
}
