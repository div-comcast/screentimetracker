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
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => AppUsageTile(
                    app: dummyApps[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SessionsScreen(app: dummyApps[index]),
                        ),
                      );
                    },
                  ),
                  childCount: dummyApps.length,
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

  // ─── "Apps" label + "By Usage Time" sort ──────────────────────────

  Widget _buildSortHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          const Text('Apps', style: AppTheme.headlineMedium),
          const Spacer(),
          Row(
            children: [
              Text(
                'By Usage Time',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.sort, size: 18, color: AppTheme.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}
