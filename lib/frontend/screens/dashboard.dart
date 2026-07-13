import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../theme/app_theme.dart';
import '../widgets/usage_kpi.dart';
import '../widgets/topbar_section.dart';
import '../widgets/appusage_tiles.dart';
import 'sessions.dart';
import 'timeline.dart';

/// Main dashboard screen — assembles all widgets matching the design.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedTab = 0;
  String _selectedCategory = 'All';

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
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──────────────────────────────────────────
            SliverToBoxAdapter(child: _buildAppBar()),

            // ── Date Navigator ───────────────────────────────────
            SliverToBoxAdapter(child: _buildDateNav()),

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
            if (_selectedTab == 2) ...[
              // Timeline view
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => TimelineTile(
                    entry: dummyTimelineEntries[index],
                    isFirst: index == 0,
                    isLast: index == dummyTimelineEntries.length - 1,
                  ),
                  childCount: dummyTimelineEntries.length,
                ),
              ),
            ] else ...[
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
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }

  // ─── Top bar: hamburger, "Daily Usage" dropdown, calendar icon ─────

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.menu, color: AppTheme.textPrimary, size: 26),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Daily Usage',
                style: AppTheme.headlineMedium.copyWith(fontSize: 17),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down,
                  color: AppTheme.textPrimary, size: 22),
            ],
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: AppTheme.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Date navigation: < 10 July 2026 > ────────────────────────────

  Widget _buildDateNav() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.chevron_left, color: AppTheme.primary),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today,
                    color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  dummyDate,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.chevron_right, color: AppTheme.primary),
          ),
        ],
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
